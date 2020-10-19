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
  echo "Press any letter to return..."
  echo "***"
  echo -e "${NC}"
  read -n 1 -r -s
  bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh
  # no drive detected, press any letter to return to menu
fi

echo -e "${RED}"
echo "***"
echo "Preparing to Mount ${SECONDARY_STORAGE} to ${SECONDARY_STORAGE_MOUNT}..."
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
        [Nn]* ) bash "$HOME"/RoninDojo/Scripts/Menu/system-menu2.sh;exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
# ask user to proceed

test ! -d "${SECONDARY_STORAGE_MOUNT}" && sudo mkdir "${SECONDARY_STORAGE_MOUNT}"
# create mount directory if not available

echo -e "${RED}"
echo "***"
echo "Mounting ${SECONDARY_STORAGE} to ${SECONDARY_STORAGE_MOUNT}..."
echo "***"
echo -e "${NC}"
_sleep 2
sudo mount "${SECONDARY_STORAGE}" "${SECONDARY_STORAGE_MOUNT}"
# mount backup drive to ${SECONDARY_STORAGE_MOUNT} directory

echo -e "${RED}"
echo "***"
echo "Press any letter to return..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s
bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh
# press any letter to return to menu-system-storage.sh