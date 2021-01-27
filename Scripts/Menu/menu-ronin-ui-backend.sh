#!/bin/bash
# shellcheck source=/dev/null disable=SC2153

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Start"
         2 "Stop"
         3 "Restart"
         4 "Status"
         5 "Logs"
         6 "Go Back")

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
        if pm2 describe "Ronin Backend" | grep status | grep stopped 1>/dev/null; then
            cat <<EOF
${RED}
***
Starting UI Backend Server...
***
${NC}
EOF
            _sleep 2
            cd "${RONIN_UI_BACKEND_DIR}" || exit

            pm2 start "Ronin Backend"
        else
            cat <<EOF
${RED}
***
UI Backend already started...
***
${NC}
EOF
            _sleep 2
        fi

        _pause return
        # press to return is needed so the user has time to see outputs

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        # start Ronin UI Backend, return to menu
        ;;
    2)
        # Check if process running before stopping it
        if pm2 describe "Ronin Backend" &>/dev/null; then
            cat <<EOF
${RED}
***
Stopping UI Backend Server...
***
${NC}
EOF
            _sleep 2
            cd "${RONIN_UI_BACKEND_DIR}" || exit

            pm2 stop "Ronin Backend"
        else
            cat <<EOF
${RED}
***
UI Backend Server already stopped...
***
${NC}
EOF
        fi

        _pause return
        # press to return is needed so the user has time to see outputs

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        # start Ronin UI Backend, return to menu
        ;;
    3)
        cat <<EOF
${RED}
***
Restarting UI Backend Server...
***
${NC}
EOF
        _sleep 2
        cd "${RONIN_UI_BACKEND_DIR}" || exit

        pm2 restart "Ronin Backend" 1>/dev/null
        # restart service

        _pause return
        # press to return is needed so the user has time to see outputs

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        # start Ronin UI Backend, return to menu
        ;;
#     4)
#         cat <<EOF
# ${RED}
# ***
# Showing UI Backend Status...
# ***
# ${NC}
# EOF
#         cd "${RONIN_UI_BACKEND_DIR}" || exit
#         pm2 status

#         _pause return
#         bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
#         ;;
    4)
        cat <<EOF
${RED}
***
Showing UI Backend Status...
***
${NC}
EOF

        cd "${RONIN_UI_BACKEND_DIR}" || exit
        pm2 status

        _pause return
        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        ;;
    5)
        cat <<EOF
${RED}
***
Showing UI Backend Logs...
***
${NC}
EOF

        cat <<EOF
${RED}
***
Press "q" key to exit at any time...
***
${NC}
EOF
        cd "${RONIN_UI_BACKEND_DIR}" || exit
        _sleep 5 # Workaround until a proper FIX
        less --force logs/combined.log

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        ;;

    6)
        ronin
        # returns to main menu
        ;;
esac
