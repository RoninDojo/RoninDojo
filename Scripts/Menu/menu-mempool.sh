#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

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
        if ! _mempool_check ; then
            cat <<EOF
${RED}
***
Mempool Space Visualizer is not installed...
***
${NC}
EOF
            _sleep 2
            _pause return
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${RED}
***
Starting Mempool Space Visualizer...
***
${NC}
EOF
            docker start mempool 1>/dev/null
            _sleep 5
            _pause return
            bash -c "${ronin_mempool_menu}"
            # see defaults.sh
            # start mempool, return to menu
        fi
        ;;
    2)
        if ! _mempool_check ; then
            cat <<EOF
${RED}
***
Mempool Space Visualizer is not installed...
***
${NC}
EOF
            _sleep 2
            _pause return
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${RED}
***
Stopping Mempool Space Visualizer...
***
${NC}
EOF
            docker stop mempool 1>/dev/null
            _pause return
            bash -c "${ronin_mempool_menu}"
            # stop mempool, return to menu
            # see defaults.sh
        fi
        ;;
    3)
        if ! _mempool_check ; then
            cat <<EOF
${RED}
***
Mempool Space Visualizer is not installed...
***
${NC}
EOF
            _sleep 2
            _pause return
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${RED}
***
Restarting Mempool Space Visualizer...
***
${NC}
EOF
            docker stop mempool 1>/dev/null
            _sleep 5
            docker start mempool 1>/dev/null
            _sleep 2

            _pause return
            bash -c "${ronin_mempool_menu}"
            # start mempool, return to menu
            # see defaults.sh
        fi
        ;;
    4)
        if ! _mempool_check ; then
            cat <<EOF
${RED}
***
Mempool Space Visualizer is not installed...
***
${NC}
EOF
            _sleep 2
            _pause return
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${RED}
***
Viewing Mempool Space Visualizer Logs...
***
${NC}
EOF
            _sleep 2

            cat <<EOF
${RED}
***
Press Ctrl+C to exit at anytime...
***
${NC}
EOF
            cd "$dojo_path_my_dojo" || exit
            ./dojo.sh logs mempool
            bash -c "${ronin_mempool_menu}"
            # view logs, return to menu
            # see defaults.sh
        fi
        ;;
    5)
        ronin
        # return to menu
        ;;
esac
