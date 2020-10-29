#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${SECONDARY_STORAGE}" ]; then
  echo -e "${RED}"
  echo "***"
  echo "Your backup drive partition has been detected..."
  echo "***"
  echo -e "${NC}"
  _sleep 2
  # checks for ${SECONDARY_STORAGE}
else
  echo -e "${RED}"
  echo "***"
  echo "No backup drive partition detected! Please make sure it is plugged in and has power if needed."
  echo "***"
  echo -e "${NC}"
  _sleep 5

  echo -e "${RED}"
  echo "***"
  echo "Press any key to return..."
  echo "***"
  echo -e "${NC}"
  _pause
  bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh
  # no drive detected, press any key to return to menu
fi

echo -e "${RED}"
echo "***"
echo "Preparing to Mount ${SECONDARY_STORAGE} to ${STORAGE_MOUNT}..."
echo "***"
echo -e "${NC}"
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

test ! -d "${STORAGE_MOUNT}" && sudo mkdir "${STORAGE_MOUNT}"
# create mount directory if not available

echo -e "${RED}"
echo "***"
echo "Mounting ${SECONDARY_STORAGE} to ${STORAGE_MOUNT}..."
echo "***"
echo -e "${NC}"
_sleep 2
sudo mount "${SECONDARY_STORAGE}" "${STORAGE_MOUNT}"
# mount backup drive to ${STORAGE_MOUNT} directory

echo -e "${RED}"
echo "***"
echo "Press any key to return..."
echo "***"
echo -e "${NC}"
_pause
bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh
# press any key to return to menu-system-storage.sh