#!/bin/bash

. ~/RoninDojo/Scripts/defaults.sh
. ~/RoninDojo/Scripts/functions.sh

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
sleep 2s

echo -e "${RED}"
echo "***"
echo "WARNING: Any pre-existing data on this backup drive will be lost!!!"
echo "***"
echo -e "${NC}"
sleep 2s

echo -e "${RED}"
echo "Are you sure?"
echo -e "${NC}"
while true; do
    read -p "Y/N?: " yn
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
sleep 2s

if [ -b /dev/sdb ]; then
  echo "Found sdb, using wipefs."
  sudo wipefs --all --force /dev/sdb
fi
# if sdb exists, use wipefs to erase wipes partition table

sudo sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk /dev/sdb
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk
    # default, extend partition to end of disk
  w # write the partition table
EOF
# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.

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
sleep 2s
# double-check that /dev/sdb1 exists, and that its storage capacity is what you expected

echo -e "${RED}"
echo "***"
echo "Check output for /dev/sdb1 and make sure everything looks ok."
echo "***"
echo -e "${NC}"
df -h /dev/sdb1
sleep 2s
# checks disk info

create_swap --file /mnt/usb1/swapfile --size 2G
# created a 2GB swapfile on the external backup drive

echo -e "${RED}"
echo "***"
echo "Changing ownership of /mnt/usb1 to $USER:$USER..."
echo "***"
echo -e "${NC}"
sudo chown -R $USER:$USER /mnt/usb1
# use chown to change ownership to $USER [current user]

echo -e "${RED}"
echo "***"
echo "Press any letter to return..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s
bash ~/RoninDojo/Scripts/Menu/menu-system2.sh
# press any letter to return to menu-system2.sh
