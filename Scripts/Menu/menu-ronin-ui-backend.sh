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
         6 "Credentials"
         7 "Install"
         8 "Uninstall"
         9 "Go Back")

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
            cat << EOF
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
            cat << EOF
${RED}
***
UI Backend already started...
***
${NC}
EOF
            _sleep 2
        fi

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        # start Ronin UI Backend, return to menu
        ;;
    2)
        # Check if process running before stopping it
        if pm2 describe "Ronin Backend" &>/dev/null; then
            cat << EOF
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
            cat << EOF
${RED}
***
UI Backend Server already stopped...
***
${NC}
EOF
        fi

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        # start Ronin UI Backend, return to menu
        ;;
    3)
        cat << EOF
${RED}
***
Restarting UI Backend Server...
***
${NC}
EOF
        _sleep 2
        cd "${RONIN_UI_BACKEND_DIR}" || exit

        # Restart service
        pm2 restart "Ronin Backend" 1>/dev/null

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        # start Ronin UI Backend, return to menu
        ;;
    4)
        cat << EOF
${RED}
***
Press any key to return.
***
${NC}
EOF
        cd "${RONIN_UI_BACKEND_DIR}" || exit
        pm2 status

        read -n 1 -r -s
        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        ;;
    5)
        cat << EOF
${RED}
***
Press q key to exit at any time.
***
${NC}
EOF
        cd "${RONIN_UI_BACKEND_DIR}" || exit
        _sleep 5 # Workaround until a proper FIX
        less --force logs/combined.log

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        ;;
    6)
        cd "${RONIN_UI_BACKEND_DIR}" || exit

        API_KEY=$(grep API_KEY .env|cut -d'=' -f2)
        JWT_SECRET=$(grep JWT_SECRET .env|cut -d'=' -f2)
        BACKEND_PORT=$(grep PORT .env|cut -d'=' -f2)
        BACKEND_TOR=$(sudo cat /var/lib/tor/hidden_service_ronin_backend/hostname)

        cat << EOF
${RED}
***
Ronin UI Backend Credentials
***
${NC}

API_KEY     =   ${API_KEY}
JWT_SECRET  =   ${JWT_SECRET}
PORT        =   ${BACKEND_PORT}
TOR_ADDRESS =   http://${BACKEND_TOR}

${RED}
***
Press any letter to return...
***
${NC}
EOF
        read -n 1 -r -s
        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        # shows Ronin UI Backend credentials, returns to menu
        ;;
    7)
        cat << EOF
${RED}
***
Installing Ronin UI Backend...
Press Ctrl+C to cancel at anytime
***
${NC}
EOF
        _sleep 5 --msg "Installing in"

        _install_ronin_ui_backend

        _sleep 5 --msg "Sucessfully Installed, returning to menu in"

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        ;;
    8)
        cd "${RONIN_UI_BACKEND_DIR}" || exit

        cat << EOF
${RED}
***
Uninstalling Ronin UI Backend...
Press Ctrl+C to cancel at anytime
***
${NC}
EOF
        _sleep 5 --msg "Uninstall in"

        # Delete app from process list
        pm2 delete "Ronin Backend" &>/dev/null

        # dump all processes for resurrecting them later
        pm2 save 1>/dev/null

        # Remove ${RONIN_UI_BACKEND_DIR}
        cd "${HOME}" || exit
        rm -rf "${RONIN_UI_BACKEND_DIR}" || exit

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh
        ;;
    9)
        bash -c ronin
        # returns to main menu
        ;;
esac
