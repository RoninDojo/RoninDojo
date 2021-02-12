#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/generated-credentials.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if ! findmnt "${install_dir}" 1>/dev/null; then
    cat <<EOF
${RED}
***
Missing drive mount at ${install_dir}! Please contact support for assistance...
***
${NC}
EOF
    _sleep 2
    cat <<EOF
${RED}
***
Exiting RoninDojo...
***
${NC}
EOF
    _sleep 2
    _pause return
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
    _sleep 2
    _pause return
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
Downloading latest RoninDojo release...
***
${NC}
EOF

cd "$HOME" || exit
git clone -b "${samourai_commitish##*/}" "$samourai_repo" dojo 2>/dev/null

if _ronin_ui_update_check; then
    cat <<EOF
${RED}
***
Installing Ronin UI Backend...
***
${NC}
EOF
    _install_ronin_ui_backend
fi

# Check if UI Backend needs installing


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
Credentials are found in RoninDojo menu, ${dojo_path_my_dojo}/conf, or the ~/RoninDojo/user.conf.example file...
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

if [ -d "${dojo_backup_dir}" ]; then
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
If you wish to disable this feature, set dojo_conf_backup=false in the $HOME/.config/RoninDojo/user.conf file...
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
    sed -i -e "s/BITCOIND_RPC_USER=.*$/BITCOIND_RPC_USER=${BITCOIND_RPC_USER:-$rpc_user}/" \
      -e "s/BITCOIND_RPC_PASSWORD=.*$/BITCOIND_RPC_PASSWORD=${BITCOIND_RPC_PASSWORD:-$rpc_pass}/" \
      -e "s/BITCOIND_DB_CACHE=.*$/BITCOIND_DB_CACHE=${BITCOIND_DB_CACHE:-1024}/" \
      -e "s/BITCOIND_MAX_MEMPOOL=.*$/BITCOIND_MAX_MEMPOOL=${BITCOIND_MAX_MEMPOOL:-1024}/" \
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
fi

_check_indexer

if (($?==2)); then # No indexer, fresh install so show prompts for indexer selection
    _indexer_prompt
    # give user menu for install choices, see functions.sh
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

if ./dojo.sh install --nolog; then
    cat <<EOF
${RED}
***
All RoninDojo feature installations complete...
***
${NC}
EOF
    _sleep

    _pause continue
    # press to continue is needed because sudo password can be requested for next steps
    # if the user is AFK there may be timeout

    # Backup dojo credentials
    _dojo_backup

    # Restore any saved IBD from a previous uninstall
    "${dojo_data_bitcoind_backup}" && _dojo_data_bitcoind restore

    # Restore any saved indexer data from a previous uninstall
    "${dojo_data_indexer_backup}" && _dojo_data_indexer restore

    if ${tor_backup}; then
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

        _pause return
        ronin
fi