#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
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

${RED}
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

cd "${HOME}" || exit
# return to previous working path

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

if grep "INDEXER_INSTALL=off" "${DOJO_PATH}"/conf/docker-indexer.conf 1>/dev/null && [ ! -f "${DOJO_PATH}"/indexer/electrs.toml ] ; then
    cat <<EOF
${RED}
***
Checking for Indexer...
***
${NC}
EOF
    _sleep 1
    # if indexer and electrs are not found then give user menu for install choices

    cat <<EOF
${RED}
***
No Indexer found...
***
${NC}
EOF
    _sleep 1

    cat <<EOF
${RED}
***
Preparing for Indexer Prompt...
***
${NC}
EOF
    _sleep 2

    cat <<EOF
${RED}
***
Samourai Indexer is recommended for most users as it helps with querying balances...
***
${NC}
EOF
    _sleep 3

    cat <<EOF
${RED}
***
Electrum Rust Server is recommended for Hardware Wallets, Multisig, and other Electrum features...
***
${NC}
EOF
    _sleep 3

    cat <<EOF
${RED}
***
Choose one of the following options for your Indexer...
***
${NC}
EOF
    _sleep 3

    # indexer names here are used as data source
    select indexer in "Samourai Indexer" "Electrum Rust Server" "Do Not Install Indexer"; do
        case $indexer in
            "Samourai Indexer")
                cat <<EOF
${RED}
***
Installing Samourai Indexer...
***
${NC}
EOF
                _sleep
                sudo sed -i 's/INDEXER_INSTALL=off/INDEXER_INSTALL=on/' "${DOJO_PATH}"/conf/docker-indexer.conf
                sudo sed -i 's/NODE_ACTIVE_INDEXER=local_bitcoind/NODE_ACTIVE_INDEXER=local_indexer/' "${DOJO_PATH}"/conf/docker-node.conf
                break;;
                # samourai indexer install enabled in .conf.tpl files using sed

            "Electrum Rust Server")
                cat <<EOF
${RED}
***
Installing Electrum Rust Server...
***
${NC}
EOF
                _sleep
                bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-electrs-upgrade.sh;;
                # triggers electrs install script

            "Do Not Install Indexer")
                cat <<EOF
${RED}
***
An Indexer will not be installed during this upgrade...
***
${NC}
EOF
                _sleep
                break;;
                # indexer will not be installed
            *)
                cat <<EOF
${RED}
***
Invalid Entry! Valid values are 1, 2, 3...
***
${NC}
EOF
                _sleep
                ;;
                # invalid data try again
        esac
    done
else
    cat <<EOF
${RED}
***
Checking for Indexer...
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
If you want to install Samourai Indexer press "Y" when prompted...
***
${NC}

${RED}
***
This is recommended for most users as it helps with querying balances...
***
${NC}
EOF
        _sleep 5
        cat <<EOF
${RED}
***
Do you want to install an Indexer? [y/n]
***
${NC}
EOF
        read -r yn
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
EOF
                    ;;
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
Checking for Electrum Rust Server...
***
${NC}
EOF
    _sleep 1

    if [ ! -f "${DOJO_PATH}"/indexer/electrs.toml ] ; then
        cat <<EOF
${RED}
***
No Electrum Rust Server found...
***
${NC}
EOF
       _sleep 3

       cat <<EOF
${RED}
***
If you want to install Electrum Rust Server press "Y" when prompted...
***
${NC}

${RED}
***
Electrum Rust Server is recommended for Hardware Wallets, Multisig, and other Electrum features...
***
${NC}
EOF
       _sleep 5
       read -rp "Do you want to install Electrum Rust Server? [y/n]" yn
       case $yn in
           [Y/y]* ) bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-electrs-upgrade.sh;;
           [N/n]* ) cat <<EOF
${RED}
***
Electrum Rust Server will not be installed!
***
${NC}
EOF
                    ;;
           * ) printf "\nPlease answer Yes or No.\n";;
        esac
    else
        cat <<EOF
${RED}
***
Electrum Rust Server is already installed!
***
${NC}
EOF
        _sleep 3
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-electrs-upgrade.sh
    fi
# if electrs.toml is not found the user is prompted to select y/n
# else informs user indexer is already installed
fi

if _is_mempool; then
    cat <<EOF
${RED}
***
Do you want to install the Mempool Visualizer? [y/n]
***
${NC}
EOF
    read -r yn
    case $yn in
        [Y/y]* )
                if [ ! -f "${DOJO_PATH}"/conf/docker-mempool.conf ]; then # New install
                    _mempool_conf conf.tpl
                else # Existing install?
                    _mempool_conf conf
                fi

                # Checks if urls need to be changed for mempool UI
                _mempool_urls_to_local_btc_explorer
                ;;
        [N/n]* )  echo -e "${RED}"
                 echo "***"
                 echo "Mempool will not be installed..."
                 echo "***"
                 echo -e "${NC}";;
        * ) echo "Please answer Yes or No.";;
    esac
else
    _mempool_conf conf
    echo -e "${RED}"
    echo "***"
    echo "Mempool visualizer is already installed..."
    echo "***"
    echo -e "${NC}"
fi
# Check if mempool available or not

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

bash -c "$RONIN_UPDATES_MENU"
# return to menu