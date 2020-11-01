#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${SECONDARY_STORAGE}" ] && findmnt "${STORAGE_MOUNT}"; then
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
No backup drive partition detected and or drive not mounted!
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
Preparing to Umount ${SECONDARY_STORAGE}...
***
${NC}
EOF
_sleep 3

cat <<EOF
${RED}
***
Are you ready to Umount?
***
${NC}
EOF

while true; do
    read -rp "[${GREEN}Yes${NC}/${RED}No${NC}]: "
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

cat <<EOF
${RED}
***
Umounting ${STORAGE_MOUNT}...
***
${NC}
EOF
_sleep 2

sudo umount "${STORAGE_MOUNT}"
# umount backup drive ${SECONDARY_STORAGE}

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