#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
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
        if ! _is_mempool ; then
            cat <<EOF
${red}
***
Mempool Space Visualizer is not installed...
***
${nc}
EOF
            _sleep
            _pause return
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${red}
***
Starting Mempool Space Visualizer...
***
${nc}
EOF
            docker start mempool_api mempool_db mempool_web 1>/dev/null
            _sleep 5
            _pause return
            bash -c "${ronin_mempool_menu}"
            # see defaults.sh
            # start mempool, return to menu
        fi
        ;;
    2)
        if ! _is_mempool ; then
            cat <<EOF
${red}
***
Mempool Space Visualizer is not installed...
***
${nc}
EOF
            _sleep
            _pause return
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${red}
***
Stopping Mempool Space Visualizer...
***
${nc}
EOF
            docker stop mempool_api mempool_db mempool_web 1>/dev/null
            _pause return
            bash -c "${ronin_mempool_menu}"
            # stop mempool, return to menu
            # see defaults.sh
        fi
        ;;
    3)
        if ! _is_mempool ; then
            cat <<EOF
${red}
***
Mempool Space Visualizer is not installed...
***
${nc}
EOF
            _sleep
            _pause return
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${red}
***
Restarting Mempool Space Visualizer...
***
${nc}
EOF
            docker stop mempool_api mempool_db mempool_web 1>/dev/null
            _sleep 5

            docker start mempool_api mempool_db mempool_web 1>/dev/null
            _sleep

            _pause return
            bash -c "${ronin_mempool_menu}"
            # start mempool, return to menu
            # see defaults.sh
        fi
        ;;
    4)
        if ! _is_mempool ; then
            cat <<EOF
${red}
***
Mempool Space Visualizer is not installed...
***
${nc}
EOF
            _sleep
            _pause return
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${red}
***
Viewing Mempool Space Visualizer Logs...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
Press Ctrl+C to exit at anytime...
***
${nc}
EOF
            cd "$dojo_path_my_dojo" || exit
            ./dojo.sh logs mempool_api
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