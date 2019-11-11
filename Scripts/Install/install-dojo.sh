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
echo "Downloading and extracting latest Dojo release."
echo "***"
echo -e "${NC}"
cd ~
sleep 5s
curl -fsSL https://github.com/Samourai-Wallet/samourai-dojo/archive/master.zip -o master.zip
unzip master.zip
sleep 2s

echo -e "${RED}"
echo "***"
echo "Making ~/dojo and copying data."
echo "***"
echo -e "${NC}"
sleep 2s
mkdir ~/dojo
cp -rv samourai-dojo-master/* ~/dojo
sleep 2s

echo -e "${RED}"
echo "***"
echo "Removing all the files no longer needed."
echo "***"
echo -e "${NC}"
sleep 2s
rm -rvf samourai-dojo-master/ master.zip

echo -e "${RED}"
echo "***"
echo "Editing the bitcoin docker file, using the aarch64-linux-gnu.tar.gz source."
echo "***"
echo -e "${NC}"
sed -i '9d' ~/dojo/docker/my-dojo/bitcoin/Dockerfile
sed -i '9i             ENV     BITCOIN_URL         https://bitcoincore.org/bin/bitcoin-core-0.18.1/bitcoin-0.18.1-aarch64-linux-gnu.tar.gz' ~/dojo/docker/my-dojo/bitcoin/Dockerfile
sed -i '10d' ~/dojo/docker/my-dojo/bitcoin/Dockerfile
sed -i '10i             ENV     BITCOIN_SHA256      88f343af72803b851c7da13874cc5525026b0b55e63e1b5e1298390c4688adc6' ~/dojo/docker/my-dojo/bitcoin/Dockerfile
sleep 2s
# method used with the sed command is to delete entire lines 9, 10 and add new lines 9, 10
# double check ~/dojo_dir/docker/my-dojo/bitcoin/Dockerfile

echo -e "${RED}"
echo "***"
echo "Editing mysql dockerfile to use a compatible database."
echo "***"
echo -e "${NC}"
sed -i '1d' ~/dojo/docker/my-dojo/mysql/Dockerfile
sed -i '1i             FROM    mariadb:latest' ~/dojo/docker/my-dojo/mysql/Dockerfile
sleep 2s
# method used with the sed command is to delete line 1 and add new line 1
# double check ~/dojo_dir/docker/my-dojo/mysql/Dockerfile

echo -e "${RED}"
echo "***"
echo "Configure your Dojo .conf.tpl files when prompted."
echo "***"
echo -e "${NC}"
sleep 3s
#RPC Configuration at dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl

echo -e "${RED}"
echo "***"
echo "Set your RPC Username and Password now..."
echo "***"
echo -e "${NC}"
sleep 3s

echo -e "${RED}"
echo "***"
echo "NOTICE:"
echo "Use alphanumerical value only! No special characters such as (*&^%$#@!)."
echo "Be sure that you record all of this information! Store it in a safe place you will not forget."
echo "***"
echo -e "${NC}"
sleep 5s

read -p 'RPC Username: ' RPC_USER
# get user input for rpc username

echo -e "${YELLOW}"
echo "----------------"
echo     "$RPC_USER"
echo "----------------"
echo -e "${RED}"
echo "Is this correct?"
echo -e "${NC}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) read -p 'New RPC Username: ' RPC_USER
            echo "$RPC_USER"
    esac
done
sed -i '7d' ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl
sed -i '7i BITCOIN_RPC_USER='$RPC_USER'' ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl
# uses sed to edit .conf.tpl file with user input value

read -p 'RPC Password: ' RPC_PASS
# get user input for rpc password

echo -e "${YELLOW}"
echo "----------------"
echo     "$RPC_PASS"
echo "----------------"
echo -e "${RED}"
echo "Is this correct?"
echo -e "${NC}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) read -p 'New Dojo RPC Password: ' RPC_PASS
            echo "$RPC_PASS"
    esac
done
sed -i '11d' ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl
sed -i '11i BITCOIND_RPC_PASS='$RPC_PASS'' ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl
# uses sed to edit .conf.tpl file with user input value

#NODE Configuration at dojo/docker/my-dojo/conf/docker-node.conf.tpl
echo -e "${RED}"
echo "***"
echo "Set your Node API Key now..."
echo "***"
echo -e "${NC}"
sleep 5s

echo -e "${RED}"
echo "***"
echo "NOTICE:"
echo "Enter any value that you want."
echo "Use alphanumerical value only! No special characters such as (*&^%$#@!)."
echo "Be sure that you record all of this information! Store it in a safe place you will not forget."
echo "***"
echo -e "${NC}"
sleep 5s

read -p 'Enter Node API Key for interacting with Wallet and Sentinel: ' NODE_API_KEY
# get user input for node api key

echo -e "${YELLOW}"
echo "----------------"
echo    "$NODE_API_KEY"
echo "----------------"
echo -e "${RED}"
echo "Is this correct?"
echo -e "${NC}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) read -p 'New Node API Key: ' NODE_API_KEY
            echo "$NODE_API_KEY"
    esac
done
sed -i '9d' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl
sed -i '9i NODE_API_KEY='$NODE_API_KEY'' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl
sleep 2s
#Password Configuration that will be used to access DOJO MAINTENANCE TOOL at dojo/docker/my-dojo/conf/docker-node.conf.tpl

echo -e "${RED}"
echo "****"
echo "Set the Node Admin Key now..."
echo "***"
echo -e "${NC}"
sleep 3s

echo -e "${RED}"
echo "***"
echo "NOTICE:"
echo "Enter any value that you want."
echo "The Node Admin Key is the password you will enter in the Maintenance Tool."
echo "Use alphanumerical value only! No special characters such as (*&^%$#@!)."
echo "Be sure that you record all of this information! Store it in a safe place you will not forget."
echo "***"
echo -e "${NC}"
sleep 5s

read -p 'Enter Node Admin Key for accessing Dojo Maintenance Tool: ' NODE_ADMIN_KEY

echo -e "${YELLOW}"
echo "----------------"
echo    "$NODE_ADMIN_KEY"
echo "----------------"
echo -e "${RED}"
echo "Is this correct?"
echo -e "${NC}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) read -p 'New Node Admin Key: ' NODE_ADMIN_KEY
            echo "$NODE_ADMIN_KEY"
    esac
done
sed -i '15d' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl
sed -i '15i NODE_ADMIN_KEY='$NODE_ADMIN_KEY'' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl

echo -e "${RED}"
echo "****"
echo "Enter any value you prefer for JWT Secret Key now..."
echo "***"
echo -e "${NC}"
sleep 3s

echo -e "${RED}"
echo "***"
echo "NOTICE:"
echo "Enter any value that you want."
echo "Node JWT Secret Key is used to sign cyrptographic key signing Json Web Tokens."
echo "Use alphanumerical value only! No special characters such as (*&^%$#@!)."
echo "Be sure that you record all of this information! Store it in a safe place you will not forget."
echo "***"
echo -e "${NC}"
sleep 5s

read -p 'Enter the Node JWT Secret Key, use HIGH ENTROPY: ' NODE_JWT_SECRET

echo -e "${YELLOW}"
echo "----------------"
echo    "$NODE_JWT_SECRET"
echo "----------------"
echo -e "${RED}"
echo "Is this correct?"
echo -e "${NC}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) read -p 'New Node JWT Secret: ' NODE_ADMIN_KEY
            echo "$NODE_JWT_SECRET"
    esac
done
sed -i '21d' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl
sed -i '21i NODE_JWT_SECRET='$NODE_JWT_SECRET'' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl
sleep 2s

#MYSQL User and Password Configuration at dojo/docker/my-dojo/conf/docker-mysql.conf.tpl
echo -e "${RED}"
echo "***"
echo "Enter your MYSQL root account password, MYSQL db User, and MYSQL db Password now..."
echo "***"
echo -e "${NC}"
sleep 5s

echo -e "${RED}"
echo "***"
echo "NOTICE:"
echo "Enter any value that you want."
echo "This will protect MYSQL database and provide login information for Dojo DB."
echo "Use alphanumerical value only! No special characters such as (*&^%$#@!)."
echo "Be sure that you record all of this information! Store it in a safe place you will not forget."
echo "***"
echo -e "${NC}"
sleep 5s

read -p 'MYSQL root password: ' MYSQL_ROOT_PASSWORD

echo -e "${YELLOW}"
echo "----------------"
echo    "$MYSQL_ROOT_PASSWORD"
echo "----------------"
echo -e "${RED}"
echo "Is this correct?"
echo -e "${NC}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) read -p 'New MYSQL Root Password: ' MYSQL_ROOT_PASSWORD
            echo "$MYSQL_ROOT_PASSWORD"
    esac
done
sed -i '7d' ~/dojo/docker/my-dojo/conf/docker-mysql.conf.tpl
sed -i '7i MYSQL_ROOT_PASSWORD='$MYSQL_ROOT_PASSWORD'' ~/dojo/docker/my-dojo/conf/docker-mysql.conf.tpl

read -p 'MYSQL db Username: ' MYSQL_USER

echo -e "${YELLOW}"
echo "----------------"
echo    "$MYSQL_USER"
echo "----------------"
echo -e "${RED}"
echo "Is this correct?"
echo -e "${NC}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) read -p 'New MYSQL DB Username: ' MYSQL_USER
            echo "$MYSQL_USER"
    esac
done
sed -i '11d' ~/dojo/docker/my-dojo/conf/docker-mysql.conf.tpl
sed -i '11i MYSQL_USER='$MYSQL_USER'' ~/dojo/docker/my-dojo/conf/docker-mysql.conf.tpl

read -p 'MYSQL DB Password: ' MYSQL_PASSWORD

echo -e "${YELLOW}"
echo "----------------"
echo    "$MYSQL_PASSWORD"
echo "----------------"
echo -e "${RED}"
echo "Is this correct?"
echo -e "${NC}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) read -p 'New MYSQL DB Password: ' MYSQL_PASSWORD
            echo "$MYSQL_PASSWORD"
    esac
done
sed -i '15d' ~/dojo/docker/my-dojo/conf/docker-mysql.conf.tpl
sed -i '15i MYSQL_PASSWORD='$MYSQL_PASSWORD'' ~/dojo/docker/my-dojo/conf/docker-mysql.conf.tpl

echo -e "${RED}"
echo "Configuration is complete!"
sleep 3s
echo "See documentation at https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_setup.md"
sleep 10s
# end dojo setup
