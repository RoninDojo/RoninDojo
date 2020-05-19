#!/bin/bash

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
        sudo chown -R ${USER}:${USER} ${DOJO_PATH}
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
    pacman -Q $1 >/dev/null && return 0

    return 1
}
#
# Check fs type
# Shows the filesystem type of a giving partition
#
check_fstype() {
    local device="${1}"

    local type="$(lsblk -f ${device} | tail -1 | awk '{print$2}')"

    echo ${type}
}

#
# Create fs
# TODO add btrfs support
#
create_fs() {
    local supported_filesystems=("ext2", "ext3", "ext4", "xfs") fstype="ext4"

    # Parse Arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --fstype|fs)
                if [[ ! "${supported_filesystems[@]}" =~ "${2}" ]]; then
                    cat <<EOF
$(echo -e $(tput setaf 1))
***
Error: unsupported filesystem type ${2}
Available options are: ${supported_filesystems[@]}
Exiting!
***
$(echo -e $(tput sgr0))
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
                if [ ! -b ${2} ]; then
                    cat <<EOF
$(echo -e $(tput setaf 1))
***
Error: ${2} not a block device! Exiting!
***
$(echo -e $(tput sgr0))
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
    if [ ! -d ${mountpoint} ]; then
        cat <<EOF
$(echo -e $(tput setaf 1))
***
Creating ${mountpoint} directory...
***
$(echo -e $(tput sgr0))
EOF
        sudo mkdir -p ${mountpoint} || return 1
    fi

    cat <<EOF
$(echo -e $(tput setaf 1))
***
Using ${fstype} filesystem format for ${device} partition...
***
$(echo -e $(tput sgr0))
EOF

    # Create filesystem
    if [[ $fstype =~ 'ext' ]]; then
        sudo mkfs.${fstype} -F -L ${label} ${device} &>/dev/null || return 1
    elif [[ $fstype =~ 'xfs' ]]; then
        sudo mkfs.${fstype} -L ${label} ${device} &>/dev/null || return 1
    fi

    # Sleep here ONLY, don't ask me why ask likewhoa!
    sleep 2

    # systemd.mount unit file creation
    local uuid=$(lsblk -no UUID ${device})  # UUID of device
    local tmp=${mountpoint:1}               # Remove leading '/'
    local systemd_mountpoint=${tmp////-}    # Replace / with -

    if [ ! -f /etc/systemd/system/${systemd_mountpoint}.mount ]; then
        cat <<EOF
$(echo -e $(tput setaf 1))
***
Adding device ${device} to systemd.mount unit file
***
$(echo -e $(tput sgr0))
EOF
        sudo bash -c "cat <<EOF >/etc/systemd/system/${systemd_mountpoint}.mount
[Unit]
Description=Mount External SSD Drive ${device}

[Mount]
What=/dev/disk/by-uuid/$(lsblk -no UUID ${device})
Where=${mountpoint}
Type=ext4
Options=defaults

[Install]
WantedBy=multi-user.target
EOF"
    # Mount filesystem
    cat <<EOF
$(echo -e $(tput setaf 1))
***
Mounting ${device} to ${mountpoint}
***
$(echo -e $(tput sgr0))
EOF
    sudo systemctl start ${systemd_mountpoint}.mount || return 1
    sudo systemctl enable ${systemd_mountpoint}.mount || return 1
    # mount drive to ${mountpoint} using systemd.mount
    fi

    return 0
}

#
# Makes sure we don't already have swap enabled
#
check_swap() {
    if [ $(swapon -s|wc -l) = 0 ]; then # no swap currently
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
$(echo -e $(tput setaf 1))
***
Creating swapfile...
***
$(echo -e $(tput sgr0))
EOF
        sudo fallocate -l ${size} ${file}
        sudo chmod 600 ${file}
        sudo mkswap -p 0 ${file}
        sudo swapon ${file}
    else
        cat <<EOF
$(echo -e $(tput sgr0))
***
Swapfile already created...
***"
$(echo -e $(tput sgr0))
EOF
    fi

    # Include fstab value
    if ! grep '${file}' /etc/fstab; then
        cat <<EOF
$(echo -e $(tput sgr0))
***
Creating swapfile entry in /etc/fstab
***
$(echo -e $(tput sgr0))
EOF
        sudo bash -c "cat <<EOF >>/etc/fstab
${file} swap swap defaults,pri=0 0 0
EOF"
    fi
}
