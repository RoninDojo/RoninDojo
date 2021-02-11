#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${secondary_storage}" ]; then
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
No backup drive partition detected! Please make sure it is plugged in and has power if needed."
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
Preparing to Mount ${secondary_storage} to ${storage_mount}...
***
${NC}
EOF
_sleep 3

cat <<EOF
${RED}
***
Are you ready to mount?
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

test ! -d "${storage_mount}" && sudo mkdir "${storage_mount}"
# create mount directory if not available

cat <<EOF
${RED}
***
Mounting ${secondary_storage} to ${storage_mount}...
***
${NC}
EOF
_sleep 2

sudo mount "${secondary_storage}" "${storage_mount}"
# mount backup drive to ${storage_mount} directory

_pause return
bash -c "${ronin_system_storage}"
# press any key to return to menu-system-storage.sh