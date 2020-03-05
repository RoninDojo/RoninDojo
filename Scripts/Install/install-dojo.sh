#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
YELLOW='\033[1;33m'
# used for color with ${YELLOW}
NC='\033[0m'
# No Color

# start of warning
echo -e "${RED}"
echo "***"
echo "Running Dojo install in 15s..."
echo "***"
echo -e "${NC}"
sleep 5s

echo -e "${RED}"
echo "***"
echo "If you have already installed Dojo on your system, use Ctrl+C to exit now!"
echo "***"
echo -e "${NC}"
sleep 5s

echo -e "${RED}"
echo "***"
echo "If you are a new user sit back, relax, and enjoy."
echo "***"
echo -e "${NC}"
sleep 5s
# end of warning

# start dojo setup
echo -e "${RED}"
echo "***"
echo "Downloading and extracting latest RoninDojo release..."
echo "***"
echo -e "${NC}"
cd ~
git clone -b feat_mydojo_local_indexer https://code.samourai.io/BTCxZelko/samourai-dojo.git # CHANGE

echo -e "${RED}"
echo "***"
echo "Making ~/dojo and copying data."
echo "***"
echo -e "${NC}"
sleep 2s
mkdir ~/dojo
cp -r samourai-dojo/* ~/dojo
sleep 2s

echo -e "${RED}"
echo "***"
echo "Removing all the files no longer needed."
echo "***"
echo -e "${NC}"
sleep 2s
rm -rf samourai-dojo/
sleep 1s

echo -e "${RED}"
echo "***"
echo "Setting the RPC User and Password..."
echo "***"
echo -e "${NC}"
sleep 1s

echo -e "${RED}"
echo "***"
echo "NOTICE:"
echo "Randomly generated 32 character value is used, and can be found in Dojo conf directory."
echo "***"
echo -e "${NC}"
sleep 3s

RPC_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
#RPC Configuration at dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl

rm -rf ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl
# Create new docker bitcoind conf file

echo "
#########################################
# CONFIGURATION OF BITCOIND CONTAINER
#########################################
# User account used for rpc access to bitcoind
# Type: alphanumeric
BITCOIND_RPC_USER=RoninDojo
# Password of user account used for rpc access to bitcoind
# Type: alphanumeric
BITCOIND_RPC_PASSWORD=$RPC_PASS
# Max number of connections to network peers
# Type: integer
BITCOIND_MAX_CONNECTIONS=16
# Mempool maximum size in MB
# Type: integer
BITCOIND_MAX_MEMPOOL=400
# Db cache size in MB
# Type: integer
BITCOIND_DB_CACHE=700
# Number of threads to service RPC calls
# Type: integer
BITCOIND_RPC_THREADS=6
# Mempool expiry in hours
# Defines how long transactions stay in your local mempool before expiring
# Type: integer
BITCOIND_MEMPOOL_EXPIRY=72
# Min relay tx fee in BTC
# Type: numeric
BITCOIND_MIN_RELAY_TX_FEE=0.00001
#
# EXPERT SETTINGS
#
#
# EPHEMERAL ONION ADDRESS FOR BITCOIND
# THIS PARAMETER HAS NO EFFECT IF BITCOIND_INSTALL IS SET TO OFF
#
# Generate a new onion address for bitcoind when Dojo is launched
# Activation of this option is recommended for improved privacy.
# Values: on | off
BITCOIND_EPHEMERAL_HS=on
#
# EXPOSE BITCOIND RPC API AND ZMQ NOTIFICATIONS TO EXTERNAL APPS
# THESE PARAMETERS HAVE NO EFFECT IF BITCOIND_INSTALL IS SET TO OFF
#
# Expose the RPC API to external apps
# Warning: Do not expose your RPC API to internet!
# See BITCOIND_RPC_EXTERNAL_IP
# Value: on | off
BITCOIND_RPC_EXTERNAL=off
# IP address used to expose the RPC API to external apps
# This parameter is inactive if BITCOIND_RPC_EXTERNAL isn't set to 'on'
# Warning: Do not expose your RPC API to internet!
# Recommended value:
#   linux: 127.0.0.1
#   macos or windows: IP address of the VM running the docker host
# Type: string
BITCOIND_RPC_EXTERNAL_IP=127.0.0.1
#
# INSTALL AND RUN BITCOIND INSIDE DOCKER
#
# Install and run bitcoind inside Docker
# Set this option to 'off' for using a bitcoind hosted outside of Docker (not recommended)
# Value: on | off
BITCOIND_INSTALL=on
# IP address of bitcoind used by Dojo
# Set value to 172.28.1.5 if BITCOIND_INSTALL is set to 'on'
# Type: string
BITCOIND_IP=172.28.1.5
# Port of the RPC API
# Set value to 28256 if BITCOIND_INSTALL is set to 'on'
# Type: integer
BITCOIND_RPC_PORT=28256
# Port exposing ZMQ notifications for raw transactions
# Set value to 9501 if BITCOIND_INSTALL is set to 'on'
# Type: integer
BITCOIND_ZMQ_RAWTXS=9501
# Port exposing ZMQ notifications for block hashes
# Set value to 9502 if BITCOIND_INSTALL is set to 'on'
# Type: integer
BITCOIND_ZMQ_BLK_HASH=9502
" | sudo tee -a ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl

# configuring ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl
echo -e "${RED}"
echo "****"
echo "Setting the Node API Key and JWT Secret..."
echo "***"
echo -e "${NC}"
sleep 1s

echo -e "${RED}"
echo "***"
echo "NOTICE:"
echo "Randomly generated 64 character value is used, and can be found in Dojo conf directory."
echo "***"
sleep 2s
echo -e "${NC}"

NODE_API_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
NODE_JWT_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
# Create random set of 64 characters for API KEY and JWT Secret

echo -e "${RED}"
echo "****"
echo "Setting the Node Admin Key..."
echo "***"
echo -e "${NC}"
sleep 1s

echo -e "${RED}"
echo "****"
echo "The Node Admin Key is password used to enter the Dojo Maintenance Tool."
echo "***"
sleep 3s
echo -e "${NC}"

echo -e "${RED}"
echo "***"
echo "NOTICE:"
echo "See randomly generated 32 character password in Dojo Menu by using Tor Hidden Service Address option."
echo "***"
echo -e "${NC}"
sleep 5s

NODE_ADMIN_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
# Create random set of 32 characters for Node Admin Key

rm -rf ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl

echo "
#########################################
# CONFIGURATION OF NODE JS CONTAINER
#########################################
# API key required for accessing the services provided by the server
# Keep this API key secret!
# Provide a value with a high entropy!
# Type: alphanumeric
NODE_API_KEY=$NODE_API_KEY

# API key required for accessing the admin/maintenance services provided by the server
# Keep this Admin key secret!
# Provide a value with a high entropy!
# Type: alphanumeric
NODE_ADMIN_KEY=$NODE_ADMIN_KEY

# Secret used by the server for signing Json Web Token
# Keep this value secret!
# Provide a value with a high entropy!
# Type: alphanumeric
NODE_JWT_SECRET=$NODE_JWT_SECRET

# Indexer or third-party service used for imports and rescans of addresses
# Values: local_bitcoind | third_party_explorer
NODE_ACTIVE_INDEXER=local_bitcoind

# FEE TYPE USED FOR FEES ESTIMATIONS BY BITCOIND
# Allowed values are ECONOMICAL or CONSERVATIVE
NODE_FEE_TYPE=ECONOMICAL
" | sudo tee -a ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl
# Create new docker node conf file 

rm -rf ~/dojo/docker/my-dojo/conf/docker-mysql.conf.tpl

MYSQL_ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
MYSQL_USER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
MYSQL_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
# Create random 64 character password and username for MYSQL 
#MYSQL User and Password Configuration at dojo/docker/my-dojo/conf/docker-mysql.conf.tpl

echo "
#########################################
# CONFIGURATION OF MYSQL CONTAINER
#########################################
# Password of MySql root account
# Type: alphanumeric
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
# User account used for db access
# Type: alphanumeric
MYSQL_USER=$MYSQL_USER
# Password of of user account
# Type: alphanumeric
MYSQL_PASSWORD=$MYSQL_PASSWORD
" | sudo tee -a ~/dojo/docker/my-dojo/conf/docker-mysql.conf.tpl
# Create new mysql conf file

# BTC-EXPLORER PASSWORD
echo -e "${RED}"
echo "***"
echo "Installing your Dojo-backed Bitcoin Explorer..."
echo "***"
echo -e "${NC}"
sleep 1s

echo -e "${RED}"
echo "***"
echo "This is a fully functioning Bitcoin Blockchain Explorer in a Web Browser."
echo "***"
echo -e "${NC}"
sleep 3s

echo -e "${RED}"
echo "***"
echo "NOTICE:"
echo "See randomly generated 16 character password in Dojo Menu by using Tor Hidden Service Address option."
echo "***"
echo -e "${NC}"
sleep 5s

if [ ! -f ~/dojo/docker/my-dojo/conf/docker-explorer.conf ]; then
    EXPLORER_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    sleep 1s
else
    echo "Explorer is already installed!"
fi

rm -rf ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl
echo "
#########################################
# CONFIGURATION OF EXPLORER CONTAINER
#########################################
# Install and run a block explorer inside Dojo (recommended)
# Value: on | off
EXPLORER_INSTALL=on
# Password required for accessing the block explorer
# (login can be anything)
# Keep this password secret!
# Provide a value with a high entropy!
# Type: alphanumeric
EXPLORER_KEY=$EXPLORER_KEY
" | sudo tee -a ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl
# Create new explorer conf file

# Install Indexer

if [ ! -f ~/dojo/docker/my-dojo/conf/docker-indexer.conf ]; then
    read -p "Do you want to install an indexer? [y/n]" yn
    case $yn in
        [Y/y]* ) sudo sed -i '9d' ~/dojo/docker/my-dojo/conf/docker-indexer.conf.tpl; sudo sed -i '9i INDEXER_INSTALL=on' ~/dojo/docker/my-dojo/conf/docker-indexer.conf.tpl; sudo sed -i '25d' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl; sudo sed -i '25i NODE_ACTIVE_INDEXER=local_indexer' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl;;
        [N/n]* ) echo "Indexer will not be installed!";;
        * ) echo "Please answer Yes or No.";;
    esac
else
    echo "Indexer is already installed!"
fi

read -p "Do you want to install Electrs? [y/n]" yn
case $yn in
    [Y/y]* ) bash ~/RoninDojo/Scripts/Install/install-electrs-indexer.sh;;
    [N/n]* ) echo "Electrs will not be installed!";;
    * ) echo "Please answer Yes or No.";;
esac

echo -e "${RED}"
echo "***"
echo "See documentation at https://code.samourai.io/ronindojo/RoninDojo/-/wikis/home"
echo "***"
echo -e "${NC}"
sleep 5s
# end dojo setup

echo -e "${RED}"
echo "***"
echo "Installing Dojo..."
echo "***"
echo -e "${NC}"
sleep 2s
cd ~/dojo/docker/my-dojo
sudo ./dojo.sh install
# once dojo install reaches bitcoind logs / begins syncing then use Ctrl + C to exit and trigger the salvage attempt below

if ls /mnt/usb | grep uninstall-salvage > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Blockchain data salvage starting..."
  echo "***"
  echo -e "${NC}"
  sleep 2s

  echo -e "${RED}"
  echo "***"
  echo "Press any letter to continue..."
  echo "***"
  echo -e "${NC}"
  read -n 1 -r -s
  # press to continue is needed because sudo password can be requested for next steps, if user is AFK there may be timeout
  cd ~/dojo/docker/my-dojo
  sudo ./dojo.sh stop
  sudo rm -rf /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/chainstate
  sudo rm -rf /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/blocks
  sudo mv -v /mnt/usb/uninstall-salvage/chainstate /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/
  sudo mv -v /mnt/usb/uninstall-salvage/blocks /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/
  echo -e "${RED}"
  echo "***"
  echo "Blockchain data salvage complete!"
  echo "***"
  echo -e "${NC}"
  sleep 3s
  sudo rm -rf /mnt/usb/uninstall-salvage/chainstate
  sudo rm -rf /mnt/usb/uninstall-salvage/blocks
  sudo chown -R 1105:1108 /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/
  sudo chmod 700 /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/chainstate
  sudo chmod 700 /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/blocks
  sudo rm -rf /mnt/usb/uninstall-salvage/
  sudo rm -rf /mnt/usb/system-setup-salvage/
  sudo sudo ./dojo.sh start
else
  echo "No Blockchain data found for salvage check 1..."
fi
# check for uninstall-salvage, if not found continue

if ls /mnt/usb | grep system-setup-salvage > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Blockchain data salvage starting..."
  echo "***"
  echo -e "${NC}"
  sleep 2s

  echo -e "${RED}"
  echo "***"
  echo "Press any letter to continue..."
  echo "***"
  echo -e "${NC}"
  read -n 1 -r -s
  cd ~/dojo/docker/my-dojo
  sudo ./dojo.sh stop
  sudo rm -rf /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/chainstate
  sudo rm -rf /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/blocks
  sudo mv -v /mnt/usb/system-setup-salvage/chainstate /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/
  sudo mv -v /mnt/usb/system-setup-salvage/blocks /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/
  echo -e "${RED}"
  echo "***"
  echo "Blockchain data salvage complete!"
  echo "***"
  echo -e "${NC}"
  sleep 3s
  sudo rm -rf /mnt/usb/system-setup-salvage/chainstate
  sudo rm -rf /mnt/usb/system-setup-salvage/blocks
  sudo chown -R 1105:1108 /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/
  sudo chmod 700 /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/chainstate
  sudo chmod 700 /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/blocks
  sudo rm -rf /mnt/usb/system-setup-salvage/
  sudo rm -rf /mnt/usb/uninstall-salvage/
  sudo sudo ./dojo.sh start
else
  echo "No Blockchain data found for salvage check 2..."
fi
# check for system-setup-salvage, if not found continue

echo -e "${RED}"
echo "***"
echo "Whirlpool is ready to be installed!"
echo "***"
echo -e "${NC}"
sleep 3s
# will continue to whirlpool install, if it was selected from the install menu
