#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if [ -b /dev/sdb1 ]; then
  echo -e "${RED}"
  echo "***"
  echo "Your backup drive partition 1 has been detected..."
  echo "***"
  echo -e "${NC}"
  _sleep 2
  # checks for /dev/sdb1
else
  echo -e "${RED}"
  echo "***"
  echo "No backup drive partition 1 detected! Please make sure it is plugged in and has power if needed."
  echo "***"
  echo -e "${NC}"
  _sleep 5

  echo -e "${RED}"
  echo "***"
  echo "Press any letter to return..."
  echo "***"
  echo -e "${NC}"
  read -n 1 -r -s
  bash ~/RoninDojo/Scripts/Menu/menu-system2.sh
  # no drive detected, press any letter to return to menu
fi

echo -e "${RED}"
echo "***"
echo "Preparing to Mount /dev/sdb1 to ${SALVAGE_MOUNT}..."
echo "***"
echo -e "${NC}"
_sleep 3

echo -e "${RED}"
echo "Are you ready to mount?"
echo -e "${NC}"
while true; do
    read -rp "Y/N?: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) bash ~/RoninDojo/Scripts/Menu/system-menu2.sh;exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
# ask user to proceed

test ! -d "${SALVAGE_MOUNT}" && sudo mkdir "${SALVAGE_MOUNT}"
# create mount directory if not available

echo -e "${RED}"
echo "***"
echo "Mounting /dev/sdb1 to ${SALVAGE_MOUNT}..."
echo "***"
echo -e "${NC}"
_sleep 2
sudo mount /dev/sdb1 "${SALVAGE_MOUNT}"
# mount backup drive to ${SALVAGE_MOUNT} directory

echo -e "${RED}"
echo "***"
echo "Press any letter to return..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s
bash ~/RoninDojo/Scripts/Menu/menu-system2.sh
# press any letter to return to menu-system2.sh
