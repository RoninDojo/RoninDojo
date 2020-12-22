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

# Update Samourai Dojo repo
_dojo_update

if grep BITCOIND_RPC_EXTERNAL=off "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf 1>/dev/null; then
    sed -i 's/BITCOIND_RPC_EXTERNAL=.*$/BITCOIND_RPC_EXTERNAL=on/' "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf
fi
# enable BITCOIND_RPC_EXTERNAL

if grep "INDEXER_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
    bash "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
else grep "INDEXER_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ ! -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
    _set_addrindexer
fi

_is_mempool
_mempool_urls_to_local_btc_explorer
