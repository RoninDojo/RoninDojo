#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if [ -b /dev/sdb ]; then
  echo -e "${RED}"
  echo "***"
  echo "Your new backup drive has been detected..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  # checks for /dev/sdb
else
  echo -e "${RED}"
  echo "***"
  echo "No backup drive detected! Please make sure it is plugged in and has power if needed."
  echo "***"
  echo -e "${NC}"
  sleep 5s

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
echo "Preparing to Format and Mount /dev/sdb1 to /mnt/usb1..."
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
        [Nn]* ) bash ~/RoninDojo/Scripts/Menu/menu-system2.sh;exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -e "${RED}"
echo "***"
echo "Formatting the Backup Data Drive..."
echo "***"
echo -e "${NC}"
_sleep 2

if [ -b /dev/sdb ]; then
  echo "Found sdb, using wipefs."
  sudo wipefs --all --force /dev/sdb && sudo sfdisk --delete /dev/sdb &>/dev/null
fi
# if sdb exists, use wipefs to erase wipes partition table

# Create a partition table with a single partition that takes the whole disk
echo 'type=83' | sudo sfdisk /dev/sdb &>/dev/null

if ! create_fs --label "backup" --device "/dev/sdb1" --mountpoint "/mnt/usb1"; then
  echo -e "${RED}Filesystem creation failed! Exiting${NC}"
  exit
fi
# format partition

echo -e "${RED}"
echo "***"
echo "Displaying the name on the external disk..."
echo "***"
echo -e "${NC}"
lsblk -o NAME,SIZE,LABEL /dev/sdb1
_sleep 2
# double-check that /dev/sdb1 exists, and that its storage capacity is what you expected

echo -e "${RED}"
echo "***"
echo "Check output for /dev/sdb1 and make sure everything looks ok."
echo "***"
echo -e "${NC}"
df -h /dev/sdb1
_sleep 2
# checks disk info

create_swap --file /mnt/usb1/swapfile --size 2G
# created a 2GB swapfile on the external backup drive

echo -e "${RED}"
echo "***"
echo "Press any letter to return..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s
bash ~/RoninDojo/Scripts/Menu/menu-system2.sh
# press any letter to return to menu-system2.sh
