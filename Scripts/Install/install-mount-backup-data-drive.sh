#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${secondary_storage}" ]; then
    # Make sure /mnt/usb UUID is not same as $secondary_storage
    if [[ $(lsblk -no UUID "$(findmnt -n -o SOURCE --target "${install_dir}")") != $(lsblk -no UUID "${secondary_storage}") ]]; then
        cat <<EOF
${red}
***
Your new backup drive has been detected...
***
${nc}
EOF
        _sleep 2
        # checks for ${secondary_storage}
    else
        cat <<EOF
${red}
***
Possible drive rearrangement occured. Checking if ${primary_storage} is available to format...
***
${nc}
EOF
        # Make sure device does not contain an existing filesystem
        if [ -b "${primary_storage}" ] && [ -n "$(lsblk -no FSTYPE "${primary_storage}")" ]; then
            # Drive got rearranged
            secondary_storage="${primary_storage}"
        elif [ -b "${primary_storage}" ] && [ -z "$(lsblk -no FSTYPE "${primary_storage}")" ]; then
            if ! "${backup_format}"; then
                cat <<EOF
${red}
***
${primary_storage} contains an existing filesystem and cannot be formatted. If you wish to use this drive
for backup purposes. Set backup_format=true in ${HOME}/.config/RoninDojo/user.conf
***
${nc}
EOF
                _pause return

                # press any key to return to menu-system-storage.sh
                bash -c "${ronin_system_storage}"
            else
                secondary_storage="${primary_storage}"
            fi
        fi
    fi
else
    cat <<EOF
${red}
***
No backup drive partition detected! Please make sure it is plugged in and has power if needed...
***
${nc}
EOF
    _sleep 5
    _pause return
    bash -c "${ronin_system_storage}"
    # no drive detected, press any key to return to menu
fi

cat <<EOF
${red}
***
Preparing to Mount ${secondary_storage} to ${storage_mount}...
***
${nc}
EOF
_sleep 3

cat <<EOF
${red}
***
Are you ready to mount?
***
${nc}
EOF

while true; do
    read -rp "[${green}Yes${nc}/${red}No${nc}]: " answer
    case $answer in
        [yY][eE][sS]|[yY]) break;;
        [nN][oO]|[Nn])
          bash "$HOME"/RoninDojo/Scripts/Menu/system-menu2.sh
          exit
          ;;
        *)
          cat <<EOF
${red}
***
Invalid answer! Enter Y or N
***
${nc}
EOF
          ;;
    esac
done
# ask user to proceed

test ! -d "${storage_mount}" && sudo mkdir "${storage_mount}"
# create mount directory if not available

cat <<EOF
${red}
***
Mounting ${secondary_storage} to ${storage_mount}...
***
${nc}
EOF
_sleep 2

sudo mount "${secondary_storage}" "${storage_mount}"
# mount backup drive to ${storage_mount} directory

_pause return
bash -c "${ronin_system_storage}"
# press any key to return to menu-system-storage.sh