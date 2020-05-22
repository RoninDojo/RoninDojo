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
cd ${DOJO_PATH}
./dojo.sh stop

echo -e "${RED}"
echo "***"
echo "Removing old Data..."
echo "***"
echo -e "${NC}"
sleep 2s
sudo rm -rf /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/{blocks,chainstate}

echo -e "${RED}"
echo "***"
echo "Copying..."
echo "***"
echo -e "${NC}"
sleep 2s

sudo cp -av /mnt/usb1/system-setup-salvage/{blocks,chainstate} /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/
# copy blockchain data from back up drive to dojo bitcoind data directory, will take a little bit

echo -e "${RED}"
echo "***"
echo "Press any letter to continue..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s
# press to continue is needed because sudo password can be requested for next step, if user is AFK there may be timeout

echo -e "${RED}"
echo "***"
echo "Unmounting..."
echo "***"
echo -e "${NC}"
sleep 2s

sudo umount /mnt/usb1 && sudo rmdir /mnt/usb1

echo -e "${RED}"
echo "***"
echo "You can now safely unplug your backup drive!"
echo "***"
echo -e "${NC}"
sleep 2s


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
