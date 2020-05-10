#!/bin/bash

. ~/RoninDojo/Scripts/defaults.sh

echo -e "${RED}"
echo "***"
echo "Upgrading Dojo in 30s..."
echo "***"
echo -e "${NC}"
sleep 3s

echo -e "${RED}"
echo "***"
echo "Use Ctrl+C to exit if needed!"
echo "***"
echo -e "${NC}"
sleep 27s

#cd ~/dojo/docker/my-dojo
cd $DOJO_PATH && sudo ./dojo.sh stop
sudo chown -R $USER:$USER ~/dojo/*
mkdir ~/.dojo > /dev/null 2>&1
cd ~/.dojo
sudo rm -rf samourai-dojo > /dev/null 2>&1
git clone $SAMOURAI_REPO #temporary
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
echo "A randomly generated 16 character password will be created if you haven't already made one."
echo "***"
echo -e "${NC}"
sleep 3s

if [ -f ~/dojo/docker/my-dojo/conf/docker-explorer.conf ] ; then
    echo -e "${RED}"
    echo "***"
    echo "Explorer is already installed!"
    echo "***"
    echo -e "${NC}"
else
    sed -i "s/EXPLORER_KEY=.*$/EXPLORER_KEY=$EXPLORER_KEY/" ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl
fi

if [ ! -f ~/dojo/docker/my-dojo/conf/docker-indexer.conf ] ; then
    read -p "Do you want to install an Indexer? [y/n]" yn
    case $yn in
        [Y/y]* )
                 sudo sed -i 's/INDEXER_INSTALL=off/INDEXER_INSTALL=on/' ~/dojo/docker/my-dojo/conf/docker-indexer.conf.tpl
                 sudo sed -i 's/NODE_ACTIVE_INDEXER=bitcoind/NODE_ACTIVE_INDEXER=local_indexer/' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl
        [N/n]* ) echo -e "${RED}"
                 echo "***"
                 echo "Indexer will not be installed!"
                 echo "***"
                 echo -e "${NC}";;
        * ) echo "Please answer Yes or No.";;
    esac
elif grep "INDEXER_INSTALL=off" ~/dojo/docker/my-dojo/conf/docker-indexer.conf > /dev/null ; then
        read -p "Do you want to install an Indexer? [y/n]" yn
        case $yn in
            [Y/y]* )
                 sudo sed -i 's/INDEXER_INSTALL=off/INDEXER_INSTALL=on/' ~/dojo/docker/my-dojo/conf/docker-indexer.conf
                 sudo sed -i 's/NODE_ACTIVE_INDEXER=bitcoind/NODE_ACTIVE_INDEXER=local_indexer/' ~/dojo/docker/my-dojo/conf/docker-node.conf
            [N/n]* ) echo -e "${RED}"
                     echo "***"
                     echo "Indexer will not be installed!"
                     echo "***"
                     echo -e "${NC}";;
            * ) echo "Please answer Yes or No.";;
        esac
    else
        echo -e "${RED}"
        echo "***"
        echo "Indexer is already installed! If you were running Electrs, press y at next prompt..."
        echo "***"
        echo -e "${NC}"
fi
# install indexer

if [ ! -f ~/dojo/docker/my-dojo/indexer/electrs.toml ] ; then
   read -p "Do you want to install Electrs? [y/n]" yn
   case $yn in
       [Y/y]* ) bash ~/RoninDojo/Scripts/Menu/menu-dojo-electrs-upgrade.sh;;
       [N/n]* ) echo -e "${RED}"
                echo "***"
                echo "Electrs will not be installed!"
                echo "***"
                echo -e "${NC}";;
       * ) echo "Please answer Yes or No.";;
    esac
else
   echo -e "${RED}"
   echo "***"
   echo "Electrs is already installed!"
   echo "***"
   echo -e "${NC}"
   sleep 3s
   bash ~/RoninDojo/Scripts/Menu/menu-dojo-electrs-upgrade.sh
fi
# install electrs

if [ -f /etc/systemd/system/whirlpool.service ] ; then
   sudo systemctl stop whirlpool
   echo -e "${RED}"
   echo "***"
   echo "Whirlpool will be installed via Dojo docker"
   echo "You will need to re-pair with GUI"
   echo "See wiki for more information"
   echo sleep 5s
else
   echo "Whirlpool will be installed via Dojo Docker"
   echo "For pairing information see the wiki"
fi
# stop whirlpool for existing whirlpool users

#cd ~/dojo/docker/my-dojo
cd $DOJO_PATH && sudo ./dojo.sh upgrade
# run upgrade

bash $RONIN_DOJO_MENU
# return to menu
