#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${SECONDARY_STORAGE}" ]; then
    cat <<EOF
${RED}
***
Your backup drive partition has been detected...
***
${NC}
EOF
  _sleep 2
  # checks for ${SECONDARY_STORAGE}
else
    cat <<EOF
${RED}
***
No backup drive partition detected! Please make sure it is plugged in and has power if needed."
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
Preparing to Mount ${SECONDARY_STORAGE} to ${STORAGE_MOUNT}...
***
${NC}
EOF
_sleep 3

cat <<EOF
${RED}
***
Are you ready to mount? [${GREEN}Yes${NC}/${RED}No${NC}]
***
${NC}
EOF

while true; do
    read -r answer
    case $answer in
        [yY][eE][sS]|[yY]|"") break;;
        [nN][oO]|[Nn])
          bash "$HOME"/RoninDojo/Scripts/Menu/system-menu2.sh
          exit
          ;;
        *)
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

test ! -d "${STORAGE_MOUNT}" && sudo mkdir "${STORAGE_MOUNT}"
# create mount directory if not available

cat <<EOF
${RED}
***
Mounting ${SECONDARY_STORAGE} to ${STORAGE_MOUNT}...
***
${NC}
EOF
_sleep 2

sudo mount "${SECONDARY_STORAGE}" "${STORAGE_MOUNT}"
# mount backup drive to ${STORAGE_MOUNT} directory

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