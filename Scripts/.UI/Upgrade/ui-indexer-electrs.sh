#!/bin/bash

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh


### SWITCH FROM ADDRINDEXER TO ELECTRS ###

if grep "INDEXER_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ ! -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
    bash "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
fi