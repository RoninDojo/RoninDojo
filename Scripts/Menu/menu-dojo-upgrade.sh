#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

WORK_DIR=$(mktemp -d)
# temporaly temp directory location

if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
    cat <<EOF
${RED}
***
Could not create temp dir, upgrade failed!
***
${NC}
EOF
exit 1
fi
# check if tmp dir was created

cat <<EOF
${RED}
***
Upgrading Dojo in 10s...
***
${NC}

{RED}
***
Use Ctrl+C to exit if needed!
***
${NC}
EOF
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

        cat <<EOF
${RED}
***
Checking BTC RPC Explorer...
***
${NC}
EOF
    _sleep 1

if [ -f "${DOJO_PATH}"/conf/docker-explorer.conf ] ; then
    cat <<EOF
${RED}
***
BTC RPC Explorer is already installed!
***
${NC}
EOF
else
    cat <<EOF
${RED}
***
Installing your BTC RPC Explorer...
***
${NC}
EOF
    _sleep 2
    cat <<EOF
${RED}
***
A randomly generated 16 character password will be created if you haven't already made one.
***
${NC}
EOF
    _sleep 3
    sed -i "s/EXPLORER_KEY=.*$/EXPLORER_KEY=$EXPLORER_KEY/" "${DOJO_PATH}"/conf/docker-explorer.conf.tpl
fi
# checks for docker-explorer.conf, if found informs user
# else uses sed to modify for explorer to be installed

    cat <<EOF
${RED}
***
Checking Indexer...
***
${NC}
EOF
    _sleep 1

if grep "INDEXER_INSTALL=off" "${DOJO_PATH}"/conf/docker-indexer.conf 1>/dev/null; then
        cat <<EOF
${RED}
***
No Indexer found...
***
${NC}
EOF
    _sleep 3
        cat <<EOF
${RED}
***
If you want an Indexer press "Y" when prompted, this is recommended for better performance...
***
${NC}
EOF
    _sleep 5
    read -rp "Do you want to install an Indexer? [y/n]" yn
    case $yn in
        [Y/y]* )
                 sudo sed -i 's/INDEXER_INSTALL=off/INDEXER_INSTALL=on/' "${DOJO_PATH}"/conf/docker-indexer.conf
                 sudo sed -i 's/NODE_ACTIVE_INDEXER=local_bitcoind/NODE_ACTIVE_INDEXER=local_indexer/' "${DOJO_PATH}"/conf/docker-node.conf;;
        [N/n]* ) cat <<EOF
                 ${RED}
                 ***
                 Indexer will not be installed...
                 ***
                 ${NC}
EOF;;
        * ) printf "\nPlease answer Yes or No.\n";;
    esac
else
    cat <<EOF
${RED}
***
Indexer is already installed...
***
${NC}
EOF
fi
# if docker-indexer.conf is not found prompt user to select
# for elif, if grep search INDEXER_INSTALL=off works, prompt user
# else informs user indexer is already installed

    cat <<EOF
${RED}
***
Checking Electrs...
***
${NC}
EOF
    _sleep 1

if [ ! -f "${DOJO_PATH}"/indexer/electrs.toml ] ; then
       cat <<EOF
${RED}
***
No Electrs found...
***
${NC}
EOF
    _sleep 3
       cat <<EOF
${RED}
***
If you want Electrs press "Y" when prompted, this is for Electrum and Hardware Wallets...
***
${NC}
EOF
    _sleep 3
   read -rp "Do you want to install Electrs? [y/n]" yn
   case $yn in
       [Y/y]* ) bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-electrs-upgrade.sh;;
       [N/n]* ) cat <<EOF
                ${RED}
                ***
                Electrs will not be installed!
                ***
                ${NC}
EOF;;
       * ) printf "\nPlease answer Yes or No.\n";;
    esac
else
   cat <<EOF
   ${RED}
   ***
   Electrs is already installed!
   ***
   ${NC}
EOF
   _sleep 3
   bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-electrs-upgrade.sh
fi
# if electrs.toml is not found the user is prompted to select y/n
# else informs user indexer is already installed

if [ -f /etc/systemd/system/whirlpool.service ] ; then
   sudo systemctl stop whirlpool
   cat <<EOF
   ${RED}
   ***
   Whirlpool will be installed via Docker...
   ***
   ${NC}

   ${RED}
   ***
   You will need to re-pair with GUI, see Wiki for more information...
   ***
   ${NC}
EOF
   _sleep 5
else
   cat <<EOF
   ${RED}
   ***
   Whirlpool will be installed via Docker...
   ***
   ${NC}

   ${RED}
   ***
   For pairing information see the wiki...
   ***
   ${NC}
EOF
   _sleep 3
fi
# stop whirlpool for existing whirlpool users

cd "${DOJO_PATH}" || exit
./dojo.sh upgrade
# run upgrade

bash -c "$RONIN_DOJO_MENU"
# return to menu