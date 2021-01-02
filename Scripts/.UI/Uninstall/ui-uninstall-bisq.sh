#!/bin/bash

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh


if _is_bisq ; then
    rm "${INSTALL_DIR_USER}"/bisq.txt
fi