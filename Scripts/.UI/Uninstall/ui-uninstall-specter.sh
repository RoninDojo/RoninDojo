#!/bin/bash

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh


if _is_specter ; then
    sudo rm -f "$HOME"/.specter /etc/systemctl/system/specter.service "$HOME"/specter-*
    sudo systemctl daemon-reload
fi