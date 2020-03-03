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
echo "Upgrading Dojo in 30s..."
echo "Use Ctrl+C to exit if needed!"
echo "***"
echo -e "${NC}"
sleep 30s
cd ~/dojo/docker/my-dojo
sudo ./dojo.sh stop
sudo chown -R $USER:$USER ~/dojo/*
mkdir ~/.dojo > /dev/null 2>&1
cd ~/.dojo
sudo rm -rf samourai-dojo > /dev/null 2>&1
git clone -b feat_mydojo_local_indexer https://code.samourai.io/BTCxZelko/samourai-dojo.git
cp -rv samourai-dojo/* ~/dojo

echo -e "${RED}"
echo "***"
echo "Installing your Dojo-backed Bitcoin Explorer..."
echo "***"
echo -e "${NC}"
sleep 1s

echo -e "${RED}"
echo "***"
echo "A randomly generated 16 character password will be created if you haven't already made one."
echo "***"
echo -e "${NC}"
sleep 3s

if [ ! -f ~/dojo/docker/my-dojo/conf/docker-explorer.conf ]; then
    EXPLORER_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
else
    echo "Explorer is already installed!"
fi

sed -i '16i EXPLORER_KEY='$EXPLORER_KEY'' ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl
sed -i '17d' ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl

# Install Indexer

if [ ! -f ~/dojo/docker/my-dojo/conf/docker-indexer.conf ]; then
    read -p "Do you want to install an Indexer? [y/n]" yn
    case $yn in
        [Y/y]* ) sudo sed -i '9d' ~/dojo/docker/my-dojo/conf/docker-indexer.conf.tpl; 
                 sudo sed -i '9i INDEXER_INSTALL=on' ~/dojo/docker/my-dojo/conf/docker-indexer.conf.tpl; 
                 sudo sed -i '25d' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl; 
                 sudo sed -i '25i NODE_ACTIVE_INDEXER=local_indexer' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl;;
        [N/n]* ) echo "Indexer will not be installed!";;
        * ) echo "Please answer Yes or No.";;
    esac
else
    echo "Indexer is already installed!"
fi

read -p "Do you want to install Electrs? [y/n]" yn
case $yn in
    [Y/y]* ) bash ~/RoninDojo/Scripts/Menu/menu-dojo-electrs-upgrade.sh;;
    [N/n]* ) echo "Electrs will not be installed!";;
    * ) echo "Please answer Yes or No.";;
esac

# Run upgrade
cd ~/dojo/docker/my-dojo
sudo ./dojo.sh upgrade

# Return to menu
bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
