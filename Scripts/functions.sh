#!/bin/bash
# shellcheck disable=SC2221,SC2222,1004,SC2154 source=/dev/null

RED=$(tput setaf 1)
NC=$(tput sgr0)
# No Color

#
# Main function runs at beginning of script execution
#
_main() {
    # Create RoninDojo config directory
    test ! -d "$HOME"/.config/RoninDojo && mkdir -p "$HOME"/.config/RoninDojo

    if [ ! -f "$HOME/.config/RoninDojo/.run" ]; then
        _sleep 5 --msg "Welcome to RoninDojo. Loading in"
        touch "$HOME/.config/RoninDojo/.run"
        cp "$HOME"/RoninDojo/user.conf.example "$HOME"/.config/RoninDojo/user.config
    fi

    # Source update script
    . "$HOME"/RoninDojo/Scripts/update.sh

    _update_01 # Check for bridge-utils version update
    _update_02 # Migrate WST to new location and install method
    _update_03 # Add password less reboot/shutdown privileges
    _update_04 # Add password less for /usr/bin/{ufw,mount,umount,cat,grep,test,mkswap,swapon,swapoff} privileges
    _update_05 # Fix tor unit file
    _update_06 # Modify pacman to Ignore specific packages
    _update_07 # Set user.conf in appropriate place

    # Create symbolic link for main ronin script
    if [ ! -h /usr/local/bin/ronin ]; then
        sudo ln -sf "$HOME"/RoninDojo/ronin /usr/local/bin/ronin
    fi

    if ! grep RoninDojo "$HOME"/.bashrc 1>/dev/null; then
        cat << EOF >> "$HOME"/.bashrc
if [ -d $HOME/RoninDojo ]; then
$HOME/RoninDojo/Scripts/.logo
ronin
fi
EOF
    fi
    # place main ronin menu script symbolic link at /usr/local/bin folder
    # because most likely that will be path already added to your $PATH variable
    # place logo and ronin main menu script "$HOME"/.bashrc to run at each login

    # Adding user to docker group if needed
    if ! getent group docker| grep -q "${USER}"; then
        cat <<EOF
${RED}
***
Adding user to the docker group and loading RoninDojo CLI...
***
${NC}
EOF
        # Create the docker group if not available
        if ! getent group docker 1>/dev/null; then
            sudo groupadd docker 1>/dev/null
        fi

        sudo gpasswd -a "${USER}" docker
        _sleep 5 --msg "Reloading RoninDojo in" && newgrp docker
    fi

    # Remove any old legacy fstab entries when systemd.mount is enabled
    if [ -f /etc/systemd/system/mnt-usb.mount ] || [ -f /etc/systemd/system/mnt-usb1.mount ]; then
        if [ "$(systemctl is-enabled mnt-usb.mount 2>/dev/null)" = "enabled" ] || [ "$(systemctl is-enabled mnt-usb1.mount 2>/dev/null)" = "enabled" ]; then
            if ! _remove_fstab; then
                cat <<EOF
${RED}
***
Removing legacy fstab entries and replacing with systemd mount service...
***
${NC}
EOF
                _sleep 4 --msg "Starting RoninDojo in"
            fi
        fi
    fi

    # Remove any legacy ipv6.disable entries from kernel line
    if ! _remove_ipv6; then
        cat <<EOF
${RED}
***
Removing ipv6 disable setting in kernel line favor of sysctl...
***
${NC}
EOF
    fi

    # Check for sudoers file for password prompt timeout
    _set_sudo_timeout

    # Force dependency on docker and tor unit files to depend on
    # external drive mount
    _systemd_unit_drop_in_check
}

# Add ronin_data_dir to store user info
_create_ronin_data_dir() {
    if test ! -d "${ronin_data_dir}"; then
        mkdir -p "${ronin_data_dir}"
    fi
}

#
# Random Password
#
_rand_passwd() {
    tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 16 | head -n 1
}

#
# Load user defined variables
#
_load_user_conf() {
if [ -f "${HOME}/.config/RoninDojo/user.conf" ]; then
  . "${HOME}/.config/RoninDojo/user.conf"
fi
}

#
# Set systemd unit dependencies for docker and tor unit files
# to depend on ${INSTALL_DIR} mount point
#
_systemd_unit_drop_in_check() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    _load_user_conf

    local tmp systemd_mountpoint

    tmp=${INSTALL_DIR:1}               # Remove leading '/'
    systemd_mountpoint=${tmp////-}     # Replace / with -

    for x in docker tor; do
        if [ ! -f "/etc/systemd/system/${x}.service.d/override.conf" ]; then
            test -d "/etc/systemd/system/${x}.service.d" || sudo mkdir "/etc/systemd/system/${x}.service.d"

            if [ -f "/etc/systemd/system/${systemd_mountpoint}.mount" ]; then
                sudo bash -c "cat <<EOF >/etc/systemd/system/${x}.service.d/override.conf
[Unit]
RequiresMountsFor=${INSTALL_DIR}
EOF"
            fi

            # Reload systemd manager configuration
            sudo systemctl daemon-reload
        fi
    done
}

#
# Sets timeout for sudo prompt to 15mins
#
_set_sudo_timeout() {
    if [ ! -f /etc/sudoers.d/21-ronindojo ]; then
        sudo bash -c 'cat <<SUDO >>/etc/sudoers.d/21-ronindojo
Defaults env_reset,timestamp_timeout=15
SUDO'
    fi
}

#
# Package version match
#
_check_pkgver() {
    local pkgver pkg

    pkgver="${2}"
    pkg="${1}"

    if pacman -Q "${pkg}" &>/dev/null && [[ $(pacman -Q "${pkg}" | awk '{print$2}') < "${pkgver}" ]]; then
        return 1
    fi

    return 0
}

#
# Countdown timer
# Usage: _sleep <seconds> --msg "your message"
#
_sleep() {
    local secs msg verbose
    secs=1 verbose=false

    # Parse Arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            (*[0-9]*)
                secs="$1"
                shift
                ;;
            --msg)
                msg="$2"
                verbose=true
                shift 2
                ;;
        esac
    done

    while [ "$secs" -gt 0 ]; do
        if $verbose; then
            printf "%s%s %s\033[0K seconds...%s\r" "${RED}" "${msg}" "${secs}" "${NC}"
        fi
        sleep 1
        : $((secs--))
    done
    printf "\n" # Add new line
}

#
# Pause & return or continue
#
_pause() {
    cat <<EOF
${RED}
***
Press any key to ${1}...
***
${NC}
EOF
    read -n 1 -r -s
}

#
# Check if unit file exist
#
_systemd_unit_exist() {
    local service
    service="$1"

    if systemctl cat -- "$service" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

#
# is systemd unit service active?
#
_is_active() {
    local service
    service="$1"

    # Check that service is running
    if ! systemctl is-active --quiet "$service"; then
        sudo systemctl start "$service"
        return 0
    fi

    return 1
}

#
# Tor credentials backup
#
_tor_backup() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    test -d "${TOR_BACKUP_DIR}" || sudo mkdir -p "${TOR_BACKUP_DIR}"

    if [ -d "${DOJO_PATH}" ]; then
        sudo rsync -ac --delete-before --quiet "${INSTALL_DIR}/${TOR_DATA_DIR}"/_data/ "${TOR_BACKUP_DIR}"
        return 0
    fi

    return 1
}

#
# Tor credentials restore
#
_tor_restore() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    if sudo test -d "${TOR_BACKUP_DIR}"; then
        sudo rsync -ac --quiet --delete-before "${TOR_BACKUP_DIR}"/ "${INSTALL_DIR}/${TOR_DATA_DIR}"/_data
        cat <<EOF
${RED}
***
Tor credentials backup detected and restored...
***
${NC}
EOF
_sleep 2

        cat <<EOF
${RED}
***
If you wish to disable this feature, set TOR_RESTORE=false in $HOME/.conf/RoninDojo/user.conf file...
***
${NC}
EOF
_sleep 3
        return 0
    fi

    return 1
}

#
# Setup torrc
#
_setup_tor() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh


    # If the setting is already active, assume user has configured it already
    if ! grep -E "^\s*DataDirectory\s+.+$" /etc/tor/torrc 1>/dev/null; then
        cat <<TOR_CONFIG
${RED}
***
Initial Tor Configuration...
***
${NC}
TOR_CONFIG

        # Default config file has example value #DataDirectory /var/lib/tor,
        if grep -E "^#DataDirectory" /etc/tor/torrc 1>/dev/null; then
            sudo sed -i "s:^#DataDirectory .*$:DataDirectory ${INSTALL_DIR_TOR}:" /etc/tor/torrc
        fi

    else
        sudo sed -i "s:^DataDirectory .*$:DataDirectory ${INSTALL_DIR_TOR}:" /etc/tor/torrc
    fi

    # Setup directory
    if [ ! -d "${INSTALL_DIR_TOR}" ]; then
        cat <<TOR_DIR
${RED}
***
Creating Tor directory...
***
${NC}
TOR_DIR
        sudo mkdir "${INSTALL_DIR_TOR}"
    fi

    # Check for ownership
    if ! [ "$(stat -c "%U" "${INSTALL_DIR_TOR}")" = "tor" ]; then
        sudo chown -R tor:tor "${INSTALL_DIR_TOR}"
    fi

    if ! systemctl is-active --quiet tor; then
        sudo sed -i 's:^ReadWriteDirectories=-/var/lib/tor.*$:ReadWriteDirectories=-/var/lib/tor /mnt/usb/tor:' /usr/lib/systemd/system/tor.service
        #sudo sed -i '/Type=notify/i\User=tor' /usr/lib/systemd/system/tor.service
        sudo systemctl daemon-reload
        sudo systemctl restart tor
    fi

    cat <<TOR_CONFIG
${RED}
***
Setting up the Tor service...
***
${NC}
TOR_CONFIG

    # Enable service on startup
    if ! systemctl is-enabled tor 1>/dev/null; then
        sudo systemctl enable tor 2>/dev/null
    fi

    _is_active tor
}

#
# Is Electrum Rust Server Installed
#
_is_electrs() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    if [ ! -f "${dojo_path_my_dojo}"/indexer/electrs.toml ]; then
        cat <<EOF
${RED}
***
Electrum Rust Server is not installed...
***
${NC}
EOF
        _sleep 2
        cat <<EOF
${RED}
***
Install or swap Indexer & Electrs using the applications install menu...
***
${NC}
EOF
        _sleep 2
        _pause return
        return 1
    fi

    return 0
}

#
# Backend torrc
#
_setup_backend_tor() {
    if ! grep hidden_service_ronin_backend /etc/tor/torrc 1>/dev/null; then
        cat <<BACKEND_TOR_CONFIG
${RED}
***
Configuring RoninDojo Backend Tor Address...
***
${NC}
BACKEND_TOR_CONFIG
        sudo sed -i "/################ This section is just for relays/i\
HiddenServiceDir ${INSTALL_DIR_TOR}/hidden_service_ronin_backend/\n\
HiddenServiceVersion 3\n\
HiddenServicePort 80 127.0.0.1:8470\n\
" /etc/tor/torrc

        # restart tor service
        sudo systemctl restart tor
    fi
}

#
# UI Backend get credentials
#
_ui_backend_credentials() {
    cd "${RONIN_UI_BACKEND_DIR}" || exit

    API_KEY=$(grep API_KEY .env|cut -d'=' -f2)
    JWT_SECRET=$(grep JWT_SECRET .env|cut -d'=' -f2)
    BACKEND_PORT=$(grep PORT .env|cut -d'=' -f2)
    BACKEND_TOR=$(sudo cat "${INSTALL_DIR_TOR}"/hidden_service_ronin_backend/hostname)

    export API_KEY JWT_SECRET BACKEND_PORT BACKEND_TOR
}

#
# Check Backend Installation
#
_is_ronin_ui_backend() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    _load_user_conf

    if [ ! -d "${RONIN_UI_BACKEND_DIR}" ]; then
        cat <<EOF
${RED}
***
RoninUI Backend is not installed, installing now...
***
${NC}
EOF
        _install_ronin_ui_backend
        _pause return
        ronin
    fi
    # check if Ronin UI Backend is already installed
}

#
# Install Ronin UI Backend
#
_install_ronin_ui_backend() {
    local ver current_ver pkg

    . "${HOME}"/RoninDojo/Scripts/defaults.sh
    . "${HOME}"/RoninDojo/Scripts/generated-credentials.sh

    _load_user_conf

    # Import PGP keys for backend archive
    #curl -s https://keybase.io/pajasevi/pgp_keys.asc | gpg -q --import

    cat <<BACKEND
${RED}
***
Checking package dependencies for RoninUI Backend...
***
${NC}
BACKEND
    _sleep 2

    # Check for nodejs
    if ! hash node 2>/dev/null; then
        sudo pacman -S --noconfirm nodejs
    fi

    # Check for npm
    if ! hash npm 2>/dev/null; then
        sudo pacman -S --noconfirm npm
    fi

    # Check for pm2 package
    if ! hash pm2 2>/dev/null; then
        sudo npm install -g pm2 &>/dev/null
    fi

    # Check for jq package
    if ! hash jq 2>/dev/null; then
        sudo pacman -S --noconfirm jq
    fi

    # Fetch Ronin UI Backend archive
    wget -q https://ronindojo.io/downloads/RoninUI-Backend/latest.txt -O /tmp/latest.txt

    # Extract latest tar archive filename and latest version
    pkg=$( cut -d ' ' -f1 </tmp/latest.txt )
    ver=$( cut -d ' ' -f2 </tmp/latest.txt )

    # Create RoninBackend directory if missing
    test -d "${RONIN_UI_BACKEND_DIR}" || mkdir "${RONIN_UI_BACKEND_DIR}"

    # Get latest version of current RoninBackend if available
    if [ -f "${RONIN_UI_BACKEND_DIR}"/package.json ]; then
        current_ver=$(jq --raw-output '.version' "${RONIN_UI_BACKEND_DIR}"/package.json)
    fi

    # Start Backend installation procedure
    if [[ "${ver}" != "${current_ver}" ]]; then
        # cd into RoninBackend dir
        cd "${RONIN_UI_BACKEND_DIR}" || exit

        # Fetch tar archive
        wget -q https://ronindojo.io/downloads/RoninUI-Backend/"${pkg}"

        # Extract all file from package directory inside tar archive into current directory
        tar xf "${pkg}" package/ --strip-components=1 || exit

        # Remove tar archive
        rm "${pkg}"

        # Generate .env file
        if [ ! -f .env ]; then
            cat << EOF >.env
API_KEY=$GUI_API
JWT_SECRET=$GUI_JWT
PORT=3000
ACCESS_TOKEN_EXPIRATION=8h
EOF

            # NPM run
            npm run start &>/dev/null

            # pm2 save process list
            pm2 save 1>/dev/null

            # pm2 system startup
            pm2 startup 1>/dev/null

            sudo env PATH="$PATH:/usr/bin" /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u "$USER" --hp "$HOME" 1>/dev/null

            _setup_backend_tor
        else # Restart process after updating
            pm2 restart "Ronin Backend" 1>/dev/null
        fi
    fi
}

#
# Identify which SBC is being run on the system.
# For now we are just looking for Rockpro64 boards
#
which_sbc() {
    case $1 in
        rockpro64)
            if grep 'rockpro64' /etc/manjaro-arm-version &>/dev/null && [ -f /sys/class/hwmon/hwmon3/pwm1 ]; then
                return 0
            else
                return 1
            fi
            ;;
    esac
}

#
# Setup mempool docker variables
#
_mempool_conf() {
    local mempool_conf bitcoind_conf RPC_USER RPC_PASS RPC_IP RPC_PORT MEMPOOL_MYSQL_USER MEMPOOL_MYSQL_PASSWORD

    . "$HOME"/RoninDojo/Scripts/defaults.sh

    bitcoind_conf="conf"
    test -f "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf || bitcoind_conf="conf.tpl"

    mempool_conf="conf"
    test -f "${dojo_path_my_dojo}"/conf/docker-mempool.conf || mempool_conf="conf.tpl"

    if [ "${mempool_conf}" = "conf" ]; then # Existing install
        MEMPOOL_MYSQL_USER=$(grep MEMPOOL_MYSQL_USER "${dojo_path_my_dojo}"/conf/docker-mempool.conf | cut -d '=' -f2)
        MEMPOOL_MYSQL_PASSWORD=$(grep MEMPOOL_MYSQL_USER "${dojo_path_my_dojo}"/conf/docker-mempool.conf | cut -d '=' -f2)
    else
        # Generate mempool MySQL credentials for a fresh install
        . "${HOME}"/RoninDojo/Scripts/generated-credentials.sh
    fi

    # Pull values for bitcoind
    RPC_USER=$(grep BITCOIND_RPC_USER "${dojo_path_my_dojo}"/conf/docker-bitcoind."${bitcoind_conf}" | cut -d '=' -f2)
    RPC_PASS=$(grep BITCOIND_RPC_PASSWORD "${dojo_path_my_dojo}"/conf/docker-bitcoind."${bitcoind_conf}" | cut -d '=' -f2)
    RPC_IP=$(grep BITCOIND_IP "${dojo_path_my_dojo}"/conf/docker-bitcoind."${bitcoind_conf}" | cut -d '=' -f2)
    RPC_PORT=$(grep BITCOIND_RPC_PORT "${dojo_path_my_dojo}"/conf/docker-bitcoind."${bitcoind_conf}" | cut -d '=' -f2)

    _load_user_conf

    # Enable mempool and set MySQL credentials
    sudo sed -i -e 's/MEMPOOL_INSTALL=.*$/MEMPOOL_INSTALL=on/' \
    -e "s/MEMPOOL_MYSQL_USER=.*$/MEMPOOL_MYSQL_USER=${MEMPOOL_MYSQL_USER}/" \
    -e "s/MEMPOOL_MYSQL_PASSWORD=.*$/MEMPOOL_MYSQL_PASSWORD=${MEMPOOL_MYSQL_PASSWORD}/" "${dojo_path_my_dojo}"/conf/docker-mempool."${mempool_conf}"

    # Set environment values for Dockerfile
    sed -i -e "s/'mempool'@/'${MEMPOOL_MYSQL_USER}'@/" -e "s/by 'mempool'/by '${MEMPOOL_MYSQL_PASSWORD}'/"  \
    -e "s/DB_USER .*$/DB_USER ${MEMPOOL_MYSQL_USER}/" -e "s/DB_PASSWORD .*$/DB_PASSWORD ${MEMPOOL_MYSQL_PASSWORD}/" \
    -e "s/BITCOIN_NODE_HOST .*$/BITCOIN_NODE_HOST ${RPC_IP}/" -e "s/BITCOIN_NODE_PORT .*$/BITCOIN_NODE_PORT ${RPC_PORT}/" \
    -e "s/BITCOIN_NODE_USER .*$/BITCOIN_NODE_USER ${RPC_USER}/" -e "s/BITCOIN_NODE_PASS .*$/BITCOIN_NODE_PASS ${RPC_PASS}/" \
    "${dojo_path_my_dojo}"/mempool/Dockerfile
}

#
# Installs the Samourai local indexer
#
_set_addrindexer() {
    local conf

    . "$HOME"/RoninDojo/Scripts/defaults.sh

    conf="conf"
    test -f "${dojo_path_my_dojo}"/conf/docker-indexer.conf || conf="conf.tpl"

    sudo sed -i 's/INDEXER_INSTALL=.*$/INDEXER_INSTALL=on/' "${dojo_path_my_dojo}"/conf/docker-indexer."${conf}"
    sudo sed -i 's/NODE_ACTIVE_INDEXER=.*$/NODE_ACTIVE_INDEXER=local_indexer/' "${dojo_path_my_dojo}"/conf/docker-node."${conf}"

    return 0
}

#
# No indexer was found so offer user choice of SW indexer, electrs, or none
#
_no_indexer_found() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh
    # indexer names here are used as data source
    while true; do
        select indexer in "Samourai Indexer (default)" "Electrum Rust Server" "Do Not Install Indexer"; do
            case $indexer in
                "Samourai Indexer (default)")
                    cat <<EOF
${RED}
***
Selected Samourai Indexer...
***
${NC}
EOF
                    _sleep

                    _set_addrindexer
                    return 0
                    ;;
                    # samourai indexer install enabled in .conf.tpl files using sed

                "Electrum Rust Server")
                    cat <<EOF
${RED}
***
Selected Electrum Rust Server...
***
${NC}
EOF
                    _sleep
                    bash "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
                    return 0
                    ;;
                    # triggers electrs install script
                "Do Not Install Indexer")
                    cat <<EOF
${RED}
***
An Indexer will not be installed...
***
${NC}
EOF
                    _sleep
                    return 0
                    ;;
                    # indexer will not be installed
                *)
                    cat <<EOF
${RED}
***
Invalid Entry! Valid values are 1, 2 & 3...
***
${NC}
EOF
                    _sleep
                    break
                    ;;
                    # invalid data try again
            esac
        done
    done
}

#
# Check if my-dojo directory is missing
#
_is_dojo() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh
    local menu
    menu="$1"

    if [ ! -d "${DOJO_PATH}" ]; then
        cat <<EOF
${RED}
***
Missing ${DOJO_PATH} directory!
${NC}
EOF
        _pause return
        bash -c "$menu"
        exit 1
fi
}

#
# Check if mempool enabled
#
_is_mempool() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh
    local conf="${dojo_path_my_dojo}/conf/docker-mempool.conf"

    if [ -f "$conf" ]; then
        if grep "MEMPOOL_INSTALL=off" "${dojo_path_my_dojo}"/conf/docker-mempool.conf 1>/dev/null; then
            return 0
        else
            return 1
        fi
    elif grep "MEMPOOL_INSTALL=off" "${dojo_path_my_dojo}"/conf/docker-mempool.conf.tpl 1>/dev/null; then
        return 0
    else
        return 1
    fi
}

#
# Mempool url rewrites
#
_mempool_urls_to_local_btc_explorer() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh
    . "$HOME"/RoninDojo/Scripts/dojo-defaults.sh

    if ! _is_mempool && grep "blockstream" "${dojo_path_my_dojo}"/mempool/frontend/src/app/blockchain-blocks/blockchain-blocks.component.html 1>/dev/null ; then
        sudo sed -i "s:https\://www.blockstream.info/block-height/:http\://ronindojo\:${EXPLORER_KEY}@${V3_ADDR_EXPLORER}/block-height/:" "${dojo_path_my_dojo}"/mempool/frontend/src/app/blockchain-blocks/blockchain-blocks.component.html
        sudo sed -i "s:https\://www.blockstream.info/block-height/:http\://ronindojo\:${EXPLORER_KEY}@${V3_ADDR_EXPLORER}/block-height/:" "${dojo_path_my_dojo}"/mempool/frontend/src/app/blockchain-blocks/block-modal/block-modal.component.html
        sudo sed -i "s:http\://www.blockstream.info/tx/:http\://ronindojo\:${EXPLORER_KEY}@${V3_ADDR_EXPLORER}/tx/:" "${dojo_path_my_dojo}"/mempool/frontend/src/app/tx-bubble/tx-bubble.component.html
    fi
}

#
# Dojo Credentials Backup
#
_dojo_backup() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    test -d "${DOJO_BACKUP_DIR}" || sudo mkdir -p "${DOJO_BACKUP_DIR}"

    if [ -d "${DOJO_PATH}" ]; then
        sudo rsync -ac --delete-before --quiet "${dojo_path_my_dojo}"/conf "${DOJO_BACKUP_DIR}"
        return 0
    fi

    return 1
}

#
# Dojo Credentials Restore
#
_dojo_restore() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    if "${DOJO_RESTORE}"; then
        sudo rsync -ac --quiet --delete-before "${DOJO_BACKUP_DIR}"/conf "${dojo_path_my_dojo}"
        return 0
    fi

    return 1
}

#
# Checks if dojo db container.
#
_dojo_check() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    _load_user_conf

    # Check that ${INSTALL_DIR} is mounted
    if ! findmnt "${INSTALL_DIR}" 1>/dev/null; then
        cat <<EOF
${RED}
***
Missing drive mount at ${INSTALL_DIR}!
***
${NC}
EOF
        _sleep 3

        cat <<EOF
${RED}
***
Please contact support for assistance...
***
${NC}
EOF
        _sleep 5 --msg "Returning to main menu in"
        ronin
    fi

    _is_active docker

    if [ -d "${DOJO_PATH}" ] && [ "$(docker inspect --format='{{.State.Running}}' db 2>/dev/null)" = "true" ]; then
        return 0
    else
        return 1
    fi
}

#
# Checks if mempool.space is enabled
#
_mempool_check() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    _load_user_conf

    # Check that ${INSTALL_DIR} is mounted
    if ! findmnt "${INSTALL_DIR}" 1>/dev/null; then
        cat <<EOF
${RED}
***
Missing drive mount at ${INSTALL_DIR}!
***
${NC}
EOF
        _sleep 3

        cat <<EOF
${RED}
***
Please contact support for assistance...
***
${NC}
EOF
        _sleep 5 --msg "Returning to main menu in"
        ronin
    fi

    _is_active docker

    if [ -d "${DOJO_PATH}" ] && grep "MEMPOOL_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-mempool.conf 1>/dev/null ; then
        return 0
    else
        return 1
    fi
}

#
# Source DOJO confs
#
_source_dojo_conf() {
    for conf in conf/docker-{whirlpool,indexer,bitcoind,explorer,mempool}.conf .env; do
        test -f "${conf}" && . "${conf}"
    done

    export BITCOIND_RPC_EXTERNAL_IP
}

#
# Select YAML files
#
_select_yaml_files() {
    local dojo_path_my_dojo
    dojo_path_my_dojo="$HOME/dojo/docker/my-dojo"

    yamlFiles="-f $dojo_path_my_dojo/docker-compose.yaml"

    if [ "$BITCOIND_INSTALL" == "on" ]; then
        yamlFiles="$yamlFiles -f $dojo_path_my_dojo/overrides/bitcoind.install.yaml"

        if [ "$BITCOIND_RPC_EXTERNAL" == "on" ]; then
            yamlFiles="$yamlFiles -f $dojo_path_my_dojo/overrides/bitcoind.rpc.expose.yaml"
        fi
    fi

    if [ "$EXPLORER_INSTALL" == "on" ]; then
        yamlFiles="$yamlFiles -f $dojo_path_my_dojo/overrides/explorer.install.yaml"
    fi

    if [ "$INDEXER_INSTALL" == "on" ]; then
        yamlFiles="$yamlFiles -f $dojo_path_my_dojo/overrides/indexer.install.yaml"
    fi

    if [ "$WHIRLPOOL_INSTALL" == "on" ]; then
        yamlFiles="$yamlFiles -f $dojo_path_my_dojo/overrides/whirlpool.install.yaml"
    fi

    if [ "$MEMPOOL_INSTALL" == "on" ]; then
        yamlFiles="$yamlFiles -f $dojo_path_my_dojo/overrides/mempool.install.yaml"
    fi

    # Return yamlFiles
    echo "$yamlFiles"
}

#
# Stop Samourai Dojo containers
#
_stop_dojo() {
    local dojo_path_my_dojo
    dojo_path_my_dojo="$HOME/dojo/docker/my-dojo"

    if [ ! -d "${DOJO_PATH}" ]; then
        cat <<EOF
${RED}
***
Missing ${DOJO_PATH} directory!
***
${NC}
EOF
        _pause return
        bash -c "$RONIN_DOJO_MENU"
        exit 1
    fi
    # is dojo installed?

    if [ -d "${DOJO_PATH}" ] && [ "$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)" = "true" ]; then
        # checks if dojo is not running (check the db container), if not running, tells user dojo is alredy stopped

        cd "${dojo_path_my_dojo}" || exit
    else
        cat <<EOF
${RED}
***
Dojo is already stopped!
***
${NC}
EOF
        return 1
    fi

    cat <<EOF
${RED}
***
Preparing shutdown of Dojo. Please wait...
***
${NC}
EOF
_sleep

    # Source conf files
    _source_dojo_conf

    # Shutdown the bitcoin daemon
    if [ "$BITCOIND_INSTALL" == "on" ]; then
        # Renewal of bitcoind onion address
        if [ "$BITCOIND_EPHEMERAL_HS" = "on" ]; then
            docker exec -it tor rm -rf /var/lib/tor/hsv2bitcoind &> /dev/null
        fi

        # Stop the bitcoin daemon
        docker exec -it bitcoind bitcoin-cli -rpcconnect=bitcoind --rpcport=28256 \
--rpcuser="$BITCOIND_RPC_USER" --rpcpassword="$BITCOIND_RPC_PASSWORD" stop &>/dev/null

        cat <<EOF
${RED}
***
Waiting for shutdown of Bitcoin Daemon...
***
${NC}
EOF
        # Check for bitcoind process
        i=0
        while ((i<21)); do
            if timeout -k 12 2 docker container top bitcoind | grep bitcoind &>/dev/null; then
                _sleep 1
                ((i++))
            else
                break
            fi
        done

        cat <<EOF
${RED}
***
Bitcoind Daemon stopped...
***
${NC}
EOF

        cat <<EOF
${RED}
***
Stopping all Docker containers...
***
${NC}
EOF
    fi

    # Stop docker containers
    yamlFiles=$(_select_yaml_files)
    docker-compose $yamlFiles stop || exit

    return 0
}

#
# Remove old fstab entries in favor of systemd.mount.
#
_remove_fstab() {
    if grep -E '^UUID=.* \/mnt\/usb1? ext4' /etc/fstab 1>/dev/null; then
        sudo sed -i '/\/mnt\/usb1\? ext4/d' /etc/fstab
        return 1
    fi

    return 0
}

#
# Remove ipv6 from kernel line in favor of sysctl
#
_remove_ipv6() {
    if [ -f /boot/cmdline.txt ]; then
        if grep ipv6.disable /boot/cmdline.txt 1>/dev/null; then
            sudo sed -i 's/ipv6.disable=1//' /boot/cmdline.txt
            return 1
        fi
        # for RPI hardware
    elif [ -f /boot/boot.ini ]; then
        if grep ipv6.disable /boot/boot.ini 1>/dev/null; then
            sudo sed -i 's/ipv6.disable=1//' /boot/boot.ini
            return 1
        fi
        # for Odroid or RockPro64 hardware
    fi

    return 0
}

#
# Update Samourai Dojo
#
_dojo_update() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    _load_user_conf

    cd "${DOJO_PATH}" || exit

    # Fetch remotes
    git fetch --all --tags --force &>/dev/null

    # Reset to origin master branch
    git reset --hard "${SAMOURAI_COMMITISH}" 1>/dev/null
}

#
# Update RoninDojo
#
_update_ronin() {
    _load_user_conf

    if [ -d "$HOME"/RoninDojo/.git ]; then
        cat <<EOF
${RED}
***
Git repo found, downloading updates...
***
${NC}
EOF
        cd "$HOME/RoninDojo" || exit

        # Fetch remotes
        git fetch --all --tags --force 1>/dev/null

        # Reset to origin master branch
        git reset --hard "${RONIN_DOJO_BRANCH}" 1>/dev/null
    else
        cat <<EOF > "$HOME"/ronin-update.sh
#!/bin/bash
sudo rm -rf "$HOME/RoninDojo"
cd "$HOME"
git clone -b "${RONIN_DOJO_BRANCH}" https://code.samourai.io/ronindojo/RoninDojo 2>/dev/null
${RED}
***
Upgrade Complete!
***
${NC}
sleep 2
bash -c "$HOME/RoninDojo/Scripts/Menu/menu-system2.sh"
EOF
        sudo chmod +x "$HOME"/ronin-update.sh
        bash "$HOME"/ronin-update.sh
        # makes script executable and runs
        # end of script returns to menu
        # script is deleted during next run of update
    fi

    # Check TOR
    _setup_tor
}

#
# Docker Data Directory
#
_docker_datadir_setup() {
    cat <<EOF
${RED}
***
Now configuring docker to use the external SSD...
***
${NC}
EOF
    _sleep 3
    test -d "${INSTALL_DIR_DOCKER}" || sudo mkdir "${INSTALL_DIR_DOCKER}"
    # makes directory to store docker/dojo data

    if [ -d /etc/docker ]; then
        cat <<EOF
${RED}
***
The /etc/docker directory already exists...
***
${NC}
EOF
    else
        cat <<EOF
${RED}
***
Creating /etc/docker directory.
***
${NC}
EOF
        sudo mkdir /etc/docker
        # makes docker directory
    fi

    # We can skip this if daemon.json was previous created
    if [ ! -f /etc/docker/daemon.json ]; then
        sudo bash -c "cat << EOF > /etc/docker/daemon.json
{ \"data-root\": \"${INSTALL_DIR_DOCKER}\" }
EOF"
        cat <<EOF
${RED}
***
Starting docker daemon.
***
${NC}
EOF
    fi

    _is_active docker

    # Enable service on startup
    if ! sudo systemctl is-enabled docker 1>/dev/null; then
        sudo systemctl enable docker 2>/dev/null
    fi

    return 0
}

#
# Check dojo directory and file permissions
# to make sure that there are no root owned files
# from legacy use of `sudo ./dojo.sh`
#
_check_dojo_perms() {
    local dojo_path_my_dojo="${1}"

    cd "${dojo_path_my_dojo}" || exit

    if find "${DOJO_PATH}" -user root | grep -q '.'; then
        _stop_dojo

        # Change ownership so that we don't
        # need to use sudo ./dojo.sh
        sudo chown -R "${USER}:${USER}" "${DOJO_PATH}"
    else
        _stop_dojo
    fi

    return 0
}

#
# Disable ipv6
#
_disable_ipv6() {
    # Add sysctl setting to prevent any network devices
    # from being assigned any IPV6 addresses
    if [ ! -f /etc/sysctl.d/40-ipv6.conf ]; then
        sudo bash -c 'cat <<EOF >/etc/sysctl.d/40-ipv6.conf
# Disable IPV6
net.ipv6.conf.all.disable_ipv6 = 1
EOF'
    else
        return 1
    fi

    # Check to see if ipv6 stack available and if so
    # restart sysctl service
    if [ -d /proc/sys/net/ipv6 ]; then
        sudo systemctl restart systemd-sysctl
    fi

    return 0
}

#
# Disable Bluetooth
#
_disable_bluetooth() {
    _systemd_unit_exist bluetooth || return 1

    if _is_active bluetooth; then
        sudo systemctl disable bluetooth 2>/dev/null
        sudo systemctl stop bluetooth
        return 0
    fi
}

#
# Check fs type
# Shows the filesystem type of a giving partition
#
check_fstype() {
    local type device="${1}"

    type="$(lsblk -f "${device}" | tail -1 | awk '{print$2}')"

    echo "${type}"
}

#
# Create fs
# TODO add btrfs support
#
create_fs() {
    local supported_filesystems=("ext2" "ext3" "ext4" "xfs") fstype="ext4"

    # Parse Arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --fstype|-fs)
                if [[ ! "${supported_filesystems[*]}" =~ ${2} ]]; then
                    cat <<EOF
${RED}
***
Error: unsupported filesystem type ${2}
Available options are: ${supported_filesystems[@]}
Exiting!
***
${NC}
EOF
                    return 1
                else
                    local fstype="$2"
                    shift 2
                fi
                ;;
            --label|-L)
                local label="$2"
                shift 2
                ;;
            --device|-d)
                local device="$2"
                shift 2
                ;;
            --mountpoint)
                local mountpoint="$2"
                shift 2
                ;;
            -*|--*=) # unsupported flags
                echo "Error: Unsupported flag $1" >&2
                exit 1
                ;;
        esac
    done

    # Create mount point directory if not available
    if [ ! -d "${mountpoint}" ]; then
        cat <<EOF
${RED}
***
Creating ${mountpoint} directory...
***
${NC}
EOF
        sudo mkdir -p "${mountpoint}" || return 1
    elif findmnt "${device}" 1>/dev/null; then # Is device already mounted?
        # Make sure to stop tor and docker when mount point is ${INSTALL_DIR}
        if [ "${mountpoint}" = "${INSTALL_DIR}" ]; then
            for x in tor docker; do
                sudo systemctl stop "${x}"
            done

            # Stop swap on mount point
            if check_swap "${INSTALL_DIR_SWAP}"; then
                test -f "${INSTALL_DIR_SWAP}" && sudo swapoff "${INSTALL_DIR_SWAP}"
            fi
        fi

        sudo umount -l "${device}"
    fi

    # This quick hack checks if device is either a SSD device or a NVMe device
    [[ "${device}" =~ "sd" ]] && _device="${device%?}" || _device="${device%??}"

    # wipe labels
    sudo wipefs -a --force "${_device}" 1>/dev/null

    # Create a partition table with a single partition that takes the whole disk
    sudo sgdisk -Zo -n 1 -t 1:8300 "${_device}" 1>/dev/null

    cat <<EOF
${RED}
***
Using ${fstype} filesystem format for ${device} partition...
***
${NC}
EOF

    # Create filesystem
    if [[ $fstype =~ 'ext' ]]; then
        sudo mkfs."${fstype}" -q -F -L "${label}" "${device}" 1>/dev/null || return 1
    elif [[ $fstype =~ 'xfs' ]]; then
        sudo mkfs."${fstype}" -L "${label}" "${device}" 1>/dev/null || return 1
    fi

    # Sleep here ONLY, don't ask me why ask likewhoa!
    _sleep 5

    # systemd.mount unit file creation
    local uuid systemd_mount
    uuid=$(lsblk -no UUID "${device}")      # UUID of device
    local tmp=${mountpoint:1}               # Remove leading '/'
    local systemd_mountpoint=${tmp////-}    # Replace / with -

    # Check if drive unit file was previously created
    if [ -f /etc/systemd/system/"${systemd_mountpoint}".mount ]; then
        systemd_mount=true
    fi

    if ! grep "${uuid}" /etc/systemd/system/"${systemd_mountpoint}".mount &>/dev/null; then
        cat <<EOF
${RED}
***
Adding device ${device} to systemd.mount unit file
***
${NC}
EOF
        sudo bash -c "cat <<EOF >/etc/systemd/system/${systemd_mountpoint}.mount
[Unit]
Description=Mount External SSD Drive ${device}

[Mount]
What=/dev/disk/by-uuid/${uuid}
Where=${mountpoint}
Type=${fstype}
Options=defaults

[Install]
WantedBy=multi-user.target
EOF"
        # Mount filesystem
        cat <<EOF
${RED}
***
Mounting ${device} to ${mountpoint}
***
${NC}
EOF
    fi

    if $systemd_mount; then
        sudo systemctl daemon-reload
    fi

    sudo systemctl start "${systemd_mountpoint}".mount || return 1
    sudo systemctl enable "${systemd_mountpoint}".mount 2>/dev/null || return 1
    # mount drive to ${mountpoint} using systemd.mount


    return 0
}

#
# Makes sure we don't already have swapfile enabled
#
check_swap() {
    local swapfile
    swapfile="$1"

    if ! grep "$swapfile" /proc/swaps 1>/dev/null; then # no swap currently
        return 1
    fi

    return 0
}

#
# Creates a swap
# TODO enable multiple swapfiles/partitions
#
create_swap() {
    # Parse Arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --file|-f)
                file=${2}
                shift 2
                ;;
            --size|-s)
                size=${2}
                shift 2
                ;;
            -*|--*=) # unsupported flags
                echo "Error: Unsupported flag $1" >&2
                exit 1
                ;;
        esac
    done

    if ! check_swap "${file}"; then
        cat <<EOF
${RED}
***
Creating swapfile...
***
${NC}
EOF
        sudo dd if=/dev/zero of="${file}" bs="${size}" count=1 2>/dev/null
        sudo chmod 600 "${file}"
        sudo mkswap -p 0 "${file}" 1>/dev/null
        sudo swapon "${file}"
    else
        cat <<EOF
${RED}
***
Swapfile already created...
***
${NC}
EOF
    fi

    # Include fstab value
    if ! grep "${file}" /etc/fstab 1>/dev/null; then
        cat <<EOF
${RED}
***
Creating swapfile entry in /etc/fstab
***
${NC}
EOF
        sudo bash -c "cat <<EOF >>/etc/fstab
${file} swap swap defaults,pri=0 0 0
EOF"
    fi
}

#
# Check if specter is installed
#
_is_specter(){
    if [ -d "$HOME"/.specter ]; then
        return 0
    else
        return 1
    fi
}

#
# Check if udev rules for HWW are installed if not install them.
# Allows for users to plug HWW straight into their Ronin and then connect to their Specter
#
_specter_hww_udev_rules() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    if [ ! -f /etc/udev/rules.d/51-coinkite.rules ] ; then
        sudo cp "$HOME"/specter-"$SPECTER_VERSION"/udev/*.rules /etc/udev/rules.d/
        sudo udevadm trigger
        sudo udevadm control --reload-rules

        # _sleep 5 --msg "Reloading RoninDojo in" && newgrp docker if not add it
        if getent group plugdev 1>/dev/null; then
            sudo groupadd plugdev
        fi

        if ! getent group plugdev | grep -q "${USER}"; then
            cat <<EOF
${RED}
***
Adding user to plugdev group...
***
${NC}
EOF
            sudo usermod -a plugdev "${USER}"
            _sleep 5 --msg "Reloading RoninDojo in" && newgrp plugdev
        fi
    fi
}

#
# Specter check cert
#
_specter_cert_check() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    if [ ! -f "$HOME"/.specter/cert.pm ] ; then
        cat <<EOF
${RED}
***
Creating Self-Signed Certs for local LAN use
***
${NC}
EOF
        cd "$HOME"/specter-"$SPECTER_VERSION"/docs || exit
        ./gen-certificate.sh "${ip}"

        cp key.pem "$HOME"/.config/RoninDojo/specter-key.pem
        cp cert.pem "$HOME"/.config/RoninDojo/specter-cert.pem

    fi

    return 0
}

#
# Specter systemd unit file creation
#
_specter_create_systemd_unit_file() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    local upgrade
    upgrade=false

    # Parse Arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --upgrade)
                upgrade=true
                break
                ;;
        esac
    done

    if ! grep "specter_server" /etc/tor/torrc 1>/dev/null && [ ! -d "${INSTALL_DIR_TOR}"/specter_server ] || "${upgrade}" ; then
        sudo sed -i "/################ This section is just for relays/i\
HiddenServiceDir ${INSTALL_DIR_TOR}/specter_server/\n\
HiddenServiceVersion 3\n\
HiddenServicePort 443 127.0.0.1:25441\n\
" /etc/tor/torrc
    fi
    # Set tor hiddenservice for https specter server

    sudo bash -c "cat <<EOF > /etc/systemd/system/specter.service
[Unit]
Description=Specter Desktop Service
After=multi-user.target

[Service]
User=$USER
Type=simple
ExecStart=$HOME/.venv_specter/bin/python -m cryptoadvance.specter server --host 0.0.0.0 --cert=$HOME/.config/RoninDojo/cert.pem --key=$HOME/.config/RoninDojo/key.pem
Environment=PATH=$HOME/.venv_specter/bin
WorkingDirectory=$HOME/specter-$SPECTER_VERSION/src
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF
"
    return 0
}

_install_specter(){
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    cd "${HOME}" || exit

    cat <<EOF
${RED}
***
Installing Specter $SPECTER_VERSION ...
***
${NC}
EOF

    git clone -q -b "$SPECTER_VERSION" "$SPECTER_URL" "$HOME"/specter-"$SPECTER_VERSION" || exit

    sed -i 's/  -disablewallet=.*$/  -disablewallet=0/' "${dojo_path_my_dojo}"/bitcoin/restart.sh

    sudo sed -i "s:^#ControlPort .*$:ControlPort 9051:" /etc/tor/torrc
    sudo systemctl restart tor

    if ! hash gcc 2>/dev/null; then
        cat <<EOF
${RED}
***
Installing gcc
***
${NC}
EOF
        sudo pacman -Syy
        sudo pacman -S --noconfirm gcc
    fi

    if ! hash libusb 2>/dev/null; then
        cat <<EOF
${RED}
***
Installing libusb
***
${NC}
EOF
     sudo pacman -S --noconfirm libusb
    fi

    if [ -d .venv_specter ]; then
        cat <<EOF
${RED}
***
venv is already set ...
***
${NC}
EOF
    else
        python3 -m venv "$HOME"/.venv_specter
    fi

    cd "$HOME"/specter-"$SPECTER_VERSION" || exit
    "$HOME"/.venv_specter/bin/python3 setup.py install

    _specter_create_systemd_unit_file

    _specter_cert_check

    _specter_hww_udev_rules

    _ufw_rule_add "${ip_range}" 25441 specter

    sudo systemctl daemon-reload
    sudo systemctl {enable,start} specter 2>/dev/null
    # Using enable and start to ensure the startup creates the .specter dir

    return 0
}

_upgrade_specter(){
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    shopt -s nullglob

    cd "${HOME}" || exit

    for dir in specter*; do
        if [[ "${dir}" != specter-$SPECTER_VERSION ]]; then
            cat <<EOF
${RED}
***
Proceeding to upgrade to $SPECTER_VERSION ...
***
${NC}
EOF
            wget --quiet "$SPECTER_SIGN_KEY_URL"
            gpg --import "$SPECTER_SIGN_KEY"
            rm "$SPECTER_SIGN_KEY"

            wget --quiet "$SPECTER_URL"/v"$SPECTER_VERSION"/sha256.signed.txt
            gpg --verify sha256.signed.txt

            wget --quiet "$SPECTER_URL"/v"$SPECTER_VERSION"/cryptoadvance.specter-"$SPECTER_VERSION".tar.gz

            if grep cryptoadvance.specter-"$SPECTER_VERSION".tar.gz sha256.signed.txt | sha256sum -c -; then
                cat <<EOF
${RED}
***
Good verification... Installing now
***
${NC}
EOF
            else
                cat <<EOF
${RED}
***
Verification failed...
***
${NC}
EOF
                _sleep 5 --msg "Returning to main menu in"
                ronin
            fi

            cat <<EOF
${RED}
***
Proceeding to upgrade to $SPECTER_VERSION ...
***
${NC}
EOF
            _sleep

            sudo systemctl stop specter
            sudo rm /etc/systemd/system/specter.service

            sudo rm -rf "${dir}"

            sed -i 's/  -disablewallet=.*$/  -disablewallet=0/' "${dojo_path_my_dojo}"/bitcoin/restart.sh
        else
            cat <<EOF
${RED}
***
On latest version of Specter ...
***
${NC}
EOF
            _sleep 2
            sed -i 's/  -disablewallet=.*$/  -disablewallet=0/' "${dojo_path_my_dojo}"/bitcoin/restart.sh
            return 0
        fi
    done

    mkdir "$HOME"/specter-"$SPECTER_VERSION"

    tar -zxf cryptoadvance.specter-"$SPECTER_VERSION".tar.gz -C "$HOME"/specter-"$SPECTER_VERSION" --strip-components 1
    rm sha256.signed.txt ./*.tar.gz

    if [ -d .venv_specter ]; then
        cat <<EOF
${RED}
***
venv is already set ...
***
${NC}
EOF
    else
        python3 -m venv "$HOME"/.venv_specter
    fi

    cd "$HOME"/specter-"$SPECTER_VERSION" || exit
    "$HOME"/.venv_specter/bin/python3 setup.py install
    # Create file .flaskenv

    _specter_create_systemd_unit_file --upgrade

    _specter_cert_check

    _specter_hww_udev_rules

    # check if udev rules are present if not install them.
    if sudo ufw status | grep 25441 > /dev/null ; then
        cat <<EOF
${RED}
***
UFW already set for Specter on local LAN
***
${NC}
EOF
    else
        _ufw_rule_add "${ip_range}" 25441 specter
    fi

    sudo systemctl daemon-reload
    systemctl is-enabled specter 1>/dev/null || sudo systemctl enable specter 2>/dev/null
    sudo systemctl start specter 2>/dev/null

    return 0
}

_backup_dojo_data_dir(){
    . "${HOME}"/RoninDojo/Scripts/defaults.sh

    for data in ${backup_dojo_data}; do
        test -d "${INSTALL_DIR}"/backup/"${data}" || sudo mkdir -p "${INSTALL_DIR}"/backup/"${data}"

        if [ -d "${DOJO_PATH}" ]; then
            if ${data} == "bitcoind" ; then
                sudo rsync -ac -delete-before --quiet "${DOCKER_VOLUMES}"/my-dojo_data-"${data}"/_data/{blocks,chainstate,indexes} "${INSTALL_DIR}"/backup/"${data}"
            else
                sudo rsync -ac -delete-before --quiet "${DOCKER_VOLUMES}"/my-dojo_data-"${data}"/_data/ "${INSTALL_DIR}"/backup/"${data}"
            return 0
            fi
        else
            return 1
        fi
    done
}

_recover_dojo_data_dir(){
    . "${HOME}"/RoninDojo/Scripts/defaults.sh

    for data in "${!backup_dojo_data[@]}"; do
        test -d "${INSTALL_DIR}"/backup/"${data}" || exit
        if [ -d "${DOJO_PATH}" ]; then
                if ${data} == "bitcoind" ; then
                    sudo rm -rf "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate}
                    sudo mv -v "${INSTALL_DIR_UNINSTALL}"/{blocks,chainstate} "${DOCKER_VOLUME_BITCOIND}"/_data/ 1>/dev/null
                else
                    sudo rm -rf "${DOCKER_VOLUMES}"/my-dojo_data-"${data}"/_data/
                    sudo rsync -ac -delete-before --quiet "${INSTALL_DIR}"/backup/"${data}" "${DOCKER_VOLUMES}"/my-dojo_data-"${data}"/_data/
                fi
            return 0
        else
            return 1
        fi
    done
}

_install_wst(){
    . "${HOME}"/RoninDojo/Scripts/defaults.sh

    cd "$HOME" || exit

    git clone -q "$WHIRLPOOL_STATS_REPO" Whirlpool-Stats-Tool 2>/dev/null
    # Download whirlpool stat tool

    if ! hash pipenv; then
        cat <<EOF
${RED}
***
Installing python-pipenv...
***
${NC}
EOF
        _sleep 1
        sudo pacman -S --noconfirm python-pipenv &>/dev/null
    fi
    # Check for python-pip and install if not found

    cd Whirlpool-Stats-Tool || exit

    pipenv install -r requirements.txt &>/dev/null
    # Change to whirlpool stats directory, otherwise exit
    # install whirlpool stat tool
    # install WST
}

_install_boltzmann(){
    . "${HOME}"/RoninDojo/Scripts/defaults.sh

    cd "$HOME" || exit

    git clone -q "$BOLTZMANN_REPO"

    cd boltzmann || exit
    # Pull Boltzmann

    cat <<EOF
${RED}
***
Checking package dependencies...
***
${NC}
EOF
    _sleep

    if ! hash pipenv; then
        cat <<EOF
${RED}
***
Installing pipenv...
***
${NC}
EOF
        sudo pacman -S --noconfirm python-pipenv &>/dev/null
    fi

    # Setup a virtual environment to hold boltzmann dependencies. We should use this
    # with all future packages that ship a requirements.txt.
    pipenv install -r requirements.txt &>/dev/null
    pipenv install sympy numpy &>/dev/null
}

_is_bisq(){
    . "${HOME}"/RoninDojo/Scripts/defaults.sh

    if [ -f "${ronin_data_dir}"/bisq.txt ]; then
        return 0
    else
        return 1
    fi
}

_install_bisq(){
    . "${HOME}"/RoninDojo/Scripts/defaults.sh

    _create_ronin_data_dir

    sed -i -e "/  -txindex=1/i\  -peerbloomfilters=1" \
        -e "/  -txindex=1/i\  -whitelist=bloomfilter@${ip}" "${dojo_path_my_dojo}"/bitcoin/restart.sh

    echo "peerbloomfilters=1" > "${ronin_data_dir}"/bisq.txt
}

#
# UFW rule add
#
_ufw_rule_add(){
    ip=$1
    port=$2
    service=$3

    sudo ufw allow to "$ip" from any "$port" "$service"
    sudo ufw reload
}