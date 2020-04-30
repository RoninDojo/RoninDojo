#
# Terminal Colors
#
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)
# No Color

#SAMOURAI_REPO='https://code.samourai.io/Ronin/samourai-dojo.git'
SAMOURAI_REPO='https://github.com/BTCxZelko/samourai-dojo.git'
USER=$(getent group 1000 | cut -d ':' -f1)

#
# Dialog variables
#
HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="RoninDojo"
MENU="Choose one of the following options:"

#
# Dojo Docker settings
#

# bitcoind
RPC_PASS=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
RPC_USER=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
RPC_PASS_CONF=(grep BITCOIND_RPC_PASSWORD ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf | cut -d '=' -f2)
RPC_USER_CONF=(grep BITCOIND_RPC_USER ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf | cut -d '=' -f2)

# node
NODE_API_KEY=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)
NODE_JWT_SECRET=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)
NODE_ADMIN_KEY=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

# mysql
MYSQL_ROOT_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)
MYSQL_USER=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 12 | head -n 1)
MYSQL_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

# explorer
EXPLORER_KEY=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 16 | head -n 1)
EXPLORER_KEY_TOR=$(grep EXPLORER_KEY ~/dojo/docker/my-dojo/conf/docker-explorer.conf | cut -d '=' -f2)
# dojo.sh path
DOJO_PATH=$(~/dojo/docker/my-dojo/)

#Tor Hiddenservice
V3_ADDR_API=$(sudo docker exec -it tor cat /var/lib/tor/hsv3dojo/hostname)
NODE_API_KEY_TOR=$(grep NODE_API_KEY ~/dojo/docker/my-dojo/conf/docker-node.conf | cut -d '=' -f2)
NODE_ADMIN_KEY_TOR=$(grep NODE_ADMIN_KEY ~/dojo/docker/my-dojo/conf/docker-node.conf | cut -d '=' -f2)
V3_ADDR_WHIRLPOOL=$(sudo docker exec -it tor cat /var/lib/tor/hsv3whirlpool/hostname)
WHIRLPOOL_API_KEY=$(sudo docker exec -it whirlpool cat /home/whirlpool/.whirlpool-cli/whirlpool-cli-config.properties | grep cli.apiKey= | cut -c 12-)
V3_ADDR_EXPLORER=$(sudo docker exec -it tor cat /var/lib/tor/hsv3explorer/hostname)
V3_ADDR_ELECTRS=$(sudo docker exec -it tor cat /var/lib/tor/hsv3electrs/hostname)


# Ronin menu paths
RONIN_DOJO_MENU=$(~/RoninDojo/Menu/menu-dojo.sh)
RONIN_DOJO_MENU2=$(~/RoninDojo/Menu/menu-dojo2.sh)
RONIN_WHIRLPOOL_MENU=$(~/RoninDojo/Menu/menu-whirlpool.sh)
