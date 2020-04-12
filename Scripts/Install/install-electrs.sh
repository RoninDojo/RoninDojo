#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
YELLOW='\033[1;33m'
# used for color with ${YELLOW}
NC='\033[0m'
# No Color


USER=$(sudo grep 1000 /etc/passwd | awk -F: '{ print $1}' | cut -c 1-)

echo -e "${RED}"
echo "***"
echo "Installing Electrs as the Dojo Indexer and running Dojo Upgrade..."
echo "***"
echo -e "${NC}"
sleep 1s

echo -e "${RED}"
echo "***"
echo "Preparing for upgrade to Dojo with Electrs in 10s..."
echo "***"
echo -e "${NC}"
sleep 3s

echo -e "${RED}"
echo "***"
echo "Use Ctrl+C to exit if needed!"
echo "***"
echo -e "${NC}"
sleep 7s

cd ~/dojo/docker/my-dojo
sudo ./dojo.sh stop
sudo chown -R $USER:$USER ~/dojo/*
mkdir ~/.dojo > /dev/null 2>&1
cd ~/.dojo
sudo rm -rf samourai-dojo > /dev/null 2>&1
git clone -b feat_mydojo_local_indexer https://github.com/BTCxZelko/samourai-dojo.git
cp -rv samourai-dojo/* ~/dojo
# stop dojo and prepare for upgrade

echo -e "${RED}"
echo "***"
echo "Installing your Dojo-backed Bitcoin Explorer..."
echo "***"
echo -e "${NC}"
sleep 2s

echo -e "${RED}"
echo "***"
echo "You can find the Username/Password in the Dojo Menu, by using the Tor Hidden Service Address option."
echo "***"
echo -e "${NC}"
sleep 3s

if [ ! -f ~/dojo/docker/my-dojo/conf/docker-explorer.conf ]; then
    EXPLORER_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    sudo sed -i '16i EXPLORER_KEY='$EXPLORER_KEY'' ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl
    sudo sed -i '17d' ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl
else
    echo -e "${RED}"
    echo "***"
    echo "Explorer is already installed!"
    echo "***"
    echo -e "${NC}"
fi

read -p "Do you want to install Electrs? [y/n]" yn
case $yn in
    [Y/y]* ) bash ~/RoninDojo/Scripts/Install/electrs-indexer.sh;;
    [N/n]* ) echo -e "${RED}"
             echo "***"
             echo "Electrs will not be installed!"
             echo "***"
             echo -e "${NC}";;
    * ) echo "Please answer Yes or No.";;
esac
# install indexer

echo "This upgrade will take roughly 1-2 hours."
sleep 1s
echo "After upgrade is complete Electrs needs 8-10 hours to fully sync, compact, etc."
sleep 1s
echo "Begin Countdown to Upgrade..."
sleep 1s
echo "5..."
sleep 1s
echo "4..."
sleep 1s
echo "3..."
sleep 1s
echo "2..."
sleep 1s
echo "1..."
sleep 1s

cd ~/dojo/docker/my-dojo
sudo ./dojo.sh upgrade
# run Upgrade to electrs

bash ~/RoninDojo/ronin
# return to main menu
