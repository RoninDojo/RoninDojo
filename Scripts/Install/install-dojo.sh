#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/generated-credentials.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if ! findmnt "${install_dir}" 1>/dev/null; then
    cat <<EOF
${red}
***
Missing drive mount at ${install_dir}! Please contact support for assistance...
***
${nc}
EOF
    _sleep 2
    cat <<EOF
${red}
***
Exiting RoninDojo...
***
${nc}
EOF
    _sleep 2
    _pause return
    exit 1
fi

if [ -d "${dojo_path_my_dojo}" ]; then
    cat <<EOF
${red}
***
RoninDojo is already installed...
***
${nc}
EOF
    _sleep 2
    _pause return
    ronin
    exit
fi
# Makes sure RoninDojo has been uninstalled

cat <<EOF
${red}
***
Running RoninDojo install...
***
${nc}
EOF
_sleep 2

cat <<EOF
${red}
***
Use Ctrl+C to exit now if needed!
***
${nc}
EOF
_sleep 10 --msg "Installing in"

cat <<EOF
${red}
***
Downloading latest RoninDojo release...
***
${nc}
EOF

cd "$HOME" || exit
git clone -q -b "${samourai_commitish#*/}" "$samourai_repo" dojo 2>/dev/null

# Switch over to a branch if in detached state. Usually this happens
# when you clone a tag instead of a branch
cd "${dojo_path}" || exit

_git_ref_type
_ret=$?

if ((_ret==3)); then
    # valid branch
    git switch -q -c "${samourai_commitish}" -t "${samourai_commitish}"
else
    # valid tag
    git checkout -q -b "${samourai_commitish}" "${samourai_commitish}"
fi

# Check if UI Backend needs installing
if ! _ronin_ui_update_check; then
    _install_ronin_ui_backend
fi

cat <<EOF
${red}
***
Credentials necessary for usernames, passwords, etc. will randomly be generated now...
***
${nc}
EOF
_sleep 4

cat <<EOF
${red}
***
Credentials are found in RoninDojo menu, ${dojo_path_my_dojo}/conf, or the ~/RoninDojo/user.conf.example file...
***
${nc}
EOF
_sleep 4

cat <<EOF
${red}
***
Be aware these credentials are used to login to Dojo Maintenance Tool, Block Explorer, and more!
***
${nc}
EOF
_sleep 4

cat <<EOF
${red}
***
Setting the RPC User and Password...
***
${nc}
EOF
_sleep

if [ -d "${dojo_backup_dir}" ]; then
    if ! _dojo_restore; then
        cat <<EOF
${red}
***
Backup restoration disabled!
***
${nc}
EOF
        _sleep

        cat <<EOF
${red}
***
Enable in user.conf if you wish to restore credentials on dojo install when available...
***
${nc}
EOF
        _sleep 3
    else
        cat <<EOF
${red}
***
Credentials backup detected and restored...
***
${nc}
EOF
        _sleep

        cat <<EOF
${red}
***
If you wish to disable this feature, set dojo_conf_backup=false in the $HOME/.config/RoninDojo/user.conf file...
***
${nc}
EOF
        _sleep 3
    fi
else
    cat <<EOF
${red}
***
Configuring the bitcoin daemon server...
***
${nc}
EOF
    _sleep
    sed -i -e "s/BITCOIND_RPC_USER=.*$/BITCOIND_RPC_USER=${BITCOIND_RPC_USER:-$rpc_user}/" \
      -e "s/BITCOIND_RPC_PASSWORD=.*$/BITCOIND_RPC_PASSWORD=${BITCOIND_RPC_PASSWORD:-$rpc_pass}/" \
      -e "s/BITCOIND_DB_CACHE=.*$/BITCOIND_DB_CACHE=${BITCOIND_DB_CACHE:-$(_mem_total "${bitcoind_db_cache_total}")}/" \
      -e "s/BITCOIND_MAX_MEMPOOL=.*$/BITCOIND_MAX_MEMPOOL=${BITCOIND_MAX_MEMPOOL:-1024}/" \
      -e "s/BITCOIND_RPC_EXTERNAL_IP=.*$/BITCOIND_RPC_EXTERNAL_IP=${BITCOIND_RPC_EXTERNAL_IP:-127.0.0.1}/" "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf.tpl
      # populate docker-bitcoind.conf.tpl template

    cat <<EOF
${red}
***
Configuring the Nodejs container...
***
${nc}
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
${red}
***
Configuring the BTC RPC Explorer...
***
${nc}
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
${red}
***
Please see Wiki for FAQ, help, and so much more...
***
${nc}
EOF
_sleep 3

cat <<EOF
${red}
***
https://wiki.ronindojo.io
***
${nc}
EOF
_sleep 3

cat <<EOF
${red}
***
Installing Samourai Wallet's Dojo...
***
${nc}
EOF
_sleep 2

# Restart docker here for good measure
sudo systemctl restart docker

cd "$dojo_path_my_dojo" || exit

if ./dojo.sh install --nolog; then
    cat <<EOF
${red}
***
All RoninDojo feature installations complete...
***
${nc}
EOF
    # Make sure to wait for user interaction before continuing
    _pause continue

    # Backup dojo credentials
    "${dojo_conf_backup}" && _dojo_backup

    # Restore any saved IBD from a previous uninstall
    "${dojo_data_bitcoind_backup}" && _dojo_data_bitcoind restore

    # Restore any saved indexer data from a previous uninstall
    "${dojo_data_indexer_backup}" && _dojo_data_indexer restore

    if ${tor_backup}; then
        _tor_restore
        docker restart tor 1>/dev/null
    fi
    # restore tor credentials backup to container

    # Installing SW Toolkit

    if [ ! -d "${HOME}"/boltzmann ]; then
        cat <<EOF
${red}
***
Installing Boltzmann Calculator...
***
${nc}
EOF
        _sleep 2

        # install Boltzmann
        _install_boltzmann
    fi

    if [ ! -d "${HOME}"/Whirlpool-Stats-Tool ]; then
        cat <<EOF
${red}
***
Installing Whirlpool Stat Tool...
***
${nc}
EOF
        _sleep 2

        _install_wst
    fi

    # Source update script
    . "$HOME"/RoninDojo/Scripts/update.sh

    # Run _update_08
    test -f "$HOME"/.config/RoninDojo/data/updates/08-* || _update_08 # Make sure mnt-usb.mount is available

    # Press to continue to prevent from snapping back to menu too quickly
    _pause return
else
        cat <<EOF
${red}
***
Install failed! Please contact support...
***
${nc}
EOF

        _pause return
        ronin
fi