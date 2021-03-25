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
        _sleep 1
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
No backup drive detected! Please make sure it is plugged in and has power if needed...
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
Preparing to Format and Mount ${secondary_storage} to ${storage_mount}...
***
${nc}
EOF
_sleep 1

cat <<EOF
${red}
***
WARNING: Any pre-existing data on this backup drive will be lost!
***
${nc}
EOF
_sleep 1

cat <<EOF
${red}
***
Are you sure?
***
${nc}
EOF

while true; do
    read -rp "[${green}Yes${nc}/${red}No${nc}]: " answer
    case $answer in
        [yY][eE][sS]|[yY]) break;;
        [nN][oO]|[Nn])
          bash -c "${ronin_system_storage}"
          exit
          ;;
        * )
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

cat <<EOF
${red}
***
Formatting the Backup Data Drive...
***
${nc}
EOF
_sleep 1

# Check for sgdisk dependency
_check_pkg "sgdisk" "gptfdisk" --update-mirrors

if ! create_fs --label "backup" --device "${secondary_storage}" --mountpoint "${storage_mount}"; then
    printf "\n %sFilesystem creation failed! Exiting now...%s" "${red}" "${nc}"
    _sleep 3
    exit 1
fi
# format partition, see create_fs in functions.sh

cat <<EOF
${red}
***
Displaying the name on the external disk...
***
${nc}
EOF

lsblk -o NAME,SIZE,LABEL "${secondary_storage}"
_sleep 1
# double-check that "${secondary_storage}" exists, and that its storage capacity is what you expected

cat <<EOF
${red}
***
Check output for ${secondary_storage} and make sure everything looks ok...
***
${nc}
EOF

df -h "${secondary_storage}"
_sleep 1
# checks disk info

_pause return
bash -c "${ronin_system_storage}"
# press any key to return to menu-system-storage.sh