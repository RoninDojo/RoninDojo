#!/bin/bash
# shellcheck disable=SC2221,SC2222

RED=$(tput setaf 1)
NC=$(tput sgr0)
# No Color

#
# Main function runs at beginning of script execution
#
_main() {
    # Create symbolic link for main ronin script
    if [ ! -h /usr/local/bin/ronin ]; then
        sudo ln -sf "$HOME"/RoninDojo/ronin /usr/local/bin/ronin
    fi

    # Adding user to docker group if needed
    if ! getent group docker| grep -q "${USER}"; then
        cat <<EOF
${RED}
***
Looks like you don't belong in the docker group
so we will add you then reload the RoninDojo GUI.
***
${NC}
EOF
        # Create the docker group if not available
        if ! getent group docker 1>/dev/null; then
            sudo groupadd docker
        fi

        sudo gpasswd -a "${USER}" docker
        _sleep 5 "Reloading RoninDojo in" && newgrp docker
    fi
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
# Update RoninDojo
#
_update_ronin() {
    if [ -d ~/RoninDojo/.git ]; then
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
    else
        cat <<EOF > ~/ronin-update.sh
#!/bin/bash
sudo rm -rf ~/RoninDojo
cd ~
git clone https://code.samourai.io/ronindojo/RoninDojo
${RED}
***
Upgrade Complete!
***
${NC}
sleep 2
bash -c ~/RoninDojo/Scripts/Menu/menu-system2.sh
EOF
        sudo chmod +x ~/ronin-update.sh
        bash ~/ronin-update.sh
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
${RED}
***
Now configuring docker to use the external SSD...
***
${NC}
EOF
    _sleep 3
    test -d /mnt/usb/docker || sudo mkdir /mnt/usb/docker
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
        sudo bash -c 'cat << EOF > /etc/docker/daemon.json
{ "data-root": "/mnt/usb/docker" }
EOF'
        cat <<EOF
${RED}
***
Starting docker daemon.
***
${NC}
EOF
        sudo systemctl start docker || return 1
    fi

    # Enable service on startup
    if ! sudo systemctl is-enabled docker; then
        sudo systemctl enable docker
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

    if find ~/dojo -user root | grep -q '.'; then
        sudo ./dojo.sh stop
        # Change ownership so that we don't
        # need to use sudo ./dojo.sh
        sudo chown -R "${USER}:${USER}" "${DOJO_PATH}"
    else
        ./dojo.sh stop
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
# Check for installed package
#
find_pkg() {
    hash "$1" >/dev/null && return 0

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
            --fstype|fs)
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
                if [ ! -b "${2}" ]; then
                    cat <<EOF
${RED}
***
Error: ${2} not a block device! Exiting!
***
${NC}
EOF
                    return 1
                else
                    local device="$2"
                    shift 2
                fi
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
        sudo mkfs."${fstype}" -F -L "${label}" "${device}" &>/dev/null || return 1
    elif [[ $fstype =~ 'xfs' ]]; then
        sudo mkfs."${fstype}" -L "${label}" "${device}" &>/dev/null || return 1
    fi

    # Sleep here ONLY, don't ask me why ask likewhoa!
    sleep 2

    # systemd.mount unit file creation
    local uuid
    uuid=$(lsblk -no UUID "${device}")      # UUID of device
    local tmp=${mountpoint:1}               # Remove leading '/'
    local systemd_mountpoint=${tmp////-}    # Replace / with -

    if [ ! -f /etc/systemd/system/"${systemd_mountpoint}".mount ]; then
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
Type=ext4
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
    sudo systemctl start "${systemd_mountpoint}".mount || return 1
    sudo systemctl enable "${systemd_mountpoint}".mount || return 1
    # mount drive to ${mountpoint} using systemd.mount
    fi

    return 0
}

#
# Makes sure we don't already have swap enabled
#
check_swap() {
    if [ "$(swapon -s|wc -l)" = 0 ]; then # no swap currently
        return 0
    fi

    return 1
}

#
# Creates a swap
# TODO enable multiple swapfiles/partitions
#
create_swap() {
    test ! check_swap && return 1 # exit if swap available

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

    if check_swap; then
        cat <<EOF
${RED}
***
Creating swapfile...
***
${NC}
EOF
        sudo fallocate -l "${size}" "${file}"
        sudo chmod 600 "${file}"
        sudo mkswap -p 0 "${file}"
        sudo swapon "${file}"
    else
        cat <<EOF
${NC}
***
Swapfile already created...
***"
${NC}
EOF
    fi

    # Include fstab value
    if ! grep "${file}" /etc/fstab; then
        cat <<EOF
${NC}
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
