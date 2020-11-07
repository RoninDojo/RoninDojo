#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${SECONDARY_STORAGE}" ]; then
    cat <<EOF
${RED}
***
Your new backup drive has been detected...
***
${NC}
EOF
    _sleep 2
    # checks for ${SECONDARY_STORAGE}
else
    cat <<EOF
${RED}
***
No backup drive detected! Please make sure it is plugged in and has power if needed.
***
${NC}
EOF
    _sleep 5

    cat <<EOF
${RED}
***
Press any key to return...
***
${NC}
EOF
    _pause

    bash -c "${RONIN_SYSTEM_STORAGE}"
    # no drive detected, press any key to return to menu
fi

cat <<EOF
${RED}
***
Preparing to Format and Mount ${SECONDARY_STORAGE} to ${STORAGE_MOUNT}...
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
          bash -c "${RONIN_SYSTEM_STORAGE}"
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

if ! create_fs --label "backup" --device "${SECONDARY_STORAGE}" --mountpoint "${STORAGE_MOUNT}"; then
    echo -e "${RED}Filesystem creation failed! Exiting${NC}"
    exit
fi
# format partition, see create_fs in functions.sh

cat <<EOF
${RED}
***
Displaying the name on the external disk...
***
${NC}
EOF

lsblk -o NAME,SIZE,LABEL "${SECONDARY_STORAGE}"
_sleep 2
# double-check that "${SECONDARY_STORAGE}" exists, and that its storage capacity is what you expected

cat <<EOF
${RED}
***
Check output for ${SECONDARY_STORAGE} and make sure everything looks ok...
***
${NC}
EOF

df -h "${SECONDARY_STORAGE}"
_sleep 2
# checks disk info

cat <<EOF
${RED}
***
Press any key to return...
***
${NC}
EOF
_pause

bash -c "${RONIN_SYSTEM_STORAGE}"
# press any key to return to menu-system-storage.sh