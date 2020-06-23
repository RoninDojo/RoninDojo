#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

# Temporaly directory location
WORK_DIR=$(mktemp -d)

# Check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
    echo -e "${RED}"
    echo "****"
    echo "Could not create temp dir, upgrade failed!"
    echo "***"
    echo -e "${NOC}"
    exit 1
fi

echo -e "${RED}"
echo "***"
echo "Upgrading Dojo in 30s..."
echo "***"
echo -e "${NC}"
_sleep 3

echo -e "${RED}"
echo "***"
echo "Use Ctrl+C to exit if needed!"
echo "***"
echo -e "${NC}"
_sleep 27

# Make sure permissions are properly set for ${DOJO_PATH}
cd "${DOJO_PATH}" || exit
_check_dojo_perms "${DOJO_PATH}"

# Enable BITCOIND_RPC_EXTERNAL
if grep BITCOIND_RPC_EXTERNAL=off "${DOJO_PATH}"/conf/docker-bitcoind.conf 1>/dev/null; then
    sed -i 's/BITCOIND_RPC_EXTERNAL=off/BITCOIND_RPC_EXTERNAL=on/' "${DOJO_PATH}"/conf/docker-bitcoind.conf
fi

cd "${WORK_DIR}" || exit
git clone -b master "$SAMOURAI_REPO" # temporary

# Copy only when the SOURCE file is newer than the
# destination file or when the destination file is missing
# and keep all permissions

cp -ua samourai-dojo/* "$HOME"/dojo/

# Remove $WORK_DIR
rm -rf "${WORK_DIR}"

# Return to previous working path
cd - || exit

# Stop dojo and prepare for upgrade

echo -e "${RED}"
echo "***"
echo "Installing your Dojo-backed Bitcoin Explorer..."
echo "***"
echo -e "${NC}"
_sleep 2

echo -e "${RED}"
echo "***"
echo "A randomly generated 16 character password will be created if you haven't already made one."
echo "***"
echo -e "${NC}"
_sleep 3

if [ -f "${DOJO_PATH}"/conf/docker-explorer.conf ] ; then
    echo -e "${RED}"
    echo "***"
    echo "Explorer is already installed!"
    echo "***"
    echo -e "${NC}"
else
    sed -i "s/EXPLORER_KEY=.*$/EXPLORER_KEY=$EXPLORER_KEY/" "${DOJO_PATH}"/conf/docker-explorer.conf.tpl
fi

if [ ! -f "${DOJO_PATH}"/conf/docker-indexer.conf ] ; then
    read -rp "Do you want to install an Indexer? [y/n]" yn
    case $yn in
        [Y/y]* )
                 sudo sed -i 's/INDEXER_INSTALL=off/INDEXER_INSTALL=on/' "${DOJO_PATH}"/conf/docker-indexer.conf.tpl
                 sudo sed -i 's/NODE_ACTIVE_INDEXER=bitcoind/NODE_ACTIVE_INDEXER=local_indexer/' "${DOJO_PATH}"/conf/docker-node.conf.tpl;;
        [N/n]* )  echo -e "${RED}"
                 echo "***"
                 echo "Indexer will not be installed!"
                 echo "***"
                 echo -e "${NC}";;
        * ) echo "Please answer Yes or No.";;
    esac
elif grep "INDEXER_INSTALL=off" "${DOJO_PATH}"/conf/docker-indexer.conf > /dev/null ; then
        read -rp "Do you want to install an Indexer? [y/n]" yn
        case $yn in
            [Y/y]* )
                     sudo sed -i 's/INDEXER_INSTALL=off/INDEXER_INSTALL=on/' "${DOJO_PATH}"/conf/docker-indexer.conf
                     sudo sed -i 's/NODE_ACTIVE_INDEXER=bitcoind/NODE_ACTIVE_INDEXER=local_indexer/' "${DOJO_PATH}"/conf/docker-node.conf;;
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

if [ ! -f "${DOJO_PATH}"/indexer/electrs.toml ] ; then
   read -rp "Do you want to install Electrs? [y/n]" yn
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
   _sleep 3
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
   _sleep 5
else
   echo "Whirlpool will be installed via Dojo Docker"
   echo "For pairing information see the wiki"
fi
# stop whirlpool for existing whirlpool users
echo -e "${NC}"
cd "${DOJO_PATH}" || exit
./dojo.sh upgrade
# run upgrade

bash -c "$RONIN_DOJO_MENU"
# return to menu
