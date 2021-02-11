#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${secondary_storage}" ]; then
    cat <<EOF
${RED}
***
Your new backup drive has been detected...
***
${NC}
EOF
    _sleep 2
    # checks for ${secondary_storage}
else
    cat <<EOF
${RED}
***
No backup drive detected! Please make sure it is plugged in and has power if needed.
***
${NC}
EOF
    _sleep 5

    _pause return
    bash -c "${ronin_system_storage}"
    # no drive detected, press any key to return to menu
fi

cat <<EOF
${RED}
***
Preparing to Format and Mount ${secondary_storage} to ${storage_mount}...
***
${NC}
EOF
_sleep 2

cat <<EOF
${RED}
***
WARNING: Any pre-existing data on this backup drive will be lost!
***
${NC}
EOF
_sleep 2

cat <<EOF
${RED}
***
Are you sure?
***
${NC}
EOF

while true; do
    read -rp "[${GREEN}Yes${NC}/${RED}No${NC}]: " answer
    case $answer in
        [yY][eE][sS]|[yY]) break;;
        [nN][oO]|[Nn])
          bash -c "${ronin_system_storage}"
          exit
          ;;
        * )
          cat <<EOF
${RED}
***
Invalid answer! Enter Y or N
***
${NC}
EOF
          ;;
    esac
done
# ask user to proceed

cat <<EOF
${RED}
***
Formatting the Backup Data Drive...
***
${NC}
EOF
_sleep 2

# Check for sgdisk dependency
_check_pkg "sgdisk" "gptfdisk" --update-mirrors

if ! create_fs --label "backup" --device "${secondary_storage}" --mountpoint "${storage_mount}"; then
    printf "\n %sFilesystem creation failed! Exiting now...%s" "${RED}" "${NC}"
    _sleep 3
    exit 1
fi
# format partition, see create_fs in functions.sh

cat <<EOF
${RED}
***
Displaying the name on the external disk...
***
${NC}
EOF

lsblk -o NAME,SIZE,LABEL "${secondary_storage}"
_sleep 2
# double-check that "${secondary_storage}" exists, and that its storage capacity is what you expected

cat <<EOF
${RED}
***
Check output for ${secondary_storage} and make sure everything looks ok...
***
${NC}
EOF

df -h "${secondary_storage}"
_sleep 2
# checks disk info

_pause return
bash -c "${ronin_system_storage}"
# press any key to return to menu-system-storage.sh