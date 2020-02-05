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
echo "Running Dojo install in 30s..."
echo "***"
echo -e "${NC}"
sleep 3s

echo -e "${RED}"
echo "***"
echo "If you have already installed Dojo on your system, use Ctrl+C to exit now!"
echo "***"
echo -e "${NC}"
sleep 10s

echo -e "${RED}"
echo "***"
echo "WARNING: You might bork your system if you have already installed Dojo!!!"
echo "***"
echo -e "${NC}"
sleep 10s

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
echo "Downloading and extracting latest Ronin release."
echo "***"
echo -e "${NC}"
cd ~
sleep 5s
mkdir ~/.dojo
cd ~/.dojo
git clone -b feat_mydojo_local_indexer https://github.com/BTCxZelko/samourai-dojo.git
sleep 2s

echo -e "${RED}"
echo "***"
echo "Making ~/dojo and copying data."
echo "***"
echo -e "${NC}"
sleep 2s
mkdir ~/dojo
cp -rv samourai-dojo/* ~/dojo
sleep 2s

echo -e "${RED}"
echo "***"
echo "Removing all the files no longer needed."
echo "***"
echo -e "${NC}"
sleep 2s
rm -rvf samourai-dojo/
sleep 1s

 # creating a 1GB swapfile
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo sed -i '20i /swapfile none swap defaults 0 0' /etc/fstab

echo -e "${RED}"
echo "***"
echo "Configure your Dojo .conf.tpl files when prompted."
echo "***"
echo -e "${NC}"
sleep 3s
#RPC Configuration at dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl

echo -e "${RED}"
echo "****"
echo "An automatically generated random 32 character value will generate for RPC Password."
echo "This can be accessed in the the conf folders at any time."
echo "***"
sleep 1s
echo "Setting the RPC User and Password now."
echo "***"
echo -e "${NC}"
sleep 1s

#RPC Configuration at dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl
RPC_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Create new docker bitcoind conf file
rm -rf ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl

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

#Password Configuration that will be used to access DOJO MAINTENANCE TOOL at dojo/docker/my-dojo/conf/docker-node.conf.tpl
echo -e "${RED}"
echo "****"
echo "Setting the Node API Key and JWT Secret now..."
echo "***"
echo -e "${NC}"
sleep 2s

echo -e "${RED}"
echo "***"
echo "NOTICE:"
echo "An automatically generated random 64 character value will generate for both."
echo "These can be accessed in the the conf folders at any time."
echo "***"
sleep 2s
echo -e "${NC}"

# Create random set of 64 characters for API KEY and JWT Secret
NODE_API_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
NODE_JWT_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)

# Create random set of 32 characters for Node Admin Key
echo -e "${RED}"
echo "***"
echo "NOTICE:"
echo "The Node Admin Key is the password you will enter in the Maintenance Tool."
echo "A randomly generated 32 character password will be created."
echo "You can find this password in Dojo Menu Tor Onion option"
echo "***"
echo -e "${NC}"
sleep 5s

NODE_ADMIN_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

sleep 1s

# Create new docker node conf file
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

#MYSQL User and Password Configuration at dojo/docker/my-dojo/conf/docker-mysql.conf.tpl
# Create new mysql conf file
rm -rf ~/dojo/docker/my-dojo/conf/docker-mysql.conf.tpl

# Create random 64 character password and username for MYSQL 
MYSQL_ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
MYSQL_USER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
MYSQL_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)

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

# BTC-EXPLORER PASSWORD
echo -e "${RED}"
echo "Installing your Dojo-backed Bitcoin Explorer"
sleep 1s
echo -e "${YELLOW}"
echo "A randomly generated 16 character password will be generated."
echo "You can find this password in the Dojo Tor Onion option"
sleep 1s
echo -e "${NC}"
if [ ! -f ~/dojo/docker/my-dojo/conf/docker-explorer.conf ]; then
    EXPLORER_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    sleep 1s
else
    echo "Explorer is already installed"
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
sleep 1s

echo -e "${RED}"
echo "***"
echo "See documentation at https://github.com/RoninDojo/RoninDojo/wiki"
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
