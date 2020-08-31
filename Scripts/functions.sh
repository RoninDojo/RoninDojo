#!/bin/bash
# shellcheck disable=SC2221,SC2222,1004 source=/dev/null

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
    fi

    # Source update script
    . "$HOME"/RoninDojo/Scripts/update.sh

    _update_01 # Check for bridge-utils version update

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
Looks like you don't belong in the docker group
so we will add you then reload the RoninDojo CLI.
***
${NC}
EOF
        # Create the docker group if not available
        if ! getent group docker 1>/dev/null; then
            sudo groupadd docker
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
Removing legacy fstab entries in favor of the
systemd mount service...
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
Removing ipv6 disable setting in kernel line favor of
sysctl...
***
${NC}
EOF
    fi

    # Check for sudoers file for password prompt timeout
    _set_sudo_timeout

    # Force dependency on docker and tor unit files to depend on
    # external drive mount
    _systemd_unit_drop_in_check

    # Checks to see if BackendUI is installed
    _isbackend_ui
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
            sudo mkdir "/etc/systemd/system/${x}.service.d"

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
            echo -ne "${msg} $secs\033[0K seconds...\r"
        fi
        sleep 1
        : $((secs--))
    done
    echo -e "\n" # Add new line
}

#
# Setup torrc
#
_setup_tor() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh


    # If the setting is already active, assume user has configured it already
    if ! grep -E "^\s*DataDirectory\s+.+$" /etc/tor/torrc 1>/dev/null; then

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

        # Set ownership
        sudo chown -R tor:tor "${INSTALL_DIR_TOR}"

        cat <<TOR_CONFIG
${RED}
***
Initial Tor Configuration...
***
${NC}
TOR_CONFIG

        # Default config file has example value #DataDirectory /var/lib/tor,
        if grep -E "^#DataDirectory" /etc/tor/torrc 1>/dev/null; then
            sudo sed -i -e "s:^#DataDirectory .*$:DataDirectory ${INSTALL_DIR_TOR}:" /etc/tor/torrc
        else
            sudo sed -i -e '$sDataDirectory ${INSTALL_DIR_TOR}' /etc/tor/torrc
        fi

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

    # Start Tor if needed
    if ! systemctl is-active tor 1>/dev/null; then
        sudo systemctl start tor
    else
        sudo systemctl restart tor
    fi
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
        sudo sed -i '/################ This section is just for relays/i\
HiddenServiceDir /var/lib/tor/hidden_service_ronin_backend/\
HiddenServiceVersion 3\
HiddenServicePort 80 127.0.0.1:8470\
' /etc/tor/torrc

        # restart tor service
        sudo systemctl restart tor
    fi
}

#
# Check Backend Installation
#
_isbackend_ui() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    _load_user_conf

    if [ ! -d "${BACKEND_DIR}" ]; then
        cat << EOF
${RED}
***
Backend is not installed, installing now...
***
${NC}
EOF
        _install_ronin_ui_backend
        _sleep 2 --msg "Returning to menu in"

        bash -c ronin
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
Checking for package dependencies for BackendUI
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
    test -d "${BACKEND_DIR}" || mkdir "${BACKEND_DIR}"

    # Get latest version of current RoninBackend if available
    if [ -f "${BACKEND_DIR}"/package.json ]; then
        current_ver=$(jq --raw-output '.version' "${BACKEND_DIR}"/package.json)
    fi

    # Start Backend installation procedure
    if [[ "${ver}" != "${current_ver}" ]]; then
        # cd into RoninBackend dir
        cd "${BACKEND_DIR}" || exit

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
# Checks if dojo db container.
#
_dojo_check() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    _load_user_conf

    local DOJO_PATH
    DOJO_PATH="$1"

    # Check that ${INSTALL_DIR} is mounted
    if ! findmnt "${INSTALL_DIR}" 1>/dev/null; then
        cat <<EOF
${RED}
***
Missing drive mount at ${INSTALL_DIR}! Returning to menu.
Please contact support for assistance
***
${NC}
EOF
        _sleep 5 --msg "Returning to main menu in"
        bash -c ronin
    fi

    # Check that docker service is running
    if ! sudo systemctl is-active docker 1>/dev/null; then
        sudo systemctl start docker
    fi

    if [ -d "${DOJO_PATH%/docker/my-dojo}" ] && [ "$(docker inspect --format='{{.State.Running}}' db 2>/dev/null)" = "true" ]; then
        return 0
    else
        return 1
    fi
}

#
# Source DOJO confs
#
_source_dojo_conf() {
    for conf in conf/docker-{whirlpool,indexer,bitcoind,explorer}.conf .env; do
        . "${conf}"
    done

    export BITCOIND_RPC_EXTERNAL_IP
}

#
# Select YAML files
#
_select_yaml_files() {
    local DOJO_PATH
    DOJO_PATH="$HOME/dojo/docker/my-dojo"

    yamlFiles="-f $DOJO_PATH/docker-compose.yaml"

    if [ "$BITCOIND_INSTALL" == "on" ]; then
        yamlFiles="$yamlFiles -f $DOJO_PATH/overrides/bitcoind.install.yaml"

        if [ "$BITCOIND_RPC_EXTERNAL" == "on" ]; then
            yamlFiles="$yamlFiles -f $DOJO_PATH/overrides/bitcoind.rpc.expose.yaml"
        fi
    fi

    if [ "$EXPLORER_INSTALL" == "on" ]; then
        yamlFiles="$yamlFiles -f $DOJO_PATH/overrides/explorer.install.yaml"
    fi

    if [ "$INDEXER_INSTALL" == "on" ]; then
        yamlFiles="$yamlFiles -f $DOJO_PATH/overrides/indexer.install.yaml"
    fi

    if [ "$WHIRLPOOL_INSTALL" == "on" ]; then
        yamlFiles="$yamlFiles -f $DOJO_PATH/overrides/whirlpool.install.yaml"
    fi

    # Return yamlFiles
    echo "$yamlFiles"
}

#
# Stop Samourai Dojo containers
#
_stop_dojo() {
    local DOJO_PATH
    DOJO_PATH="$HOME/dojo/docker/my-dojo"

    if [ -d "${DOJO_PATH%/docker/my-dojo}" ] && [ "$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)" = "true" ]; then
        # checks if dojo is not running (check the db container), if not running, tells user dojo is alredy stopped
        cat <<EOF
${RED}
***
Stopping Dojo...
***
${NC}
EOF
        cd "${DOJO_PATH}" || exit
    else
        echo -e "${RED}"
        echo "***"
        echo "Dojo is already stopped!"
        echo "***"
        echo -e "${NC}"
        return 1
    fi

    cat <<EOF
${RED}
***
Preparing shutdown of Dojo. Please wait...
***
${NC}
EOF

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
                sleep 1
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
Stopping all Dojo containers...
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
# Update RoninDojo
#
_update_ronin() {
    if [ -d "$HOME"/RoninDojo/.git ]; then
        cat <<EOF
${RED}
***
git repo found! Updating RoninDojo via git fetch
***
${NC}
EOF
        cd "$HOME/RoninDojo" || exit

        # Checkout master branch
        git checkout master

        # Fetch remotes
        git fetch --all

        # Reset to origin master branch
        git reset --hard origin/master

        # Check for backend updates
        _install_ronin_ui_backend
    else
        cat <<EOF > "$HOME"/ronin-update.sh
#!/bin/bash
sudo rm -rf "$HOME/RoninDojo"
cd "$HOME"
git clone -b "${RONIN_DOJO_BRANCH:-master}" https://code.samourai.io/ronindojo/RoninDojo 2>/dev/null
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

        # Check for backend updates
        _install_ronin_ui_backend
    fi
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
The /etc/docker directory already exists.
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
        sudo systemctl start docker || return 1
    elif ! systemctl is-active docker 1>/dev/null; then # is docker started?
        sudo systemctl start docker || return 1
    fi

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
    local DOJO_PATH="${1}"

    cd "${DOJO_PATH}" || exit

    if find "${DOJO_PATH%/docker/my-dojo}" -user root | grep -q '.'; then
        _stop_dojo

        # Change ownership so that we don't
        # need to use sudo ./dojo.sh
        sudo chown -R "${USER}:${USER}" "${DOJO_PATH%/docker/my-dojo}"
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
    if sudo systemctl is-active --quiet bluetooth; then
        sudo systemctl disable bluetooth 2>/dev/null
        sudo systemctl stop bluetooth
        return 0
    fi

    return 1
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
            if ! check_swap "${INSTALL_DIR_SWAP}"; then
                sudo swapoff "${INSTALL_DIR_SWAP}"
            fi
        fi

        sudo umount -l "${device}"
    fi

    # This quick hack checks if device is either a SSD device or a NVMe device
    [[ "${device}" =~ "sd" ]] && _device="${device%?}" || _device="${device%??}"

    if [ ! -b "${device}" ]; then
        echo 'type=83' | sudo sfdisk -q "${_device}" 2>/dev/null
    else
        sudo sfdisk --quiet --wipe always --delete "${_device}" &>/dev/null
        # if device exists, use sfdisk to erase filesystem and partition table

        # wipe labels
        sudo wipefs -a --force "${_device}" &>/dev/null

        # reload partition table
        partprobe

        # Create a partition table with a single partition that takes the whole disk
        echo 'type=83' | sudo sfdisk -q "${_device}" 2>/dev/null
    fi

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
        return 0
    fi

    return 1
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

    if check_swap "${file}"; then
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
***"
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