#!/bin/bash

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if [ ! -d "$HOME"/RoninDojo ] || [ ! -d ${DOJO_PATH} ]; then
    exit 1
fi
# is ronindojo directory missing?

if ! _dojo_check; then
    if [ ! -d "${DOJO_PATH}" ]; then
        exit 1
    fi
fi

_load_user_conf
_check_dojo_perms "${dojo_path_my_dojo}"

if grep BITCOIND_RPC_EXTERNAL=off "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf 1>/dev/null; then
    sed -i 's/BITCOIND_RPC_EXTERNAL=.*$/BITCOIND_RPC_EXTERNAL=on/' "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf
fi
# enable BITCOIND_RPC_EXTERNAL

# Update Samourai Dojo repo
_dojo_update

cd "${HOME}" || exit