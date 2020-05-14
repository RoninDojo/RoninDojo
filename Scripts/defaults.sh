#
# Terminal Colors
#
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)
# No Color

DOJO_PATH=~/dojo/docker/my-dojo
SAMOURAI_REPO='https://code.samourai.io/ronindojo/samourai-dojo.git'
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
# Dojo Existing Configuration Values
#
if [ -f ${DOJO_PATH}/conf/docker-node.conf ]; then
    NODE_API_KEY_TOR=$(grep NODE_API_KEY ${DOJO_PATH}/conf/docker-node.conf | cut -d '=' -f2)
    NODE_ADMIN_KEY_TOR=$(grep NODE_ADMIN_KEY ${DOJO_PATH}/conf/docker-node.conf | cut -d '=' -f2)
fi

#
# Dojo Docker settings
#

# bitcoind
RPC_PASS=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
RPC_USER=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

if [ -f ${DOJO_PATH}/conf/docker-bitcoind.conf ]; then
    RPC_PASS_CONF=$(grep BITCOIND_RPC_PASSWORD ${DOJO_PATH}/conf/docker-bitcoind.conf | cut -d '=' -f2)
    RPC_USER_CONF=$(grep BITCOIND_RPC_USER ${DOJO_PATH}/conf/docker-bitcoind.conf | cut -d '=' -f2)
fi

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
if [ -f ${DOJO_PATH}/conf/docker-explorer.conf ]; then
    EXPLORER_KEY_TOR=$(grep EXPLORER_KEY ${DOJO_PATH}/conf/docker-explorer.conf | cut -d '=' -f2)
fi
#
# Tor Hidden Service Addresses
#

# Dojo Maintanance Tool
if [ -d /mnt/usb/docker/volumes/my-dojo_data-tor/_data/hsv3dojo ]; then
    V3_ADDR_API=$(sudo cat /mnt/usb/docker/volumes/my-dojo_data-tor/_data/hsv3dojo/hostname)
fi

# Whirlpool
if [ -d /mnt/usb/docker/volumes/my-dojo_data-tor/_data/hsv3whirlpool ]; then
    V3_ADDR_WHIRLPOOL=$(sudo cat /mnt/usb/docker/volumes/my-dojo_data-tor/_data/hsv3whirlpool/hostname)
    WHIRLPOOL_API_KEY=$(sudo grep cli.apiKey /mnt/usb/docker/volumes/my-dojo_data-whirlpool/_data/.whirlpool-cli/whirlpool-cli-config.properties | cut -d '=' -f2)
fi

# Explorer
if [ -d /mnt/usb/docker/volumes/my-dojo_data-tor/_data/hsv3explorer ]; then
    V3_ADDR_EXPLORER=$(sudo cat /mnt/usb/docker/volumes/my-dojo_data-tor/_data/hsv3explorer/hostname)
fi

# Electrum Server
if [ -d /mnt/usb/docker/volumes/my-dojo_data-tor/_data/hsv3electrs ]; then
    V3_ADDR_ELECTRS=$(sudo cat /mnt/usb/docker/volumes/my-dojo_data-tor/_data/hsv3electrs/hostname)
fi

# Ronin menu paths
RONIN_DOJO_MENU='~/RoninDojo/Scripts/Menu/menu-dojo.sh'
RONIN_DOJO_MENU2='~/RoninDojo/Scripts/Menu/menu-dojo2.sh'
RONIN_WHIRLPOOL_MENU='~/RoninDojo/Scripts/Menu/menu-whirlpool.sh'
