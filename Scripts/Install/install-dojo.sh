#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/generated-credentials.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if ! findmnt "${INSTALL_DIR}" 1>/dev/null; then
    cat <<EOF
${RED}
***
Missing drive mount at ${INSTALL_DIR}! Please contact support for assistance.
***
${NC}
EOF
_sleep

    cat <<EOF
${RED}
***
Exiting RoninDojo in 5 seconds...
***
${NC}
EOF
    _sleep 5 --msg "Returning to menu in"
    exit 1
fi

if [ -d "${dojo_path_my_dojo}" ]; then
    cat <<EOF
${RED}
***
RoninDojo is already installed...
***
${NC}
EOF
    _sleep 5 --msg "Returning to menu in"
    ronin
    exit
fi
# Makes sure RoninDojo has been uninstalled

cat <<EOF
${RED}
***
Running RoninDojo install...
***
${NC}
EOF
_sleep 2

cat <<EOF
${RED}
***
Use Ctrl+C to exit now if needed!
***
${NC}
EOF
_sleep 10 --msg "Installing in"

cat <<EOF
${RED}
***
Downloading and extracting latest RoninDojo release...
***
${NC}
EOF

cd "$HOME" || exit
git clone -b "${SAMOURAI_COMMITISH:-master}" "$SAMOURAI_REPO" dojo 2>/dev/null

if [ ! -d "${RONIN_UI_BACKEND_DIR}" ]; then
  _install_ronin_ui_backend
  # Install Ronin UI Backend service
fi

cat <<EOF
${RED}
***
Credentials necessary for usernames, passwords, etc. will randomly be generated now...
***
${NC}
EOF
_sleep 4

cat <<EOF
${RED}
***
Credentials are found in RoninDojo menu, ${dojo_path_my_dojo}/conf, or in the ~/RoninDojo/user.conf.example file.
***
${NC}
EOF
_sleep 4

cat <<EOF
${RED}
***
Be aware these credentials are used to login to Dojo Maintenance Tool, Block Explorer, and more!
***
${NC}
EOF
_sleep 4

cat <<EOF
${RED}
***
Setting the RPC User and Password...
***
${NC}
EOF
_sleep

if [ -d "${DOJO_BACKUP_DIR}" ]; then
    if ! _dojo_restore; then
        cat <<EOF
${RED}
***
Backup restoration disabled!
***
${NC}
EOF
        _sleep

        cat <<EOF
${RED}
***
Enable in user.conf if you wish to restore credentials on dojo install when available...
***
${NC}
EOF
        _sleep 3
    else
        cat <<EOF
${RED}
***
Credentials backup detected and restored...
***
${NC}
EOF
        _sleep

        cat <<EOF
${RED}
***
If you wish to disable this feature, set DOJO_RESTORE=false in $HOME/.conf/RoninDojo/user.conf file...
***
${NC}
EOF
        _sleep 3
    fi
else
    cat <<EOF
${RED}
***
Configuring the bitcoin daemon server...
***
${NC}
EOF
    _sleep
    sed -i -e "s/BITCOIND_RPC_USER=.*$/BITCOIND_RPC_USER=${BITCOIND_RPC_USER:-$RPC_USER}/" \
      -e "s/BITCOIND_RPC_PASSWORD=.*$/BITCOIND_RPC_PASSWORD=${BITCOIND_RPC_PASSWORD:-$RPC_PASS}/" \
      -e "s/BITCOIND_DB_CACHE=.*$/BITCOIND_DB_CACHE=${BITCOIND_DB_CACHE:-700}/" \
      -e "s/BITCOIND_MAX_MEMPOOL=.*$/BITCOIND_MAX_MEMPOOL=400/" \
      -e "s/BITCOIND_RPC_EXTERNAL=.*$/BITCOIND_RPC_EXTERNAL=${BITCOIND_RPC_EXTERNAL:-on}/" \
      -e "s/BITCOIND_RPC_EXTERNAL_IP=.*$/BITCOIND_RPC_EXTERNAL_IP=${BITCOIND_RPC_EXTERNAL_IP:-127.0.0.1}/" "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf.tpl
      # populate docker-bitcoind.conf.tpl template

    cat <<EOF
${RED}
***
Configuring the Nodejs container...
***
${NC}
EOF
    _sleep

    sed -i -e "s/NODE_API_KEY=.*$/NODE_API_KEY=${NODE_API_KEY}/" \
      -e "s/NODE_ADMIN_KEY=.*$/NODE_ADMIN_KEY=${NODE_ADMIN_KEY}/" \
      -e "s/NODE_JWT_SECRET=.*$/NODE_JWT_SECRET=${NODE_JWT_SECRET}/" \
      -e "s/NODE_ACTIVE_INDEXER=.*$/NODE_ACTIVE_INDEXER=${NODE_ACTIVE_INDEXER:-local_bitcoind}/" "${dojo_path_my_dojo}"/conf/docker-node.conf.tpl
    # populate docker-node.conf.tpl template

    sed -i -e "s/MYSQL_ROOT_PASSWORD=.*$/MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}/" \
      -e "s/MYSQL_USER=.*$/MYSQL_USER=${MYSQL_USER}/" \
      -e "s/MYSQL_PASSWORD=.*$/MYSQL_PASSWORD=${MYSQL_PASSWORD}/" "${dojo_path_my_dojo}"/conf/docker-mysql.conf.tpl
    # populate docker-mysql.conf.tpl template

    cat <<EOF
${RED}
***
Configuring the BTC RPC Explorer...
***
${NC}
EOF
    _sleep

    sed -i -e "s/EXPLORER_INSTALL=.*$/EXPLORER_INSTALL=${EXPLORER_INSTALL:-on}/" \
      -e "s/EXPLORER_KEY=.*$/EXPLORER_KEY=${EXPLORER_KEY}/" "${dojo_path_my_dojo}"/conf/docker-explorer.conf.tpl
    # populate docker-explorer.conf.tpl template

    # Backup credentials
    _dojo_backup
fi

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
_sleep 4

cat <<EOF
${RED}
***
Electrum Rust Server is recommended for Hardware Wallets, Multisig, and other Electrum features...
***
${NC}
EOF
_sleep 4

cat <<EOF
${RED}
***
Skipping the installation of either Indexer option is ok! You can always install later...
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
_no_indexer_found
# give user menu for install choices, see functions.sh

if [ ! -f "${dojo_path_my_dojo}/conf/docker-mempool.conf" ] || grep "MEMPOOL_INSTALL=off" "${dojo_path_my_dojo}/conf/docker-mempool.conf" 1>/dev/null; then
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
          [yY][eE][sS]|[yY]|"")
            _mempool_conf conf.tpl
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
    # install mempool prompt
fi

cat <<EOF
${RED}
***
Please see Wiki for FAQ, help, and so much more...
***
${NC}
EOF
_sleep 3

cat <<EOF
${RED}
***
https://wiki.ronindojo.io
***
${NC}
EOF
_sleep 3

cat <<EOF
${RED}
***
Installing Samourai Wallet's Dojo...
***
${NC}
EOF
_sleep 2

cd "$dojo_path_my_dojo" || exit
./dojo.sh install --nolog

# Checks if urls need to be changed for mempool UI
_mempool_urls_to_local_btc_explorer

if _dojo_check "$dojo_path_my_dojo"; then
    cat <<EOF
${RED}
***
All RoninDojo feature installations complete...
***
${NC}
EOF
    _sleep 3

    cat <<EOF
${RED}
***
Press any key to continue...
***
${NC}
EOF

    _pause
    # press to continue is needed because sudo password can be requested for next steps
    # if the user is AFK there may be timeout

    if sudo test -d "${INSTALL_DIR_UNINSTALL}/blocks" && sudo test -d "${DOCKER_VOLUME_BITCOIND}"; then
        cat <<EOF
${RED}
***
Blockchain data salvage starting...
***
${NC}
EOF

        cd "$dojo_path_my_dojo" || exit
        _stop_dojo

        _sleep

        sudo rm -rf "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate}
        sudo mv -v "${INSTALL_DIR_UNINSTALL}"/{blocks,chainstate} "${DOCKER_VOLUME_BITCOIND}"/_data/ 1>/dev/null
        # changes to dojo path, otherwise exit
        # websearch "bash Logical OR (||)" for info
        # stops dojo and removes new data directories
        # then moves salvaged block data

        cat <<EOF
${RED}
***
Blockchain data salvage completed...
***
${NC}
EOF
        _sleep 2

        sudo rm -rf "${INSTALL_DIR_UNINSTALL}"
        # remove old salvage directories

        cd "$dojo_path_my_dojo" || exit
        _source_dojo_conf

        # Start docker containers
        yamlFiles=$(_select_yaml_files)
        docker-compose $yamlFiles up --remove-orphans -d || exit # failed to start dojo
        # start dojo
    fi
    # check for IBD data, if not found continue

    if ${TOR_RESTORE}; then
        _tor_restore
        docker restart tor 1>/dev/null
    fi
    # restore tor credentials backup to container
else
        cat <<EOF
${RED}
***
Install failed! Please contact support...
***
${NC}
EOF

        cat <<EOF
${RED}
***
Press any key to continue...
***
${NC}
EOF

        _pause
        _sleep 5 --msg "Returning to main menu in"
        ronin
fi

