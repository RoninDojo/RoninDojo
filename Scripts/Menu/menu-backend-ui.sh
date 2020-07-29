#!/bin/bash
# shellcheck source=/dev/null disable=SC2153

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Start"
         2 "Stop"
         3 "Restart"
         4 "Credentials"
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
        if [ ! -d "${BACKEND_DIR}" ]; then
            cat << EOF
${RED}
***
Backend is not installed, installing now...
***
${NC}
EOF
            _install_ronin_ui_backend
            _sleep 2 --msg "Returning to menu in"

            bash -c "${HOME}/RoninDojo/Scripts/Menu/menu-backend-ui.sh"
            exit
        fi
        # check if backend ui is already installed

        cat << EOF
${RED}
***
Starting Backend UI Server...
***
${NC}
EOF
        _sleep 2
        cd "${BACKEND_DIR}" || exit

        # Check if process running, otherwise start it
        if ! pm2 describe "Ronin Backend" &>/dev/null; then
            pm2 start "Ronin Backend"
        fi

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-backend-ui.sh
        # start backend ui, return to menu
        ;;
    2)
        if [ ! -d "${BACKEND_DIR}" ]; then
            cat << EOF
${RED}
***
Backend is not installed, installing now...
***
${NC}
EOF
            _install_ronin_ui_backend
            _sleep 2 --msg "Returning to menu in"

            bash -c "${HOME}/RoninDojo/Scripts/Menu/menu-backend-ui.sh"
            exit
        fi

        cat << EOF
${RED}
***
Stopping Backend UI Server...
***
${NC}
EOF
        _sleep 2
        cd "${BACKEND_DIR}" || exit

        # Check if process running before stopping it
        if pm2 describe "Ronin Backend" &>/dev/null; then
            pm2 stop "Ronin Backend"
        else
            cat << EOF
${RED}
***
Backend UI Server already stopped...
***
${NC}
EOF
        fi

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-backend-ui.sh
        # start backend ui, return to menu
        ;;
    3)
        if [ ! -d "${BACKEND_DIR}" ]; then
            cat << EOF
${RED}
***
Backend is not installed, installing now...
***
${NC}
EOF
            _install_ronin_ui_backend
            _sleep 2 --msg "Returning to menu in"

            bash -c "${HOME}/RoninDojo/Scripts/Menu/menu-backend-ui.sh"
            exit
        fi

        cat << EOF
${RED}
***
Restarting Backend UI Server...
***
${NC}
EOF
        _sleep 2
        cd "${BACKEND_DIR}" || exit

        # Restart service
        pm2 restart "Ronin Backend"

        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-backend-ui.sh
        # start backend ui, return to menu
        ;;
    4)
        if [ ! -d "${BACKEND_DIR}" ]; then
            cat << EOF
${RED}
***
Backend is not installed, installing now...
***
${NC}
EOF
            _install_ronin_ui_backend
            _sleep 2 --msg "Returning to menu in"

            bash -c "${HOME}/RoninDojo/Scripts/Menu/menu-backend-ui.sh"
            exit
        fi

        cd "${BACKEND_DIR}" || exit

        API_KEY=$(grep API_KEY .env|cut -d'=' -f2)
        JWT_SECRET=$(grep JWT_SECRET .env|cut -d'=' -f2)
        BACKEND_PORT=$(grep PORT .env|cut -d'=' -f2)
        BACKEND_TOR=$(sudo cat /var/lib/tor/hidden_service_ronin_backend/hostname)

        cat << EOF
${RED}
***
Showing Backend UI Credentials...
API_KEY     =           ${API_KEY}
JWT_SECRET  =           ${JWT_SECRET}
PORT        =           ${BACKEND_PORT}
TOR_ADDRESS =           http://${BACKEND_TOR}
***
Press any letter to return...
${NC}
EOF
        read -n 1 -r -s
        bash -c "${HOME}"/RoninDojo/Scripts/Menu/menu-backend-ui.sh
        # shows backend ui credentials, returns to menu
        ;;
    5)
        bash -c ronin
        # returns to main menu
        ;;
esac