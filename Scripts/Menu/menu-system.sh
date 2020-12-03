#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Disk Storage"
         2 "Power Off"
         3 "Reboot"
         4 "Software Updates"
         5 "System Monitoring"
         6 "System Setup & Install"
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
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh
        # System storage menu
        ;;
    2)
        if [ -d "$HOME"/dojo ]; then
            echo -e "${RED}"
            echo "***"
            echo "Shutting down Dojo if running..."
            echo "***"
            echo -e "${NC}"
            cd "${dojo_path_my_dojo}" || exit
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
    3)
        if [ -d "$HOME"/dojo ]; then
            echo -e "${RED}"
            echo "***"
            echo "Shutting down Dojo if running..."
            echo "***"
            echo -e "${NC}"
            cd "${dojo_path_my_dojo}" || exit
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

    4)
        bash -c "$RONIN_UPDATES_MENU"
        # System updates menu
        ;;
    5)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-monitoring.sh
        # System monitoring menu
        ;;
    6)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-install.sh
        # System Setup & Install menu
        ;;
    7)
        bash -c "${RONIN_SYSTEM_MENU2}"
        ;;
    8)
        ronin
        # returns to main menu
        ;;
esac