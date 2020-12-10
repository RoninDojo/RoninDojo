#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Start"
         2 "Stop"
         3 "Restart"
         4 "Upgrade"
         5 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
    1)
        echo "Starting Specter Service"
        sudo systemctl start specter
        _sleep 1
        bash -c "$RONIN_SPECTER_MENU"
        #start specter.service and return to same menu
        ;;

    2)
        echo "Stopping Specter Service"
        sudo systemctl stop specter
        _sleep 1
        bash -c "$RONIN_SPECTER_MENU"
        #stop specter.service and return to same menu
        ;;

    3)
        echo "Restartinging Specter Service"
        sudo systemctl restart specter
        _sleep 1
        bash -c "$RONIN_SPECTER_MENU"
        #restart specter.service and return to same menu
        ;;

    4)
        echo "Upgrading Specter Service... then returning to Main Menu"
        bash -c "$HOME"/RoninDojo/Scripts/Install/install-specter.sh
        _sleep 1
        bash -c "$RONIN_SPECTER_MENU"
        #upgrade specter.service and return to same menu
        ;;

    5)
        ronin
        #return to main menu
        ;;
