#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "System Setup & Install"
         2 "Software Updates"
         3 "System Monitoring"
         4 "Disk Storage"
         5 "Restart"
         6 "Power Off"
         7 "Next Page"
         8 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
    1)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-install.sh
        # System Setup & Install menu
        ;;
    2)
        bash -c "$RONIN_UPDATES_MENU"
        # System updates menu
        ;;
    3)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-monitoring.sh
        # System monitoring menu
        ;;
    4)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh
        # System storage menu
        ;;
    5)
        if [ -d "$HOME"/dojo ]; then
            echo -e "${RED}"
            echo "***"
            echo "Shutting down Dojo if running..."
            echo "***"
            echo -e "${NC}"
            cd "${DOJO_PATH}" || exit
            _stop_dojo
            # stop dojo

            echo -e "${RED}"
            echo "***"
            echo "Restarting in 5s, or press Ctrl + C to cancel now..."
            echo "***"
            echo -e "${NC}"
            _sleep 5
            sudo systemctl reboot
            # restart machine
        else
            echo -e "${RED}"
            echo "***"
            echo "Restarting in 5s, or press Ctrl + C to cancel now..."
            echo "***"
            echo -e "${NC}"
            _sleep 5
            sudo systemctl reboot
            # restart machine
        fi
        ;;
    6)
        if [ -d "$HOME"/dojo ]; then
            echo -e "${RED}"
            echo "***"
            echo "Shutting down Dojo if running..."
            echo "***"
            echo -e "${NC}"
            cd "${DOJO_PATH}" || exit
            _stop_dojo
            # stop dojo

            echo -e "${RED}"
            echo "***"
            echo "Powering off in 5s, or press Ctrl + C to cancel now..."
            echo "***"
            echo -e "${NC}"
            _sleep 5
            sudo systemctl poweroff
            # power off machine
        else
            echo -e "${RED}"
            echo "***"
            echo "Powering off in 5s, or press Ctrl + C to cancel now..."
            echo "***"
            echo -e "${NC}"
            _sleep 5
            sudo systemctl poweroff
            # power off machine
        fi
        ;;
    7)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system2.sh
        ;;
    8)
        bash -c ronin
        # returns to main menu
        ;;
esac