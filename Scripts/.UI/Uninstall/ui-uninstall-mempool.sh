#!/bin/bash

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if grep "MEMPOOL_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-mempool.conf 1>/dev/null; then
    sed -i 's/MEMPOOL_INSTALL=.*$/MEMPOOL_INSTALL=off/' "${dojo_path_my_dojo}"/conf/docker-mempool.conf
fi