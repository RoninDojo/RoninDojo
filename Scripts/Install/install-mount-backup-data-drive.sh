#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

echo -e "${RED}"
echo "***"
echo "Preparing to Mount /dev/sdb1 to /mnt/usb1..."
echo "***"
echo -e "${NC}"
sleep 3s

echo -e "${RED}"
echo "Have you plugged in your Backup Data Drive?"
echo -e "${NC}"
while true; do
    read -p "Y/N?: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) bash ~/RoninDojo/Scripts/Menu/system-menu2.sh;exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -e "${RED}"
echo "***"
echo "Editing /etc/fstab to input UUID for sdb1 and adjust settings..."
echo "***"
echo -e "${NC}"
sleep 2s

lsblk -o UUID,NAME | grep sdb1 >> ~/uuid.txt
# this will look up uuid of sda1 and makes txt file with that value

sed -i 's/ └─sdb1//g' ~/uuid.txt
# removes the text sdb1 after the uuid in txt file, be aware the text "└─sdb1" can have problems being copy pasted
# └─sdb1 is correct
# └sdb1 is wrong, sometimes certain terminal like debian windows10 subsystem do not copy this correctly and cause problems

sed -i 1's|$| /mnt/usb1 ext4 rw,nosuid,dev,noexec,noatime,nodiratime,noauto,x-systemd.automount,nouser,async,nofail 0 2 &|' ~/uuid.txt
# adds a necessary line with the path and other options after the uuid in txt file
# noauto and x-systemd.automount options are important so external drive is found properly by docker, otherwise docker may cause problems by writing to SD card instead

sed -i 's/^/UUID=/' ~/uuid.txt
# adds UUID= prefix to the front of the line

cat ~/uuid.txt | sudo tee -a /etc/fstab > /dev/null
# even with sudo cant get permission to pipe cat output into /etc/fstab, so using sudo tee -a

rm ~/uuid.txt
# delete txt file

echo -e "${RED}"
echo "***"
echo "Creating /mnt/usb1 directory..."
echo "***"
echo -e "${NC}"
sudo mkdir /mnt/usb1
sleep 2s

echo -e "${RED}"
echo "***"
echo "Mounting /dev/sdb1 to /mnt/usb1..."
echo "***"
echo -e "${NC}"
sleep 2s
sudo mount /dev/sdb1 /mnt/usb1
# mount backup drive to /mnt/usb1 directory

echo -e "${RED}"
echo "***"
echo "Displaying the name on the external disk..."
echo "***"
echo -e "${NC}"
lsblk -o UUID,NAME,FSTYPE,SIZE,LABEL,MODEL
sleep 2s
# double-check that /dev/sdb exists, and that its storage capacity is what you expected

echo -e "${RED}"
echo "***"
echo "Check output for /dev/sdb1 and make sure everything looks ok."
echo "***"
echo -e "${NC}"
df -h
sleep 2s
# checks disk info

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
