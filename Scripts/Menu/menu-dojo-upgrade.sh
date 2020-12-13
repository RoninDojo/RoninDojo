#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

_check_dojo_perms "${dojo_path_my_dojo}"
# make sure permissions are properly set for ${dojo_path_my_dojo}

if grep BITCOIND_RPC_EXTERNAL=off "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf 1>/dev/null; then
    sed -i 's/BITCOIND_RPC_EXTERNAL=.*$/BITCOIND_RPC_EXTERNAL=on/' "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf
fi
# enable BITCOIND_RPC_EXTERNAL

# Update Samourai Dojo repo
_dojo_update

cd "${HOME}" || exit
# return to previous working path

if grep "EXPLORER_INSTALL=off" "${dojo_path_my_dojo}"/conf/docker-explorer.conf 1>/dev/null; then
    cat <<EOF
${RED}
***
BTC RPC Explorer not installed, would you like to install it?
***
${NC}
EOF
    while true; do
        read -rp "[${GREEN}Yes${NC}/${RED}No${NC}]: " answer
        case $answer in
            [yY][eE][sS]|[yY])
                sed -i "s/EXPLORER_INSTALL=.*$/EXPLORER_INSTALL=on/" "${dojo_path_my_dojo}"/conf/docker-explorer.conf
                break
                ;;
            [nN][oO]|[Nn])
                break
                ;;
                *)
                cat <<EOF
${RED}
***
Invalid answer! Enter Y or N
***
${NC}
EOF
                ;;
        esac
    done
fi
# Checks if BTC RPC Explorer is disabled

if grep "INDEXER_INSTALL=off" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ ! -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
    cat <<EOF
${RED}
***
Checking for Indexer...
***
${NC}
EOF
    _sleep

    cat <<EOF
${RED}
***
No Indexer found...
***
${NC}
EOF
    _sleep

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
    _sleep 2

    cat <<EOF
${RED}
***
Electrum Rust Server is recommended for Hardware Wallets, Multisig, and other Electrum features...
***
${NC}
EOF
    _sleep 2

    cat <<EOF
${RED}
***
Skipping the installation of either Indexer option is ok! You can always install later...
***
${NC}
EOF
    _sleep 2

    cat <<EOF
${RED}
***
Choose one of the following options for your Indexer...
***
${NC}
EOF
    _sleep 2

    _no_indexer_found
    # give user menu for install choices, see functions.sh
else
    if grep "INDEXER_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
        cat <<EOF
${RED}
***
Electrum Rust Server found...
***
${NC}
EOF
        _sleep 2

        cat <<EOF
${RED}
***
Would you like to make any changes to your Indexer during this upgrade?
***
${NC}
EOF
        _sleep 2

        select indexer in "Keep Electrum Rust Server (default)" "Replace With Samourai Indexer"; do
            case $indexer in
                "Keep Electrum Rust Server (default)")
                    cat <<EOF
${RED}
***
Keeping Electrum Rust Server...
***
${NC}
EOF
                    _sleep
                    bash "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
                    break
                    ;;
                    # keep the samourai indexer

                "Replace With Samourai Indexer")
                    cat <<EOF
${RED}
***
Replacing with Samourai Indexer...
***
${NC}
EOF
                    _sleep

                    cd "${dojo_path_my_dojo}" || exit

                    rm indexer/electrs.toml

                    _set_addrindexer

                    break
                    ;;
                    # remove electrs toml file, checkout to revert changes made in files, and trigger samourai indexer install
                *)
                    cat <<EOF
${RED}
***
Invalid Entry! Valid values are 1 or 2...
***
${NC}
EOF
                    _sleep
                    ;;
                    # invalid data try again
            esac
        done
    elif grep "INDEXER_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ ! -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
        cat <<EOF
${RED}
***
Samourai Indexer found...
***
${NC}
EOF
        _sleep 2

        cat <<EOF
${RED}
***
Would you like to make any changes to your Indexer during this upgrade?
***
${NC}
EOF
        _sleep 3

        select indexer in "Keep Samourai Indexer (default)" "Replace With Electrum Rust Server"; do
            case $indexer in
                "Keep Samourai Indexer (default)")
                    cat <<EOF
${RED}
***
Keeping Samourai Indexer...
***
${NC}
EOF
                    _sleep

                    _set_addrindexer

                    break
                    ;;
                    # keep electrum rust server

                "Replace With Electrum Rust Server")
                    cat <<EOF
${RED}
***
Replacing with Electrum Rust Server...
***
${NC}
EOF
                    _sleep

                    bash "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh

                    break
                    ;;
                    # triggers electrs install script
                *)
                    cat <<EOF
${RED}
***
Invalid answer! Enter Y or N
***
${NC}
EOF
                    _sleep
                    ;;
                    # invalid data try again
            esac
        done
    fi
fi

if _is_mempool; then
    cat <<EOF
${RED}
***
Do you want to install the Mempool Visualizer?
***
${NC}
EOF
    while true; do
        read -rp "[${GREEN}Yes${NC}/${RED}No${NC}]: " answer
        case $answer in
            [yY][eE][sS]|[yY])
                _mempool_conf

                # Checks if urls need to be changed for mempool UI
                _mempool_urls_to_local_btc_explorer
                break
                ;;
            [Nn][oO]|[nN])
                break
                ;;
            *)
                cat <<EOF
${RED}
***
Please answer Yes or No.
***
${NC}
EOF
            ;;
        esac
    done
else
    # Repopulate mempool/Dockerfile with current credentials
    _mempool_conf
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
   _sleep 2
fi
# stop whirlpool for existing whirlpool users

cd "${dojo_path_my_dojo}" || exit
./dojo.sh upgrade --nolog
# run upgrade

_create_credentials

bash -c "$RONIN_UPDATES_MENU"
# return to menu
