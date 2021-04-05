#!/bin/bash
# shellcheck source=/dev/null disable=SC2153,SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Start"
         2 "Stop"
         3 "Restart"
         4 "Status"
         5 "Logs"
         6 "Reset"
         7 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
	1)
        # Check if process running, otherwise start it
        if pm2 describe "RoninUI" | grep status | grep stopped 1>/dev/null; then
            cat <<EOF
${red}
***
Starting Ronin UI...
***
${nc}
EOF
            _sleep
            cd "${ronin_ui_path}" || exit

            pm2 start "RoninUI"
        else
            cat <<EOF
${red}
***
Ronin UI already started...
***
${nc}
EOF
            _sleep
        fi

        _pause return
        # press to return is needed so the user has time to see outputs

        bash -c "${ronin_ui_menu}"
        # start Ronin UI, return to menu
        ;;
    2)
        # Check if process running before stopping it
        if pm2 describe "RoninUI" &>/dev/null; then
            cat <<EOF
${red}
***
Stopping Ronin UI...
***
${nc}
EOF
            _sleep
            cd "${ronin_ui_path}" || exit

            pm2 stop "RoninUI"
        else
            cat <<EOF
${red}
***
Ronin UI already stopped...
***
${nc}
EOF
        fi

        _pause return
        # press to return is needed so the user has time to see outputs

        bash -c "${ronin_ui_menu}"
        # start Ronin UI, return to menu
        ;;
    3)
        cat <<EOF
${red}
***
Restarting Ronin UI...
***
${nc}
EOF
        _sleep
        cd "${ronin_ui_path}" || exit

        pm2 restart "RoninUI" 1>/dev/null
        # restart service

        _pause return
        # press to return is needed so the user has time to see outputs

        bash -c "${ronin_ui_menu}"
        # start Ronin UI, return to menu
        ;;
    4)
        cat <<EOF
${red}
***
Showing Ronin UI Status...
***
${nc}
EOF

        cd "${ronin_ui_path}" || exit
        pm2 status

        _pause return
        bash -c "${ronin_ui_menu}"
        ;;
    5)
        cat <<EOF
${red}
***
Showing Ronin UI Logs...
***
${nc}
EOF

        cat <<EOF
${red}
***
Press "q" key to exit at any time...
***
${nc}
EOF
        cd "${ronin_ui_path}" || exit

        _sleep 5 # Workaround until a proper FIX!!!
        less --force logs/combined.log

        bash -c "${ronin_ui_menu}"
        ;;
    6)
        cat <<EOF
${red}
***
Resetting Ronin UI...
***
${nc}
EOF

        cd "${ronin_ui_path}" || exit

        test -f ronin-ui.dat && rm ronin-ui.dat

        _pause return

        bash -c "${ronin_ui_menu}"
        ;;
    7)
        ronin
        # returns to main menu
        ;;
esac