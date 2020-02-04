#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
YELLOW='\033[1;33m'
# used for color with ${YELLOW}
NC='\033[0m'
# No Color


USER=$(sudo cat /etc/passwd | grep 1000 | awk -F: '{ print $1}' | cut -c 1-)

echo -e "${RED}"
echo "***"
echo "This will install Electrs as the Dojo Indexer and requires a Dojo upgrade"
echo "***"
echo -e "${NC}"
sleep 1s

echo -e "${RED}"
echo "***"
echo "Preparing for upgrade to Dojo with Electrs in 10s..."
echo "Use Ctrl+C to exit if needed!"
echo "***"
echo -e "${NC}"
sleep 10s

# Stop Dojo and prepare for upgrade
cd ~/dojo/docker/my-dojo
sudo ./dojo.sh stop
sudo chown -R $USER:$USER ~/dojo/*
mkdir ~/.dojo > /dev/null 2>&1
cd ~/.dojo
sudo rm -rf samourai-dojo > /dev/null 2>&1
git clone -b feat_mydojo_local_indexer https://github.com/BTCxZelko/samourai-dojo.git
cp -rv samourai-dojo/* ~/dojo

echo -e "${RED}"
echo "Installing your Dojo-backed Bitcoin Explorer"
sleep 1s
echo -e "${YELLOW}"
echo "This password should be something you can remember and is alphanumerical"
sleep 1s
echo -e "${NC}"
if [ ! -f ~/dojo/docker/my-dojo/conf/docker-explorer.conf ]; then
    read -p 'Your Dojo Explorer password: ' EXPLORER_PASS
    sleep 1s
    echo -e "${YELLOW}"
    echo "----------------"
    echo "$EXPLORER_PASS"
    echo "----------------"
    echo -e "${RED}"
    echo "Is this correct?"
    echo -e "${NC}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) read -p 'New Dojo Explorer password: ' EXPLORER_PASS
            echo "$EXPLORER_PASS"
        esac
    done
    echo -e "${RED}"
    echo "$EXPLORER_PASS"
else
    echo "Explorer is already installed"
fi

sed -i '16i EXPLORER_KEY='$EXPLORER_PASS'' ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl
sed -i '17d' ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl

# Install Indexer
read -p "Do you want to install Electrs? [y/n]" yn
case $yn in
    [Y/y]* ) bash ~/RoninDojo/Scripts/Install/electrs-indexer.sh;;
    [N/n]* ) echo "Electrs not installed.";;
    * ) echo "Please answer yes or no.";;
esac

# Upgrade message and countdown
echo "This upgrade will take roughly 1-2 hours"
sleep 1s
echo "After upgrade is complete Electrs takes about 8-10 hours to fully sync and use"
sleep 1s
echo "Upgrading in ...5"
sleep 1s
echo "4..."
sleep 1s
echo "3..."
sleep 1s
echo "2..."
sleep 1s
echo "1..."
sleep 1s

# Run Upgrade to electrs
cd ~/dojo/docker/my-dojo
sudo ./dojo.sh upgrade

# Return to main menu
bash ~/RoninDojo/ronin
