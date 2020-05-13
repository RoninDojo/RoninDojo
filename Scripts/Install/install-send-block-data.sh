#!/bin/bash

. ~/RoninDojo/Scripts/defaults.sh

echo -e "${RED}"
echo "***"
echo "Preparing to copy data from your Backup Data Drive now..."
echo "***"
echo -e "${NC}"
sleep 3s

echo -e "${RED}"
echo "Have you mounted the Backup Data Drive?"
echo -e "${NC}"
while true; do
    read -p "Y/N?: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh;exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -e "${RED}"
echo "This will take some time, are you sure that you want to do this?"
echo -e "${NC}"
while true; do
    read -p "Y/N?: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh;exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -e "${RED}"
echo "***"
echo "Making sure Dojo is stopped..."
echo "***"
echo -e "${NC}"
sleep 2s
cd ~/dojo/docker/my-dojo/
./dojo.sh stop

echo -e "${RED}"
echo "***"
echo "Copying..."
echo "***"
echo -e "${NC}"
sleep 2s
sudo mkdir /mnt/usb1/system-setup-salvage
sudo cp -a /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/{blocks,chainstate} /mnt/usb1/system-setup-salvage
# copies blockchain data to backup drive while keeping permissions so we can later restore properly

echo -e "${RED}"
echo "***"
echo "Complete!"
echo "***"
echo -e "${NC}"
sleep 2s

echo -e "${RED}"
echo "***"
echo "Press any letter to return..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s
bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh
