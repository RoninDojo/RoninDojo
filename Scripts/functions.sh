#!/bin/bash
# shellcheck disable=SC2221,SC2222,1004,SC2154 source=/dev/null

. "${HOME}"/RoninDojo/Scripts/defaults.sh
#
# Main function runs at beginning of script execution
#
_main() {
    # Create RoninDojo config directory
    test ! -d "$HOME"/.config/RoninDojo && mkdir -p "$HOME"/.config/RoninDojo

    # Create Updates history directory
    test ! -d "$HOME"/.config/RoninDojo/data/updates && mkdir -p "$HOME"/.config/RoninDojo/data/updates

    if [ ! -f "$HOME/.config/RoninDojo/.run" ]; then
        _sleep 5 --msg "Welcome to RoninDojo. Loading in"
        touch "$HOME/.config/RoninDojo/.run"
        cp "$HOME"/RoninDojo/user.conf.example "$HOME"/.config/RoninDojo/user.config
    fi

    # Source update script
    . "$HOME"/RoninDojo/Scripts/update.sh

    test -f "$HOME"/.config/RoninDojo/data/updates/01-* || _update_01 # Check for bridge-utils version update
    test -f "$HOME"/.config/RoninDojo/data/updates/02-* || _update_02 # Migrate WST to new location and install method
    test -f "$HOME"/.config/RoninDojo/data/updates/03-* || _update_03 # Add password less reboot/shutdown privileges
    test -f "$HOME"/.config/RoninDojo/data/updates/04-* || _update_04 # Add password less for /usr/bin/{ufw,mount,umount,cat,grep,test,mkswap,swapon,swapoff} privileges
    _update_05 # Check on tor unit service
    test -f "$HOME"/.config/RoninDojo/data/updates/06-* || _update_06 # Modify pacman to Ignore specific packages
    test -f "$HOME"/.config/RoninDojo/data/updates/07-* || _update_07 # Set user.conf in appropriate place
    test -f "$HOME"/.config/RoninDojo/data/updates/08-* || _update_08 # Make sure mnt-usb.mount is available
    test -f "$HOME"/.config/RoninDojo/data/updates/09-* || _update_09 # Migrate bitcoin ibd data to new backup directory
    test -f "$HOME"/.config/RoninDojo/data/updates/10-* || _update_10 # Migrate user.conf variables to lowercase
    test -f "$HOME"/.config/RoninDojo/data/updates/11-* || _update_11 # Migrate to new ui backend tor location
    test -f "$HOME"/.config/RoninDojo/data/updates/12-* || _update_12 # Set BITCOIND_DB_CACHE to use bitcoind_db_cache_total value if not set
    test -f "$HOME"/.config/RoninDojo/data/updates/13-* || _update_13 # tag that system install has been installed already
    test -f "$HOME"/.config/RoninDojo/data/updates/14-* || _update_14 # Remove user.config file if it exist
    test -f "$HOME"/.config/RoninDojo/data/updates/15-* || _update_15 # Remove duplicate bisq integration changes
    test -f "$HOME"/.config/RoninDojo/data/updates/16-* || _update_16 # Fix any existing specter installs that are missing gcc dependency
    test -f "$HOME"/.config/RoninDojo/data/updates/17-* || _update_17  # Uninstall legacy Ronin UI

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
    if ! id | grep -q "docker"; then
        if ! id "${ronindojo_user}" | grep -q "docker"; then
            cat <<EOF
${red}
***
Adding user to the docker group and loading RoninDojo CLI...
***
${nc}
EOF
        else
            newgrp docker
        fi

        # Create the docker group if not available
        if ! getent group docker 1>/dev/null; then
            sudo groupadd docker 1>/dev/null
        fi

        sudo gpasswd -a "${ronindojo_user}" docker
        _sleep 5 --msg "Reloading RoninDojo in" && newgrp docker
    fi

    # Remove any old legacy fstab entries when systemd.mount is enabled
    if [ -f /etc/systemd/system/mnt-usb.mount ] || [ -f /etc/systemd/system/mnt-backup.mount ]; then
        if [ "$(systemctl is-enabled mnt-usb.mount 2>/dev/null)" = "enabled" ] || [ "$(systemctl is-enabled mnt-backup.mount 2>/dev/null)" = "enabled" ]; then
            if ! _remove_fstab; then
                cat <<EOF
${red}
***
Removing legacy fstab entries and replacing with systemd mount service...
***
${nc}
EOF
                _sleep 4 --msg "Starting RoninDojo in"
            fi
        fi
    fi

    # Remove any legacy ipv6.disable entries from kernel line
    if ! _remove_ipv6; then
        cat <<EOF
${red}
***
Removing ipv6 disable setting in kernel line favor of sysctl...
***
${nc}
EOF
    fi

    # Check for sudoers file for password prompt timeout
    _set_sudo_timeout

    # Force dependency on docker and tor unit files to depend on
    # external drive mount
    _systemd_unit_drop_in_check
}

#
# Update pacman mirrors
#
_pacman_update_mirrors() {
    sudo pacman --quiet -Syy &>/dev/null
    return 0
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
    local _length
    _length="${1:-16}"

    tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w "$_length" | head -n 1
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
# to depend on ${install_dir} mount point
#
_systemd_unit_drop_in_check() {
    _load_user_conf

    local tmp systemd_mountpoint

    tmp=${install_dir:1}               # Remove leading '/'
    systemd_mountpoint=${tmp////-}     # Replace / with -

    for x in docker tor; do
        if [ ! -f "/etc/systemd/system/${x}.service.d/override.conf" ]; then
            test -d "/etc/systemd/system/${x}.service.d" || sudo mkdir "/etc/systemd/system/${x}.service.d"

            if [ -f "/etc/systemd/system/${systemd_mountpoint}.mount" ]; then
                sudo bash -c "cat <<EOF >/etc/systemd/system/${x}.service.d/override.conf
[Unit]
RequiresMountsFor=${install_dir}
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
# Check if package is installed or not
#
_check_pkg() {
    local pkg_bin pkg_name update
    pkg_bin="${1}"
    pkg_name="${2:-$1}"
    update=false

    # Parse Arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --update-mirrors)
                update=true
                break
                ;;
            *)
                shift 1
                ;;
        esac
    done

    [ "${pkg_name}" = "--update-mirrors" ] && pkg_name="${pkg_bin}"

    "${update}" && _pacman_update_mirrors

    if ! hash "${pkg_bin}" 2>/dev/null; then
        cat <<EOF
${red}
***
Installing ${pkg_name}...
***
${nc}
EOF
        if ! sudo pacman --quiet -S --noconfirm "${pkg_name}" &>/dev/null; then
            cat <<EOF
${red}
***
${pgk_name} failed to install!
***
${nc}
EOF
            return 1
        else
            return 0
        fi
    fi

    return 1
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
            printf "%s%s %s\033[0K seconds...%s\r" "${red}" "${msg}" "${secs}" "${nc}"
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
${red}
***
Press any key to ${1}...
***
${nc}
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
        sudo systemctl start --quiet "$service"
        return 0
    fi

    return 1
}

#
# Tor credentials backup
#
_tor_backup() {
    test -d "${tor_backup_dir}" || sudo mkdir -p "${tor_backup_dir}"

    if [ -d "${dojo_path}" ] && [ -d "${install_dir}/${tor_data_dir}"/_data/hsv3dojo ]; then
        sudo rsync -ac --delete-before --quiet "${install_dir}/${tor_data_dir}"/_data/ "${tor_backup_dir}"
        return 0
    fi

    return 1
}

#
# Tor credentials restore
#
_tor_restore() {
    if sudo test -d "${tor_backup_dir}"/_data/hsv3dojo; then
        sudo rsync -ac --quiet --delete-before "${tor_backup_dir}"/ "${install_dir}/${tor_data_dir}"/_data
        cat <<EOF
${red}
***
Tor credentials backup detected and restored...
***
${nc}
EOF
_sleep

        cat <<EOF
${red}
***
If you wish to disable this feature, set tor_backup=false in $HOME/.conf/RoninDojo/user.conf file...
***
${nc}
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
    _load_user_conf

    # If the setting is already active, assume user has configured it already
    if ! grep -E "^\s*DataDirectory\s+.+$" /etc/tor/torrc 1>/dev/null; then
        cat <<TOR_CONFIG
${red}
***
Initial Tor Configuration...
***
${nc}
TOR_CONFIG

        # Default config file has example value #DataDirectory /var/lib/tor,
        if grep -E "^#DataDirectory" /etc/tor/torrc 1>/dev/null; then
            sudo sed -i "s:^#DataDirectory .*$:DataDirectory ${install_dir_tor}:" /etc/tor/torrc
        fi

    else
        sudo sed -i "s:^DataDirectory .*$:DataDirectory ${install_dir_tor}:" /etc/tor/torrc
    fi

    # Setup directory
    if [ ! -d "${install_dir_tor}" ]; then
        cat <<TOR_DIR
${red}
***
Creating Tor directory...
***
${nc}
TOR_DIR
        sudo mkdir "${install_dir_tor}"
    fi

    # Check for ownership
    if ! [ "$(stat -c "%U" "${install_dir_tor}")" = "tor" ]; then
        sudo chown -R tor:tor "${install_dir_tor}"
    fi

    if ! systemctl is-active --quiet tor; then
        sudo sed -i 's:^ReadWriteDirectories=-/var/lib/tor.*$:ReadWriteDirectories=-/var/lib/tor /mnt/usb/tor:' /usr/lib/systemd/system/tor.service
        sudo systemctl daemon-reload
        sudo systemctl restart --quiet tor
    fi

    cat <<TOR_CONFIG
${red}
***
Setting up the Tor service...
***
${nc}
TOR_CONFIG

    # Enable service on startup
    if ! systemctl is-enabled --quiet tor; then
        sudo systemctl enable --quiet tor
    fi

    _is_active tor
}

#
# Is Electrum Rust Server Installed
#
_is_electrs() {
    if [ ! -f "${dojo_path_my_dojo}"/indexer/electrs.toml ]; then
        cat <<EOF
${red}
***
Electrum Rust Server is not installed...
***
${nc}
EOF
        _sleep
        cat <<EOF
${red}
***
Enable Electrum Rust Server using the manage applications menu...
***
${nc}
EOF
        _sleep

        _pause return
        return 1
    fi

    return 0
}

#
# Ronin UI torrc
#
_ronin_ui_setup_tor() {
    if ! grep hidden_service_ronin_backend /etc/tor/torrc 1>/dev/null; then
        cat <<EOF
${red}
***
Configuring RoninDojo Backend Tor Address...
***
${nc}
EOF
        sudo sed -i "/################ This section is just for relays/i\
HiddenServiceDir ${install_dir_tor}/hidden_service_ronin_backend/\n\
HiddenServiceVersion 3\n\
HiddenServicePort 80 127.0.0.1:8470\n\
" /etc/tor/torrc

        # restart tor service
        sudo systemctl restart --quiet tor
    fi

    # Populate or update "${ronin_data_dir}"/ronin-ui-tor-hostname with tor address
    if [ ! -f "${ronin_data_dir}"/ronin-ui-tor-hostname ]; then
        sudo cat "${install_dir_tor}"/hidden_service_ronin_backend/hostname >"${ronin_data_dir}"/ronin-ui-tor-hostname
    elif ! sudo grep -q "$(sudo cat "${install_dir_tor}"/hidden_service_ronin_backend/hostname)" "${ronin_data_dir}"/ronin-ui-tor-hostname; then
        sudo cat "${install_dir_tor}"/hidden_service_ronin_backend/hostname >"${ronin_data_dir}"/ronin-ui-tor-hostname
    fi
}

#
# Source Ronin UI credentials
#
_ronin_ui_credentials() {
    cd "${ronin_ui_path}" || exit

    JWT_SECRET=$(grep JWT_SECRET .env|cut -d'=' -f2)
    BACKEND_TOR=$(sudo cat "${install_dir_tor}"/hidden_service_ronin_backend/hostname)

    export JWT_SECRET BACKEND_TOR
}

#
# Check Ronin UI Installation
#
_is_ronin_ui() {
    _load_user_conf

    if [ ! -d "${ronin_ui_path}" ]; then
        return 1
    fi
    # check if Ronin UI is already installed

    return 0
}

#
# Install Ronin UI
#
_ronin_ui_install() {
    . "${HOME}"/RoninDojo/Scripts/generated-credentials.sh

    _load_user_conf

    cd "$HOME" || exit

    cat <<EOF
${red}
***
Checking package dependencies for Ronin UI...
***
${nc}
EOF
    _sleep

    # Check package dependencies
    _check_pkg nginx

    _check_pkg "avahi-daemon" "avahi"

    sudo npm i -g pnpm &>/dev/null

    test -d "${ronin_ui_path}" || mkdir "${ronin_ui_path}"

    # cd into Ronin UI dir
    cd "${ronin_ui_path}" || exit

    # get file URL
    _file=$(curl -s https://ronindojo.io/downloads/RoninUI/version.json | jq -r .file)

    wget -q https://ronindojo.io/downloads/RoninUI/"$_file"

    tar xzf "$_file"

    rm -f "$_file"

    # Generate .env file
    cat << EOF >.env
JWT_SECRET=$gui_jwt
NEXT_TELEMETRY_DISABLED=1
EOF

    cat <<EOF
${red}
***
Performing pnpm install, please wait...
***
${nc}
EOF

    pnpm install --prod &>/dev/null || { printf "\n %s***\nRonin UI pnpm install failed...\n***%s\n" "${red}" "${nc}";exit; }

    cat <<EOF
${red}
***
Performing Next start, please wait...
***
${nc}
EOF

    # Start app
    pm2 start pm2.config.js &>/dev/null

    # pm2 save process list
    pm2 save &>/dev/null

    # pm2 system startup
    pm2 startup &>/dev/null

    sudo env PATH="$PATH:/usr/bin" /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u "${ronindojo_user}" --hp "$HOME" &>/dev/null

    _ronin_ui_setup_tor

    _ronin_ui_vhost

    _ronin_ui_avahi_service

    _ufw_rule_add "${ip_range}" "80"
}

#
# Setup avahi service for ronindojo.local access
#
_ronin_ui_avahi_service() {
    if [ ! -f /etc/avahi/services/http.service ]; then
        # Generate service file
        sudo bash -c "cat <<EOF >/etc/avahi/services/http.service
<?xml version=\"1.0\" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM \"avahi-service.dtd\">
<!-- This advertises the RoninDojo vhost -->
<service-group>
 <name replace-wildcards=\"yes\">%h Web Application</name>
  <service>
   <type>_http._tcp</type>
   <port>80</port>
  </service>
</service-group>
EOF"
    fi

    # Setup /etc/nsswitch.conf
    sudo sed -i 's/hosts: .*$/hosts: files mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] dns mdns/' /etc/nsswitch.conf

    # Set hostname in avahi-daemon.conf
    if ! grep -q "host-name=ronindojo" /etc/avahi/avahi-daemon.conf; then
        sudo sed -i 's/.*host-name=.*$/host-name=ronindojo/' /etc/avahi/avahi-daemon.conf
    fi

    # Restart avahi-daemon service
    sudo systemctl restart avahi-daemon

    # Enable avahi-daemon on boot
    if ! systemctl is-enabled --quiet avahi-daemon; then
        sudo systemctl enable --quiet avahi-daemon
    fi

    return 0
}

#
# Setup nginx reverse proxy for Ronin UI
#
_ronin_ui_vhost() {
    if [ ! -f /etc/nginx/sites-enabled/001-roninui ]; then
        local _tor_hostname
        _tor_hostname=$(sudo cat "${install_dir_tor}"/hidden_service_ronin_backend/hostname)

        test -d /etc/nginx/sites-enabled || sudo mkdir /etc/nginx/sites-enabled

        test -d /var/log/nginx || sudo mkdir /var/log/nginx

        test -d /etc/nginx/logs || sudo mkdir /etc/nginx/logs

        # Generate nginx.conf
        sudo bash -c "cat <<'EOF' >/etc/nginx/nginx.conf
worker_processes  2;
worker_rlimit_nofile 65535;

error_log  logs/error.log;
error_log  logs/error.log  notice;
error_log  logs/error.log  info;

events {
    worker_connections  8192;
    use epoll;

    multi_accept on;
}

http {
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';

    client_header_timeout 10m;
    client_body_timeout 10m;
    client_max_body_size 0;
    client_header_buffer_size 1k;

    keepalive_timeout  10 10;

    gzip  on;
    gzip_buffers 16 8k;
    gzip_comp_level 1;
    gzip_http_version 1.1;
    gzip_min_length 10;
    gzip_types text/plain text/css application/x-javascript text/xml application/xml application/xlm+rss text/javascript image/x-icon application/vnd.ms-fontobject font/opentype application/x-font-ttf;
    gzip_vary off;
    gzip_proxied any;
    gzip_disable \"msie6\";
    gzip_static off;

    server_tokens off;
    limit_conn_zone \$binary_remote_addr zone=arbeit:10m;
    connection_pool_size 256;
    reset_timedout_connection on;
    ignore_invalid_headers on;

    include /etc/nginx/sites-enabled/*;
}
EOF"
        # Generate default server vhost
        sudo bash -c "cat <<EOF >/etc/nginx/sites-enabled/000-default
server {
    listen 80 default_server;

    server_name_in_redirect off;
    return 444;
}
EOF"
        # Generate Ronin UI reverse proxy server vhost
        sudo bash -c "cat <<'EOF' >/etc/nginx/sites-enabled/001-roninui
server {
    listen ${ip}:80;
    server_name ronindojo ${_tor_hostname};

    ## Access and error logs.
    access_log /var/log/nginx/ronindojo_access.log;
    error_log /var/log/nginx/ronindojo_error.log;

    # Prevent iframe jacking
    add_header X-Frame-Options \"SAMEORIGIN\";

    # Prevent clickjacking attacks
    add_header X-Frame-Options DENY;

    # Prevent \"mime\" based attacks
    add_header X-Content-Type-Options nosniff;

    # Prevent XSS attacks
    add_header X-XSS-Protection \"1; mode=block\";

    location / {
        proxy_http_version      1.1;
        proxy_set_header        Upgrade \$http_upgrade;
        proxy_set_header        Connection \"upgrade\";
        proxy_set_header        Host \$http_host;
        proxy_cache_bypass      \$http_upgrade;
        proxy_next_upstream     error timeout http_502 http_503 http_504;
        proxy_pass              http://127.0.0.1:8470;
    }
}
EOF"
    elif ! sudo grep -q "${ip}" /etc/nginx/sites-enabled/001-roninui; then
        # Updates the ip in vhost
        sudo sed -i "s/listen .*$/listen ${ip}:80;/" /etc/nginx/sites-enabled/001-roninui

        # Reload nginx server
        sudo systemctl reload --quiet nginx
    fi

    # Enable nginx on boot
    if ! systemctl is-enabled --quiet nginx; then
        sudo systemctl enable --quiet nginx
    fi

    return 0
}

#
# Ronin UI Uninstall
#
_ronin_ui_uninstall() {
    cd "${ronin_ui_path}" || exit

    cat <<EOF
${red}
***
Uninstalling Ronin UI...
***
${nc}
EOF
    _sleep

    # Delete app from process list
    pm2 delete "RoninUI" &>/dev/null

    # dump all processes for resurrecting them later
    pm2 save 1>/dev/null

    # Remove ${ronin_ui_path}
    cd "${HOME}" || exit

    rm -rf "${ronin_ui_path}" || exit

    # Remove nginx vhost and disable nginx on boot
    sudo rm /etc/nginx/sites-enabled/001-roninui
    sudo systemctl disable --now nginx

    # Disable avahi host and disable avahi-daemon on boot
    sudo rm /etc/avahi/services/http.service
    sudo systemctl disable --now avahi-daemon

    return 0
}

#
# Identify which SBC is being run on the system.
# For now we are just looking for Rockpro64 boards
#
which_sbc() {
    case $1 in
        rockpro64)
            if grep 'rockpro64' /etc/manjaro-arm-version &>/dev/null; then
                # Find fan control file
                cd /sys/class/hwmon || exit

                for dir in *; do
                    if [ -f "${dir}/pwm1" ]; then
                        hwmon_dir="${dir}"
                        return 0
                    fi
                done

                return 1
            else
                return 1
            fi
            ;;
    esac
}

#
# Is fan control installed
#
_is_fan_control() {
    if [ -d "${HOME}"/bitbox-base ]; then
        return 0
    fi

    return 1
}

#
# Install fan control for rockchip boards
#
_fan_control_install() {
    local upgrade
    upgrade=false

    if ! _is_fan_control; then
        git clone -q https://github.com/digitalbitbox/bitbox-base.git &>/dev/null || return 1
        cd bitbox-base/tools/bbbfancontrol || return 1
    else
        # Stop service before upgrade
        sudo systemctl stop --quiet bbbfancontrol

        if ! _fan_control_upgrade; then
            return 1
        fi

        upgrade=true
    fi

    _fan_control_compile || return 1

    _fan_control_unit_file || return 1

    _is_active bbbfancontrol

    if "${upgrade}"; then
        cat <<EOF
${red}
***
Fan control upgraded...
***
${nc}
EOF
    else
        cat <<EOF
${red}
***
Fan control installed...
***
${nc}
EOF
    fi

    return 0
}

#
# Install fan control for rockchip boards
#
_fan_control_uninstall() {
    if _is_fan_control && [ -f /etc/systemd/system/bbbfancontrol.service ]; then
        # Stop service before upgrade
        sudo systemctl stop --quiet bbbfancontrol

        sudo systemctl disable --quiet bbbfancontrol

        sudo rm /etc/systemd/system/bbbfancontrol.service

        rm -rf "${HOME}"/bitbox-base || exit

        cat <<EOF
${red}
***
Fan control Uninstalled...
***
${nc}
EOF
    fi

    return 0
}

#
# Fan Control systemd unit file
#
_fan_control_unit_file() {
    if [ ! -f /etc/systemd/system/bbbfancontrol.service ]; then
        sudo bash -c "cat <<EOF >/etc/systemd/system/bbbfancontrol.service
[Unit]
Description=BitBoxBase fancontrol
After=local-fs.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/bbbfancontrol --tmin 60 --tmax 75 --cooldown 55 -fan /sys/class/hwmon/${hwmon_dir}/pwm1
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"

        sudo systemctl enable --quiet bbbfancontrol
        sudo systemctl start --quiet bbbfancontrol
    else # Previous unit file found
        # Update unit file if hwmon directory location changed
        if ! grep "${hwmon_dir}" /etc/systemd/system/bbbfancontrol.service 1>/dev/null; then
            sudo sed -i "s:/sys/class/hwmon/hwmon[0-9]/pwm1:/sys/class/hwmon/${hwmon_dir}/pwm1:" /etc/systemd/system/bbbfancontrol.service

            # Reload systemd unit file & restart daemon
            sudo systemctl daemon-reload
            sudo systemctl restart --quiet bbbfancontrol.service
        fi
    fi

    return 0
}

#
# Fan Control build package
#
_fan_control_compile() {
    # Build package
    go build || return 1

    sudo cp bbbfancontrol /usr/local/sbin/

    return 0
}

#
# Update fan control for rockchip boards
#
_fan_control_upgrade() {
    cd "${HOME}"/bitbox-base || exit

    if (($(git pull --rebase|wc -l)>1)); then
        cd tools/bbbfancontrol || return 1
        return 0
    else
        return 1
    fi
}

#
# Enables the Samourai & or Electrs local indexer
#
_set_indexer() {
    local conf

    conf="conf"
    test -f "${dojo_path_my_dojo}"/conf/docker-indexer.conf || conf="conf.tpl"

    sudo sed -i 's/INDEXER_INSTALL=.*$/INDEXER_INSTALL=on/' "${dojo_path_my_dojo}"/conf/docker-indexer."${conf}"
    sudo sed -i 's/NODE_ACTIVE_INDEXER=.*$/NODE_ACTIVE_INDEXER=local_indexer/' "${dojo_path_my_dojo}"/conf/docker-node."${conf}"

    return 0
}

#
# Undo changes from electrs install
#
_uninstall_electrs_indexer() {
    test -f "${dojo_path_my_dojo}"/indexer/electrs.toml && rm "${dojo_path_my_dojo}"/indexer/electrs.toml

    cd "${dojo_path_my_dojo}" || exit

    for file in dojo.sh indexer/Dockerfile indexer/restart.sh tor/restart.sh; do
        git checkout "${file}" &>/dev/null
    done
    # undo changes for files

    return 0
}

#
# Checks what indexer is set if any
#
_check_indexer() {
    local conf
    conf="conf"

    test -f "${dojo_path_my_dojo}"/conf/docker-indexer.conf || conf="conf.tpl"

    if grep "NODE_ACTIVE_INDEXER=local_indexer" "${dojo_path_my_dojo}"/conf/docker-node."${conf}" 1>/dev/null && [ -f "${dojo_path_my_dojo}"/indexer/electrs.toml ]; then
        return 0
        # Found electrs
    elif grep "NODE_ACTIVE_INDEXER=local_indexer" "${dojo_path_my_dojo}"/conf/docker-node."${conf}" 1>/dev/null && [ ! -f "${dojo_path_my_dojo}"/indexer/electrs.toml ]; then
        return 1
        # Found SW indexer
    fi

    return 2 # No indexer
}

#
# No indexer was found so offer user choice of SW indexer, electrs, or none
#
_indexer_prompt() {
    . "$HOME"/RoninDojo/Scripts/defaults.sh

    cat <<EOF
${red}
***
No Indexer found...
***
${nc}
EOF
    _sleep

    cat <<EOF
${red}
***
Preparing for Indexer Prompt...
***
${nc}
EOF
    _sleep

    cat <<EOF
${red}
***
Samourai Indexer is recommended for most users as it helps with querying balances...
***
${nc}
EOF
    _sleep 3

    cat <<EOF
${red}
***
Electrum Rust Server is recommended for Hardware Wallets, Multisig, and other Electrum features...
***
${nc}
EOF
    _sleep 3

    cat <<EOF
${red}
***
Skipping the installation of either Indexer option is ok! You can always enable later...
***
${nc}
EOF
    _sleep 3

    cat <<EOF
${red}
***
Choose one of the following options for your Indexer...
***
${nc}
EOF
    _sleep

    # indexer names here are used as data source
    while true; do
        select indexer in "Samourai Indexer (recommended)" "Electrum Rust Server" "No Indexer (not recommended)"; do
            case $indexer in
                "Samourai Indexer"*)
                    cat <<EOF
${red}
***
Selected Samourai Indexer...
***
${nc}
EOF
                    _sleep

                    _check_indexer && _uninstall_electrs_indexer

                    _set_indexer
                    return 0
                    ;;
                    # Samourai indexer install enabled in .conf.tpl files using sed
                "Electrum"*)
                    cat <<EOF
${red}
***
Selected Electrum Rust Server...
***
${nc}
EOF
                    _sleep

                    _set_indexer

                    bash "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
                    return 0
                    ;;
                    # triggers electrs install script
                "No Indexer"*)
                    cat <<EOF
${red}
***
An Indexer will not be installed...
***
${nc}
EOF
                    _sleep
                    return 0
                    ;;
                    # indexer will not be installed
                *)
                    cat <<EOF
${red}
***
Invalid Entry! Valid values are 1, 2 & 3...
***
${nc}
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
    local menu
    menu="$1"

    if [ ! -d "${dojo_path}" ]; then
        cat <<EOF
${red}
***
Missing ${dojo_path} directory!
${nc}
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
    local conf
    conf="${dojo_path_my_dojo}/conf/docker-mempool.conf"

    if [ -f "$conf" ]; then
        if grep "MEMPOOL_INSTALL=off" "${dojo_path_my_dojo}"/conf/docker-mempool.conf 1>/dev/null; then
            return 1
        else
            return 0
        fi
    elif grep "MEMPOOL_INSTALL=off" "${dojo_path_my_dojo}"/conf/docker-mempool.conf.tpl 1>/dev/null; then
        return 1
    else
        return 0
    fi
}

#
# Uninstall Mempool Space Visualizer
#
_mempool_uninstall() {
    cat <<EOF
${red}
***
Uninstalling Mempool Space Visualizer...
***
${nc}
EOF
    sed -i 's/MEMPOOL_INSTALL=.*$/MEMPOOL_INSTALL=off/' "$dojo_path_my_dojo"/conf/docker-mempool.conf
    # Turns mempool install set to off

    cat <<EOF
${red}
***
Mempool Space Visualizer Uninstalled...
***
${nc}
EOF

    return 0
}

#
# Setup mempool docker variables
#
_mempool_conf() {
    local mempool_conf bitcoind_conf MEMPOOL_MYSQL_USER MEMPOOL_MYSQL_PASSWORD

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

    # source values for docker-bitcoind."${bitcoind_conf}"
    . "${dojo_path_my_dojo}"/conf/docker-bitcoind."${bitcoind_conf}"

    _load_user_conf

    # Enable mempool and set MySQL credentials
    sudo sed -i -e 's/MEMPOOL_INSTALL=.*$/MEMPOOL_INSTALL=on/' \
    -e "s/MEMPOOL_MYSQL_USER=.*$/MEMPOOL_MYSQL_USER=${MEMPOOL_MYSQL_USER}/" \
    -e "s/MEMPOOL_MYSQL_PASSWORD=.*$/MEMPOOL_MYSQL_PASSWORD=${MEMPOOL_MYSQL_PASSWORD}/" "${dojo_path_my_dojo}"/conf/docker-mempool."${mempool_conf}"

    # Set environment values for Dockerfile
    sed -i -e "s/'mempool'@/'${MEMPOOL_MYSQL_USER}'@/" -e "s/by 'mempool'/by '${MEMPOOL_MYSQL_PASSWORD}'/"  \
    -e "s/DB_USER .*$/DB_USER ${MEMPOOL_MYSQL_USER}/" -e "s/DB_PASSWORD .*$/DB_PASSWORD ${MEMPOOL_MYSQL_PASSWORD}/" \
    -e "s/BITCOIN_NODE_HOST .*$/BITCOIN_NODE_HOST ${BITCOIND_IP}/" -e "s/BITCOIN_NODE_PORT .*$/BITCOIN_NODE_PORT ${BITCOIND_RPC_PORT}/" \
    -e "s/BITCOIN_NODE_USER .*$/BITCOIN_NODE_USER ${BITCOIND_RPC_USER}/" -e "s/BITCOIN_NODE_PASS .*$/BITCOIN_NODE_PASS ${BITCOIND_RPC_PASSWORD}/" \
    "${dojo_path_my_dojo}"/mempool/Dockerfile
}

#
# Mempool Space Visualizer url rewrites
#
_mempool_urls_to_local_btc_explorer() {
    . "$HOME"/RoninDojo/Scripts/dojo-defaults.sh

    if _is_mempool && grep "blockstream" "${dojo_path_my_dojo}"/mempool/frontend/src/app/blockchain-blocks/blockchain-blocks.component.html 1>/dev/null ; then
        sudo sed -i "s:https\://www.blockstream.info/block-height/:http\://ronindojo\:${EXPLORER_KEY}@${v3_addr_explorer}/block-height/:" "${dojo_path_my_dojo}"/mempool/frontend/src/app/blockchain-blocks/blockchain-blocks.component.html
        sudo sed -i "s:https\://www.blockstream.info/block-height/:http\://ronindojo\:${EXPLORER_KEY}@${v3_addr_explorer}/block-height/:" "${dojo_path_my_dojo}"/mempool/frontend/src/app/blockchain-blocks/block-modal/block-modal.component.html
        sudo sed -i "s:http\://www.blockstream.info/tx/:http\://ronindojo\:${EXPLORER_KEY}@${v3_addr_explorer}/tx/:" "${dojo_path_my_dojo}"/mempool/frontend/src/app/tx-bubble/tx-bubble.component.html
    fi
}

#
# git current branch name. If in detached state returns zero output. We only need branch name as
# we discard any detached states in future versions
#
_git_branch_name() {
    git branch --show-current
}

#
# git reference type a.k.a is it a branch or tag?
#
_git_ref_type() {
    local _ref

    # Check if argument was passed
    if [ -z "$1" ]; then
        _ref=$(_git_branch_name)

        test "$_ref" || return 1
    else
        _ref=$1
    fi

    if git show-ref -q --verify "refs/remotes/origin/${_ref#*/}" 2>/dev/null; then
        # Valid branch
        return 3
    elif git show-ref -q --verify "refs/tags/${_ref#*/}" 2>/dev/null; then
        # Valid tag
        return 2
    else
        # Invalid reference, exit script
        return 1
    fi
}

#
# git check if local branch exist
#
_git_is_branch() {
    if git show-ref --quiet refs/heads/"${1}"; then
        return 0
    else
        return 1
    fi
}

#
# Update Samourai Dojo Repository
#
_dojo_update() {
    local _head _ret

    _load_user_conf

    cd "${dojo_path}" || exit

    # Fetch remotes
    git fetch -q --all --tags --force

    # Validate current branch from user.conf
    _git_ref_type "${samourai_commitish#*/}"
    _ret=$?

    # Validate branch/tag reference
    if ((_ret==1)); then
        cat <<EOF
${red}
***
Invalid branch or tag name for ${samourai_commitish}!!!
***
${nc}
EOF
        exit
    fi

    # Check current branch/tag
    _head=$(_git_branch_name)

    # reset any local changes
    git reset -q --hard

    # Check if on existing branch/tag
    if [ "${samourai_commitish}" != "${_head}" ]; then
        # Make sure we are not in current master branch
        if [ "${samourai_commitish}" != "origin/master" ]; then
            if ((_ret==3)); then
                if ! _git_is_branch "${samourai_commitish}"; then
                    git switch -q -c "${samourai_commitish}" -t "${samourai_commitish}"
                else
                    git branch -q -D "${samourai_commitish}"
                    git switch -q -c "${samourai_commitish}" -t "${samourai_commitish}"
                fi
            else # on a tag
                if ! _git_is_branch "${samourai_commitish}"; then # Not on existing tag
                    git checkout -q tags/"${samourai_commitish}" -b "${samourai_commitish}"
                fi
            fi
        elif ! _git_is_branch "${samourai_commitish}"; then # coming from detach state i.e tag clone
                git checkout -q "${samourai_commitish}"
        else # existing master branch
                git reset -q --hard remotes/"${samourai_commitish}"
        fi

        # Delete old local branch if available otherwise check if master branch needs
        # to be deleted
        if test "${_head}"; then
            if ! git branch -q -D "${_head}" 2>/dev/null; then
                if _git_is_branch master; then
                    git branch -q -D master
                fi
            fi
        fi
    else # On same branch/tag
        _git_ref_type
        _ret=$?

        if ((_ret==3)); then
            # valid branch, so reset hard
            git reset -q --hard remotes/"${samourai_commitish}"
        fi
    fi
}

#
# Upgrade Samourai Dojo containers
#
_dojo_upgrade() {
    cat <<EOF
${red}
***
Performing Dojo upgrade to finalize changes...
***
${nc}
EOF

    _dojo_check && _stop_dojo
    cd "${dojo_path_my_dojo}" || exit

    . dojo.sh upgrade --nolog
    _pause return

    bash -c "${ronin_applications_menu}"
}

#
# Dojo Credentials Backup
#
_dojo_backup() {
    test -d "${dojo_backup_dir}" || sudo mkdir -p "${dojo_backup_dir}"

    if [ -d "${dojo_path}" ]; then
        sudo rsync -ac --delete-before --quiet "${dojo_path_my_dojo}"/conf "${dojo_backup_dir}"
        return 0
    fi

    return 1
}

#
# Dojo Credentials Restore
#
_dojo_restore() {
    if "${dojo_conf_backup}"; then
        sudo rsync -ac --quiet --delete-before "${dojo_backup_dir}"/conf "${dojo_path_my_dojo}"

        # Apply bitcoind_db_cache_total tweak if needed
        . "$HOME"/RoninDojo/Scripts/update.sh

        test -f "$HOME"/.config/RoninDojo/data/updates/12-* || _update_12

        return 0
    fi

    return 1
}

#
# Checks if dojo db container.
#
_dojo_check() {
    _load_user_conf

    # Check that ${install_dir} is mounted
    if ! findmnt "${install_dir}" 1>/dev/null; then
        cat <<EOF
${red}
***
Missing drive mount at ${install_dir}!
***
${nc}
EOF
        _sleep 3

        cat <<EOF
${red}
***
Please contact support for assistance...
***
${nc}
EOF
        _sleep 5 --msg "Returning to main menu in"
        ronin
    fi

    _is_active docker

    if [ -d "${dojo_path}" ] && [ "$(docker inspect --format='{{.State.Running}}' db 2>/dev/null)" = "true" ]; then
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
    if [ ! -d "${dojo_path}" ]; then
        cat <<EOF
${red}
***
Missing ${dojo_path} directory!
***
${nc}
EOF
        _pause return
        bash -c "$ronin_dojo_menu"
        exit 1
    fi
    # is dojo installed?

    if docker inspect --format="{{.State.Running}}" db 1>/dev/null; then
        # checks if dojo is running (check the db container), if not running, tells user dojo is alredy stopped

        cd "${dojo_path_my_dojo}" || exit
    else
        cat <<EOF
${red}
***
Dojo is already stopped!
***
${nc}
EOF
        return 1
    fi

    cat <<EOF
${red}
***
Preparing shutdown of Dojo...
***
${nc}
EOF
_sleep

    # Source conf files
    _source_dojo_conf

    # Shutdown the bitcoin daemon
    if [ "$BITCOIND_INSTALL" == "on" ]; then
        # Renewal of bitcoind onion address
        if [ "$BITCOIND_LISTEN_MODE" == "on" ]; then
            if [ "$BITCOIND_EPHEMERAL_HS" = "on" ]; then
                docker exec -it tor rm -rf /var/lib/tor/hsv3bitcoind &> /dev/null
            fi
        fi

        # Stop the bitcoin daemon
        docker exec -it bitcoind bitcoin-cli -rpcconnect=bitcoind --rpcport=28256 \
--rpcuser="$BITCOIND_RPC_USER" --rpcpassword="$BITCOIND_RPC_PASSWORD" stop &>/dev/null

        cat <<EOF
${red}
***
Waiting for shutdown of Bitcoin Daemon...
***
${nc}
EOF
        # Check for bitcoind process
        i=0
        nbIters=$((BITCOIND_SHUTDOWN_DELAY/10))

        while ((i<nbIters)); do
            if timeout -k 12 2 docker container top bitcoind | grep bitcoind &>/dev/null; then
                sleep 1
                ((i++))
            else
                cat <<EOF
${red}
***
Bitcoin Server Daemon stopped...
***
${nc}
EOF
                break
            fi
        done

        cat <<EOF
${red}
***
Stopping all Docker containers...
***
${nc}
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
    if grep -E '(^UUID=.* \/mnt\/(usb1?|backup) ext4)' /etc/fstab 1>/dev/null; then
        sudo sed -i '/\/mnt\/usb\|backup ext4/d' /etc/fstab
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
_ronindojo_update() {
    local _head _ret

    _load_user_conf

    if [ -d "$HOME"/RoninDojo/.git ]; then
        cd "$HOME/RoninDojo" || exit

        # Fetch remotes
        git fetch -q --all --tags --force

        # Validate current branch from user.conf
        _git_ref_type "${ronin_dojo_branch#*/}"
        _ret=$?

        # Validate branch/tag reference
        if ((_ret==1)); then
            cat <<EOF
${red}
***
Invalid branch or tag name for ${ronin_dojo_branch}!!!
***
${nc}
EOF
            exit
        fi

        cat <<EOF
${red}
***
Git repo found, downloading updates...
***
${nc}
EOF

        # Check current branch/tag
        _head=$(_git_branch_name)

        # reset any local changes
        git reset -q --hard

        # Check if on existing branch/tag
        if [ "${ronin_dojo_branch}" != "${_head}" ]; then
            # Make sure we are not in current master branch
            if [ "${ronin_dojo_branch}" != "origin/master" ]; then
                if ((_ret==3)); then
                    if ! _git_is_branch "${ronin_dojo_branch}"; then
                        git switch -q -c "${ronin_dojo_branch}" -t "${ronin_dojo_branch}"
                    else
                        git branch -q -D "${ronin_dojo_branch}"
                        git switch -q -c "${ronin_dojo_branch}" -t "${ronin_dojo_branch}"
                    fi
                else # on a tag
                    if ! _git_is_branch "${ronin_dojo_branch}"; then # Not on existing tag
                        git checkout -q tags/"${ronin_dojo_branch}" -b "${ronin_dojo_branch}"
                    fi
                fi
            elif ! _git_is_branch "${ronin_dojo_branch}"; then # coming from detach state i.e tag clone
                    git checkout -q "${ronin_dojo_branch}"
            else # existing master branch
                    git reset -q --hard remotes/"${ronin_dojo_branch}"
            fi

            # Delete old local branch if available otherwise check if master branch needs
            # to be deleted
            if test "${_head}"; then
                if ! git branch -q -D "${_head}" 2>/dev/null; then
                    if _git_is_branch master; then
                        git branch -q -D master
                    fi
                fi
            fi
        else # On same branch/tag
            _git_ref_type
            _ret=$?

            if ((_ret==3)); then
                # valid branch, so reset hard
                git reset -q --hard remotes/"${ronin_dojo_branch}"
            fi
        fi
    else
        cat <<EOF > "$HOME"/ronin-update.sh
#!/bin/bash
sudo rm -rf "$HOME/RoninDojo"
cd "$HOME"

if [ "${ronin_dojo_branch}" != "origin/master" ]; then
    git clone -q -b "${ronin_dojo_branch#*/}" "${ronin_dojo_repo}" 2>/dev/null
else
    git clone -q "${ronin_dojo_repo}" 2>/dev/null
fi

# Switch over to a branch if in detached state. Usually this happens
# when you clone a tag instead of a branch
cd RoninDojo || exit

# Would not run when ronin_dojo_branch="origin/master"
git symbolic-ref -q HEAD 1>/dev/null || git switch -q -c "${ronin_dojo_branch}" -t "${ronin_dojo_branch}" 2>/dev/null
EOF

        sudo chmod +x "$HOME"/ronin-update.sh
        bash "$HOME"/ronin-update.sh
        # makes script executable and runs
        # end of script returns to menu
        # script is deleted during next run of update
    fi
}

#
# Docker Data Directory
#
_docker_datadir_setup() {
    cat <<EOF
${red}
***
Now configuring docker to use the external SSD...
***
${nc}
EOF
    _sleep 3
    test -d "${install_dir_docker}" || sudo mkdir "${install_dir_docker}"
    # makes directory to store docker/dojo data

    if [ -d /etc/docker ]; then
        cat <<EOF
${red}
***
The /etc/docker directory already exists...
***
${nc}
EOF
    else
        cat <<EOF
${red}
***
Creating /etc/docker directory.
***
${nc}
EOF
        sudo mkdir /etc/docker
        # makes docker directory
    fi

    # We can skip this if daemon.json was previous created
    if [ ! -f /etc/docker/daemon.json ]; then
        sudo bash -c "cat << EOF > /etc/docker/daemon.json
{ \"data-root\": \"${install_dir_docker}\" }
EOF"
        cat <<EOF
${red}
***
Starting docker daemon.
***
${nc}
EOF
    fi

    _is_active docker

    # Enable service on startup
    if ! sudo systemctl is-enabled --quiet docker; then
        sudo systemctl enable --quiet docker
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

    if find "${dojo_path}" -user root | grep -q '.'; then
        _dojo_check && _stop_dojo

        # Change ownership so that we don't
        # need to use sudo ./dojo.sh
        sudo chown -R "${ronindojo_user}:${ronindojo_user}" "${dojo_path}"
    else
        _dojo_check && _stop_dojo
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
        sudo systemctl restart --quiet systemd-sysctl
    fi

    return 0
}

#
# Disable Bluetooth
#
_disable_bluetooth() {
    _systemd_unit_exist bluetooth || return 1

    if _is_active bluetooth; then
        sudo systemctl --quiet disable bluetooth
        sudo systemctl stop --quiet bluetooth
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
${red}
***
Error: unsupported filesystem type ${2}
Available options are: ${supported_filesystems[@]}
Exiting!
***
${nc}
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
${red}
***
Creating ${mountpoint} directory...
***
${nc}
EOF
        sudo mkdir -p "${mountpoint}" || return 1
    elif findmnt "${device}" 1>/dev/null; then # Is device already mounted?
        # Make sure to stop tor and docker when mount point is ${install_dir}
        if [ "${mountpoint}" = "${install_dir}" ]; then
            for x in tor docker; do
                sudo systemctl stop --quiet "${x}"
            done

            # Stop swap on mount point
            if check_swap "${install_dir_swap}"; then
                test -f "${install_dir_swap}" && sudo swapoff "${install_dir_swap}"
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
${red}
***
Using ${fstype} filesystem format for ${device} partition...
***
${nc}
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
${red}
***
Adding device ${device} to systemd.mount unit file
***
${nc}
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
${red}
***
Mounting ${device} to ${mountpoint}
***
${nc}
EOF
    fi

    if $systemd_mount; then
        sudo systemctl daemon-reload
    fi

    sudo systemctl start --quiet "${systemd_mountpoint}".mount || return 1
    sudo systemctl enable --quiet "${systemd_mountpoint}".mount || return 1
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
# Returns RAM total or a percentage of it
#
_mem_total() {
    local t
    t=false

    _load_user_conf

    # Parse Arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --total|-t)
                t=true
                shift 1
                ;;
            [0-9].[0-9])
                num=$1
                shift
                ;;
        esac
    done

    if "${t}"; then
        # returns total
        awk '/MemTotal/ {printf("%d\n", $2 / 1024)}' /proc/meminfo
    else
        # returns percentage
        awk -vn="$num" '/MemTotal/ {printf("%d\n", $2 / 1024 * n )}' /proc/meminfo
    fi
}

#
# Calculate swapfile size based on available RAM
#
_swap_size() {
    # Calculate swap file size when swapfile_size variable is not set
    _size="${swapfile_size:-$(_mem_total -t)}"

    for num in 1024 2096; do
        if [ -z "${swapfile_size}" ]; then
            # < 2GB set twice RAM total for swapfile
            if (( num >= 0 && _size <= num )); then
                _size=$((_size * 2 / 1000))
                break
            fi

            # > 2GB
            if (( num >= 2096 && num <= _size )); then
                _size=$((_size / 1000))
                break
            fi
        fi
    done
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
${red}
***
Creating swapfile...
***
${nc}
EOF
        sudo dd if=/dev/zero of="${file}" bs="${size}" count=1 2>/dev/null
        sudo chmod 600 "${file}"
        sudo mkswap -p 0 "${file}" 1>/dev/null
        sudo swapon "${file}"
    else
        cat <<EOF
${red}
***
Swapfile already created...
***
${nc}
EOF
    fi

    # Include fstab value
    if ! grep "${file}" /etc/fstab 1>/dev/null; then
        cat <<EOF
${red}
***
Creating swapfile entry in /etc/fstab
***
${nc}
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
    if [ -d "$HOME"/.venv_specter ]; then
        return 0
    fi

    return 1
}

#
# Check if udev rules for HWW are installed if not install them.
# Allows for users to plug HWW straight into their Ronin and then connect to their Specter
#
_specter_hww_udev_rules() {
    _load_user_conf

    if [ ! -f /etc/udev/rules.d/51-coinkite.rules ] ; then
        sudo cp "$HOME"/specter-"$specter_version"/udev/*.rules /etc/udev/rules.d/
        sudo udevadm trigger
        sudo udevadm control --reload-rules

        if ! getent group plugdev 1>/dev/null; then
            sudo groupadd plugdev
        fi
        # Add group plugdev if missing

        if ! getent group plugdev | grep -q "${ronindojo_user}" &>/dev/null; then
            cat <<EOF
${red}
***
Adding ${ronindojo_user} to plugdev group...
***
${nc}
EOF
            sudo usermod -aG plugdev "${ronindojo_user}" 1>/dev/null
        fi
    fi
}

#
# Specter check cert
#
_specter_cert_check() {
    _load_user_conf

    if [ ! -f "$HOME"/.specter/cert.pm ] ; then
        cat <<EOF
${red}
***
Generating a self-signed certicate for local LAN use
***
${nc}
EOF
        cd "$HOME"/specter-"$specter_version"/docs || exit
        ./gen-certificate.sh "${ip}" &>/dev/null

        cp key.pem "$HOME"/.config/RoninDojo/specter-key.pem
        cp cert.pem "$HOME"/.config/RoninDojo/specter-cert.pem

    fi

    return 0
}

#
# Specter tor hidden service configuration
#
_specter_config_tor() {
    _load_user_conf

    sudo sed -i "s:^#ControlPort .*$:ControlPort 9051:" /etc/tor/torrc

    if ! grep "specter_server" /etc/tor/torrc 1>/dev/null && [ ! -d "${install_dir_tor}"/specter_server ]; then
        sudo sed -i "/################ This section is just for relays/i\
HiddenServiceDir ${install_dir_tor}/specter_server/\n\
HiddenServiceVersion 3\n\
HiddenServicePort 443 127.0.0.1:25441\n\
" /etc/tor/torrc
        sudo systemctl restart --quiet tor
    fi
    # Set tor hiddenservice for https specter server

    return 0
}

#
# Specter systemd unit file creation
#
_specter_create_systemd_unit_file() {
    _load_user_conf

    sudo bash -c "cat <<EOF > /etc/systemd/system/specter.service
[Unit]
Description=Specter Desktop Service
After=multi-user.target

[Service]
User=${ronindojo_user}
Type=simple
ExecStart=$HOME/.venv_specter/bin/python -m cryptoadvance.specter server --host 0.0.0.0 --cert=$HOME/.config/RoninDojo/cert.pem --key=$HOME/.config/RoninDojo/key.pem
Environment=PATH=$HOME/.venv_specter/bin
WorkingDirectory=$HOME/specter-$specter_version/src
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF
"
    return 0
}

_specter_uninstall() {
    local _specter_version
    _specter_version="$1"

    _load_user_conf

    cat <<EOF
${red}
***
Uninstalling Specter ${_specter_version:-$specter_version}...
***
${nc}
EOF

    if systemctl is-active --quiet specter; then
        sudo systemctl stop --quiet specter
        sudo systemctl --quiet disable specter
        sudo rm /etc/systemd/system/specter.service
        sudo systemctl daemon-reload
    fi
    # Remove systemd unit

    cd "${dojo_path_my_dojo}"/bitcoin || exit
    git checkout restart.sh &>/dev/null && cd - 1>/dev/null || exit
    # Resets to defaults

    if [ -f /etc/udev/rules.d/51-coinkite.rules ]; then
        cd "$HOME"/specter-"${_specter_version:-$specter_version}"/udev || exit

        for file in *.rules; do
            sudo rm /etc/udev/rules.d/"${file}"
        done

        sudo udevadm trigger
        sudo udevadm control --reload-rules
    fi
    # Delete udev rules

    rm -rf "$HOME"/.specter "$HOME"/specter-* "$HOME"/.venv_specter &>/dev/null
    rm "$HOME"/.config/RoninDojo/specter* &>/dev/null
    # Deletes the .specter dir, source dir, venv directory, certificate files and specter.service file

    sudo sed -i -e "s:^ControlPort .*$:#ControlPort 9051:" -e "/specter/,+3d" /etc/tor/torrc
    sudo systemctl restart --quiet tor
    # Remove torrc changes

    if getent group plugdev | grep -q "${ronindojo_user}" &>/dev/null; then
        sudo gpasswd -d "${ronindojo_user}" plugdev 1>/dev/null
    fi
    # Remove user from plugdev group
}

_specter_install(){
    _load_user_conf

    cd "${HOME}" || exit

    cat <<EOF
${red}
***
Installing Specter $specter_version, please wait...
***
${nc}
EOF

    cat <<EOF
${red}
***
Downloading latest Specter release......
***
${nc}
EOF

    git clone -q -b "$specter_version" "$specter_url" "$HOME"/specter-"$specter_version" &>/dev/null || exit

    sed -i 's/  -disablewallet=.*$/  -disablewallet=0/' "${dojo_path_my_dojo}"/bitcoin/restart.sh

    # Check for package dependencies
    _check_pkg "gcc" --update-mirrors

    if ! pacman -Q libusb 1>/dev/null; then
        _pacman_update_mirrors

        cat <<EOF
${red}
***
Installing libusb...
***
${nc}
EOF
     sudo pacman --quiet -S --noconfirm libusb
    fi

    python3 -m venv "$HOME"/.venv_specter &>/dev/null

    cd "$HOME"/specter-"$specter_version" || exit
    "$HOME"/.venv_specter/bin/python3 setup.py install &>/dev/null || return 1

    cat <<EOF
${red}
***
Configuring Specter Daemon...
***
${nc}
EOF
    _specter_create_systemd_unit_file

    _specter_config_tor

    _specter_cert_check

    _ufw_rule_add "${ip_range}" 25441

    sudo systemctl daemon-reload
    sudo systemctl enable --quiet specter
    # Using enable

    cat <<EOF
${red}
***
Loading UDEV rules for Specter HWWI...
***
${nc}
EOF
    _specter_hww_udev_rules

    sudo systemctl start --quiet specter
    # start to ensure the startup creates the .specter dir

    cat <<EOF
${red}
***
Specter $specter_version installed...
***
${nc}
EOF

    return 0
}

_specter_upgrade(){
    _load_user_conf

    shopt -s nullglob

    cd "${HOME}" || exit

    for dir in specter*; do
        if [ -d "$dir" ] && [[ "${dir}" != specter-$specter_version ]]; then
            cat <<EOF
${red}
***
Upgrading Specter to version $specter_version...
***
${nc}
EOF

            _sleep

            git clone -q -b "$specter_version" "$specter_url" "$HOME"/specter-"$specter_version" &>/dev/null || exit

            sed -i 's/  -disablewallet=.*$/  -disablewallet=0/' "${dojo_path_my_dojo}"/bitcoin/restart.sh

            sudo systemctl stop --quiet specter
            sudo rm /etc/systemd/system/specter.service

            rm -rf "${dir}"
            # Remove old specter directory
        else
            return 1
        fi
    done

    cd "$HOME"/specter-"$specter_version" || exit
    "$HOME"/.venv_specter/bin/python3 setup.py install &>/dev/null

    _specter_create_systemd_unit_file

    _specter_config_tor

    _specter_cert_check

    # check if udev rules are present if not install them.
    _ufw_rule_add "${ip_range}" "25441"

    sudo systemctl daemon-reload
    systemctl is-enabled --quiet specter || sudo systemctl enable --quiet specter

    _specter_hww_udev_rules

    sudo systemctl restart --quiet specter

    return 0
}

#
# Whirlpool Status Tool
#
_install_wst(){
    cd "$HOME" || exit

    git clone -q "$whirlpool_stats_repo" Whirlpool-Stats-Tool 2>/dev/null
    # Download whirlpool stat tool

    # Check for python-pip and install if not found
    _check_pkg "pipenv" "python-pipenv"

    cd Whirlpool-Stats-Tool || exit

    pipenv install -r requirements.txt &>/dev/null
    # Change to whirlpool stats directory, otherwise exit
    # install whirlpool stat tool
    # install WST
}

#
# Boltzmann Entropy Calculator
#
_install_boltzmann(){
    cd "$HOME" || exit

    git clone -q "$boltzmann_repo"

    cd boltzmann || exit
    # Pull Boltzmann

    cat <<EOF
${red}
***
Checking package dependencies...
***
${nc}
EOF
    _sleep

    # Check for package dependency
    _check_pkg "pipenv" "python-pipenv"

    # Setup a virtual environment to hold boltzmann dependencies. We should use this
    # with all future packages that ship a requirements.txt.
    pipenv install -r requirements.txt &>/dev/null
    pipenv install sympy numpy &>/dev/null
}

_is_bisq(){
    if [ -f "${ronin_data_dir}"/bisq.txt ]; then
        return 0
    else
        return 1
    fi
}

#
# Install Bisq Support
#
_bisq_install(){
    cat <<EOF
${red}
***
Enabling Bisq support...
***
${nc}
EOF

    . "${HOME}"/RoninDojo/Scripts/defaults.sh

    _create_ronin_data_dir

    sed -i -e "/  -txindex=1/i\  -peerbloomfilters=1" \
        -e "/  -txindex=1/i\  -whitelist=bloomfilter@${ip}" "${dojo_path_my_dojo}"/bitcoin/restart.sh

    touch "${ronin_data_dir}"/bisq.txt

    return 0
}

#
# Uninstall Bisq Support
#
_bisq_uninstall() {
    cat <<EOF
${red}
***
Disabling Bisq Support...
***
${nc}
EOF

    sed -i -e '/-peerbloomfilters=1/d' \
        -e "/-whitelist=bloomfilter@${ip}/d" "${dojo_path_my_dojo}"/bitcoin/restart.sh

    rm "${ronin_data_dir}"/bisq.txt
    # Deletes bisq.txt file

    return 0
}

#
# Indexer data backup/restore
#
_dojo_data_indexer() {
    _load_user_conf

    # Parse Arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            restore)
                if sudo test -d "${dojo_backup_indexer}/db" && sudo test -d "${docker_volume_indexer}"; then
                    cd "$dojo_path_my_dojo" || exit
                    _dojo_check && _stop_dojo

                    _sleep

                    if sudo test -d "${docker_volume_indexer}"/_data/db; then
                        sudo rm -rf "${docker_volume_indexer}"/_data/db
                    fi

                    if sudo test -d "${dojo_backup_indexer}"/db; then
                        sudo mv "${dojo_backup_indexer}"/db "${docker_volume_indexer}"/_data/
                    fi

                    # changes to dojo path, otherwise exit
                    # websearch "bash Logical OR (||)" for info
                    # stops dojo and removes new data directories
                    # then moves salvaged indexer data

                    cat <<EOF
${red}
***
Indexer data restore completed...
***
${nc}
EOF
                    _sleep

                    sudo rm -rf "${dojo_backup_indexer}"
                    # remove old salvage directories

                    cd "$dojo_path_my_dojo" || exit
                    _source_dojo_conf

                    cat <<EOF
${red}
***
Starting all Docker containers...
***
${nc}
EOF
                    # Start docker containers
                    yamlFiles=$(_select_yaml_files)
                    docker-compose $yamlFiles up --remove-orphans -d || exit # failed to start dojo
                    # start dojo
                fi
                # check for indexer db data directory, if not found continue

                if ! _dojo_check; then
                    cd "$dojo_path_my_dojo" || exit
                    _source_dojo_conf

                    # Start docker containers
                    yamlFiles=$(_select_yaml_files)
                    docker-compose $yamlFiles up --remove-orphans -d || exit # failed to start dojo
                    # start dojo
                fi

                return 0
                ;;
            backup)
                test ! -d "${dojo_backup_indexer}" && sudo mkdir "${dojo_backup_indexer}"
                # check if salvage directory exist

                if sudo test -d "${docker_volume_indexer}"/_data/db; then
                    sudo mv "${docker_volume_indexer}"/_data/db "${dojo_backup_indexer}"/
                fi

                # moves indexer data to ${dojo_backup_indexer} directory to be used by the dojo install script
                return 0
                ;;
        esac
    done
}

#
# Bitcoin IBD backup/restore
#
_dojo_data_bitcoind() {
    _load_user_conf

    # Parse Arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            restore)
                if sudo test -d "${dojo_backup_bitcoind}/blocks" && sudo test -d "${docker_volume_bitcoind}"; then
                    cat <<EOF
${red}
***
Blockchain data restore starting...
***
${nc}
EOF

                    cd "$dojo_path_my_dojo" || exit
                    _dojo_check && _stop_dojo

                    _sleep

                    for dir in blocks chainstate indexes; do
                        if sudo test -d "${docker_volume_bitcoind}"/_data/"${dir}"; then
                            sudo rm -rf "${docker_volume_bitcoind}"/_data/"${dir}"
                        fi
                    done

                    for dir in blocks chainstate indexes; do
                        if sudo test -d "${dojo_backup_bitcoind}"/"${dir}"; then
                            sudo mv "${dojo_backup_bitcoind}"/"${dir}" "${docker_volume_bitcoind}"/_data/
                        fi
                    done
                    # changes to dojo path, otherwise exit
                    # websearch "bash Logical OR (||)" for info
                    # stops dojo and removes new data directories
                    # then moves salvaged block data

                    cat <<EOF
${red}
***
Blockchain data restore completed...
***
${nc}
EOF
                    _sleep

                    sudo rm -rf "${dojo_backup_bitcoind}"
                    # remove old salvage directories

                    if ! "${dojo_data_indexer_backup}"; then
                        cd "$dojo_path_my_dojo" || exit
                        _source_dojo_conf

                        cat <<EOF
${red}
***
Starting all Docker containers...
***
${nc}
EOF
                        # Start docker containers
                        yamlFiles=$(_select_yaml_files)
                        docker-compose $yamlFiles up --remove-orphans -d || exit # failed to start dojo
                        # start dojo
                    fi
                    # Only start dojo if no indexer restore is enabled
                fi
                # check for IBD data, if not found continue
                return 0
                ;;
            backup)
                test ! -d "${dojo_backup_bitcoind}" && sudo mkdir "${dojo_backup_bitcoind}"
                # check if salvage directory exist

                for dir in blocks chainstate indexes; do
                    if sudo test -d "${docker_volume_bitcoind}"/_data/"${dir}"; then
                        sudo mv "${docker_volume_bitcoind}"/_data/"${dir}" "${dojo_backup_bitcoind}"/
                    fi
                done
                # moves blockchain data to ${dojo_backup_bitcoind} to be used by the dojo install script
                return 0
                ;;
        esac
    done
}

#
# UFW rule add
#
_ufw_rule_add(){
    ip=$1
    port=$2

    if ! sudo ufw status | grep "${port}" &>/dev/null; then
        sudo ufw allow from "$ip" to any port "$port"
        sudo ufw reload
    fi
}
