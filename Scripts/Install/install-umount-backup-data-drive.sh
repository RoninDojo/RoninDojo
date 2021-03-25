#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${secondary_storage}" ] && findmnt "${storage_mount}"; then
    cat <<EOF
${red}
***
Your backup drive partition has been detected...
***
${nc}
EOF
    _sleep 1
    # checks for ${secondary_storage}
else
    cat <<EOF
${red}
***
No backup drive partition detected and or drive not mounted!
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
Preparing to Umount ${secondary_storage}...
***
${nc}
EOF
_sleep 3

cat <<EOF
${red}
***
Are you ready to Umount?
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

cat <<EOF
${red}
***
Umounting ${storage_mount}...
***
${nc}
EOF
_sleep 1

sudo umount "${storage_mount}"
# umount backup drive ${secondary_storage}

_pause return
bash -c "${ronin_system_storage}"
# press any key to return to menu-system-storage.sh