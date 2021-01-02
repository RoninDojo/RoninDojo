#!/bin/bash

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if _mempool_check ; then
    _mempool_conf
    _mempool_urls_to_local_btc_explorer
fi