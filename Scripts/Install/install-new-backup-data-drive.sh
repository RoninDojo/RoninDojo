#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${SECONDARY_STORAGE}" ]; then
  echo -e "${RED}"
  echo "***"
  echo "Your new backup drive has been detected..."
  echo "***"
  echo -e "${NC}"
  _sleep 2
  # checks for ${SECONDARY_STORAGE}
else
  echo -e "${RED}"
  echo "***"
  echo "No backup drive detected! Please make sure it is plugged in and has power if needed."
  echo "***"
  echo -e "${NC}"
  _sleep 5

  echo -e "${RED}"
  echo "***"
  echo "Press any key to return..."
  echo "***"
  echo -e "${NC}"
  read -n 1 -r -s
  bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh
  # no drive detected, press any letter to return to menu
fi

echo -e "${RED}"
echo "***"
echo "Preparing to Format and Mount ${SECONDARY_STORAGE} to ${STORAGE_MOUNT}..."
echo "***"
echo -e "${NC}"
_sleep 2

echo -e "${RED}"
echo "***"
echo "WARNING: Any pre-existing data on this backup drive will be lost!!!"
echo "***"
echo -e "${NC}"
_sleep 2

echo -e "${RED}"
echo "Are you sure?"
echo -e "${NC}"
while true; do
    read -rp "Y/N?: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh;exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
# ask user to proceed

echo -e "${RED}"
echo "***"
echo "Formatting the Backup Data Drive..."
echo "***"
echo -e "${NC}"
_sleep 2

if ! create_fs --label "backup" --device "${SECONDARY_STORAGE}" --mountpoint "${STORAGE_MOUNT}"; then
  echo -e "${RED}Filesystem creation failed! Exiting${NC}"
  exit
fi
# format partition, see create_fs in functions.sh

echo -e "${RED}"
echo "***"
echo "Displaying the name on the external disk..."
echo "***"
echo -e "${NC}"
lsblk -o NAME,SIZE,LABEL "${SECONDARY_STORAGE}"
_sleep 2
# double-check that "${SECONDARY_STORAGE}" exists, and that its storage capacity is what you expected

echo -e "${RED}"
echo "***"
echo "Check output for ${SECONDARY_STORAGE} and make sure everything looks ok."
echo "***"
echo -e "${NC}"
df -h "${SECONDARY_STORAGE}"
_sleep 2
# checks disk info

echo -e "${RED}"
echo "***"
echo "Press any key to return..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s
bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh
# press any letter to return to menu-system-storage.sh