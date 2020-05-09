#!/bin/bash

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
                    sleep 2s
                    local device="$2"
                    local uuid=$(lsblk -no UUID ${device})
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
        sleep 2s
        sudo mkdir -p ${2} || return 1
    fi

    cat <<EOF
$(echo -e $(tput setaf 1))
***
Using ${2} filesystem format for /dev/${device} partition...
***
$(echo -e $(tput sgr0))
EOF
    sleep 2s

    # /etc/fstab changes
    if ! grep "${uuid}" /etc/fstab; then
        cat <<EOF
$(echo -e $(tput setaf 1))
***
Editing /etc/fstab to input UUID for ${device} and adjust settings...
***
$(echo -e $(tput sgr0))
EOF
        sudo bash -c 'cat <<EOF >>/etc/fstab
UUID=${uuid} ${mountpoint} ${fstype} rw,nosuid,dev,noexec,noatime,nodiratime,noauto,x-systemd.automount,nouser,async,nofail 0 2
EOF'
        # adds a necessary line in /etc/fstab
        # noauto and x-systemd.automount options are important so external drive is found properly by docker
        # otherwise docker may cause problems by writing to SD card instead
    fi

    # Create filesystem
    if [[ $fstype =~ 'ext' ]]; then
        sudo mkfs.${fstype} -F -L ${label} ${device} || return 1
    elif [[ $fstype =~ 'xfs' ]]; then
        sudo mkfs.${fstype} -L ${label} ${device} || return 1
    fi

    # Mount filesystem
    cat <<EOF
$(echo -e $(tput setaf 1))
***
echo "Mounting ${device} to ${mountpoint}...
***
$(echo -e $(tput sgr0))
EOF

    sleep 2s
    sudo mount ${device} ${mountpoint} || return 1
    # mount drive to ${mountpoint} directory

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
        sleep 2s
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
        sudo bash -c 'cat <<OEF >>/etc/fstab
${file} swap swap defaults,pri=0 0 0
EOF'
    fi
}
