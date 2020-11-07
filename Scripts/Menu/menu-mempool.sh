#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Start"
         2 "Stop"
         3 "Restart"
         4 "Logs"
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
        cat <<MEMPOOL
${RED}
***
Starting Mempool...
***
${NC}
MEMPOOL
        docker start mempool 1>/dev/null

        _sleep 5
        bash -c "$RONIN_MEMPOOL_MENU"
        # see defaults.sh
        # start mempool, return to menu
        ;;
    2)
        cat <<MEMPOOL
${RED}
***
Stopping Mempool...
***
${NC}
MEMPOOL
        docker stop mempool 1>/dev/null
        bash -c "$RONIN_MEMPOOL_MENU"
        # stop mempool, return to menu
        # see defaults.sh
        ;;
    3)
        cat <<MEMPOOL
${RED}
***
Restarting Mempool...
***
${NC}
MEMPOOL
        docker stop mempool 1>/dev/null
        _sleep 5
        docker start mempool 1>/dev/null
        _sleep 2
        bash -c "$RONIN_MEMPOOL_MENU"
        # start mempool, return to menu
        # see defaults.sh
        ;;
    4)
        cat <<MEMPOOL
${RED}
***
Viewing Mempool Logs...
***
${NC}
MEMPOOL
        _sleep 2

        cat <<MEMPOOL
${RED}
***
Press Ctrl+C to exit at anytime...
***
${NC}
MEMPOOL
        cd "$dojo_path_my_dojo" || exit
        ./dojo.sh logs mempool
        bash -c "$RONIN_MEMPOOL_MENU"
        # view logs, return to menu
        # see defaults.sh
        ;;
    5)
        ronin
        # return to menu
        ;;
esac
