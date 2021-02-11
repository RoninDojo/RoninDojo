#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${secondary_storage}" ] && findmnt "${storage_mount}"; then
    cat <<EOF
${RED}
***
Your backup drive partition has been detected...
***
${NC}
EOF
    _sleep 2
    # checks for ${secondary_storage}
else
    cat <<EOF
${RED}
***
No backup drive partition detected and or drive not mounted!
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
Preparing to Umount ${secondary_storage}...
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
    read -rp "[${GREEN}Yes${NC}/${RED}No${NC}]: " answer
    case $answer in
        [yY][eE][sS]|[yY]) break;;
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
Umounting ${storage_mount}...
***
${NC}
EOF
_sleep 2

sudo umount "${storage_mount}"
# umount backup drive ${secondary_storage}

_pause return
bash -c "${ronin_system_storage}"
# press any key to return to menu-system-storage.sh