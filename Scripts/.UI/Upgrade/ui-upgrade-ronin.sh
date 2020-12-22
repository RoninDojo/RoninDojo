#!/bin/bash

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if [ ! -d "$HOME"/RoninDojo ] || [ ! -d ${DOJO_PATH} ]; then
    exit 1
fi
# is ronindojo directory missing?

test -f "$HOME"/ronin-update.sh && sudo rm "$HOME"/ronin-update.sh
# Remove old update file

_update_ronin
# see functions.sh
_install_ronin_ui_backend
# update ronin ui backend
if ! _dojo_check; then
    if [ ! -d "${DOJO_PATH}" ]; then
        exit 1
    fi
fi