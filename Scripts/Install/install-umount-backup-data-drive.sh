#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${SECONDARY_STORAGE}" ] && findmnt "${SECONDARY_STORAGE_MOUNT}"; then
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
  echo "No backup drive partition detected and or drive not mounted!"
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
echo "Preparing to UMount ${SECONDARY_STORAGE}..."
echo "***"
echo -e "${NC}"
_sleep 3

echo -e "${RED}"
echo "Are you ready to umount?"
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

echo -e "${RED}"
echo "***"
echo "Umounting ${SECONDARY_STORAGE_MOUNT}..."
echo "***"
echo -e "${NC}"
_sleep 2
sudo umount "${SECONDARY_STORAGE_MOUNT}"
# umount backup drive ${SECONDARY_STORAGE}

echo -e "${RED}"
echo "***"
echo "Press any letter to return..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s
bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh
# press any letter to return to menu-system-storage.sh