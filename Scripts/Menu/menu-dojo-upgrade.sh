#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

WORK_DIR=$(mktemp -d)
# temporaly temp directory location

if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
    echo -e "${RED}"
    echo "****"
    echo "Could not create temp dir, upgrade failed!"
    echo "***"
    echo -e "${NOC}"
    exit 1
fi
# check if tmp dir was created

echo -e "${RED}"
echo "***"
echo "Upgrading Dojo in 10s..."
echo "***"
echo -e "${NC}"

echo -e "${RED}"
echo "***"
echo "Use Ctrl+C to exit if needed!"
echo "***"
echo -e "${NC}"
_sleep 5

_check_dojo_perms "${DOJO_PATH}"
# make sure permissions are properly set for ${DOJO_PATH}

if grep BITCOIND_RPC_EXTERNAL=off "${DOJO_PATH}"/conf/docker-bitcoind.conf 1>/dev/null; then
    sed -i 's/BITCOIND_RPC_EXTERNAL=off/BITCOIND_RPC_EXTERNAL=on/' "${DOJO_PATH}"/conf/docker-bitcoind.conf
fi
# enable BITCOIND_RPC_EXTERNAL
cd "${WORK_DIR}" || exit
git clone -b "${SAMOURAI_COMMITISH:-master}" "$SAMOURAI_REPO" 2>/dev/null # temporary

cp -ua samourai-dojo/* "${DOJO_PATH%/docker/my-dojo}"/
# copy only when the SOURCE file is newer than the
# destination file or when the destination file is missing
# and keep all permissions

rm -rf "${WORK_DIR}"
# remove $WORK_DIR

# Return to previous working path
cd "${HOME}" || exit

if [ -f "${DOJO_PATH}"/conf/docker-explorer.conf ] ; then
    echo -e "${RED}"
    echo "***"
    echo "Explorer is already installed!"
    echo "***"
    echo -e "${NC}"
else
    echo -e "${RED}"
    echo "***"
    echo "Installing your Blockchain Explorer..."
    echo "***"
    echo -e "${NC}"
    _sleep 2

    echo -e "${RED}"
    echo "***"
    echo "A randomly generated 16 character password will be created if you haven't already made one."
    echo "***"
    echo -e "${NC}"
    _sleep 3
    sed -i "s/EXPLORER_KEY=.*$/EXPLORER_KEY=$EXPLORER_KEY/" "${DOJO_PATH}"/conf/docker-explorer.conf.tpl
fi
# checks for docker-explorer.conf, if found informs user
# else uses sed to modify for explorer to be installed

if grep "INDEXER_INSTALL=off" "${DOJO_PATH}"/conf/docker-indexer.conf 1>/dev/null; then
    read -rp "Do you want to install an Indexer? [y/n]" yn
    case $yn in
        [Y/y]* )
                 sudo sed -i 's/INDEXER_INSTALL=off/INDEXER_INSTALL=on/' "${DOJO_PATH}"/conf/docker-indexer.conf
                 sudo sed -i 's/NODE_ACTIVE_INDEXER=local_bitcoind/NODE_ACTIVE_INDEXER=local_indexer/' "${DOJO_PATH}"/conf/docker-node.conf;;
        [N/n]* )  echo -e "${RED}"
                 echo "***"
                 echo "Indexer will not be installed..."
                 echo "***"
                 echo -e "${NC}";;
        * ) echo "Please answer Yes or No.";;
    esac
else
    echo -e "${RED}"
    echo "***"
    echo "Indexer is already installed..."
    echo "***"
    echo -e "${NC}"
fi
# if docker-indexer.conf is not found prompt user to select
# for elif, if grep search INDEXER_INSTALL=off works, prompt user
# else informs user indexer is already installed

if [ ! -f "${DOJO_PATH}"/indexer/electrs.toml ] ; then
   read -rp "Do you want to install Electrs? [y/n]" yn
   case $yn in
       [Y/y]* ) bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-electrs-upgrade.sh;;
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
   bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-electrs-upgrade.sh
fi
# if electrs.toml is not found the user is prompted to select y/n
# else informs user indexer is already installed

if [ -f /etc/systemd/system/whirlpool.service ] ; then
   sudo systemctl stop whirlpool
   echo -e "${RED}"
   echo "***"
   echo "Whirlpool will be installed via Dojo docker"
   echo "You will need to re-pair with GUI"
   echo "See wiki for more information"
   echo "***"
   echo -e "${NC}"
   _sleep 5
else
   echo -e "${RED}"
   echo "Whirlpool will be installed via Dojo Docker"
   echo "For pairing information see the wiki"
   echo -e "${NC}"
fi
# stop whirlpool for existing whirlpool users

cd "${DOJO_PATH}" || exit
./dojo.sh upgrade
# run upgrade

bash -c "$RONIN_DOJO_MENU"
# return to menu