#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Firewall"
         2 "Lock Root User"
         3 "Unlock Root User"
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
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall.sh
        ;;
	2)
        echo -e "${RED}"
        echo "***"
        echo "Locking Root User..."
        echo "***"
        echo -e "${NC}"
        _sleep 2
        sudo passwd -l root
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system2.sh
        # uses passwd to lock root user, returns to menu
        ;;
	3)
        echo -e "${RED}"
        echo "***"
        echo "Unlocking Root User..."
        echo "***"
        echo -e "${NC}"
        _sleep 2
        sudo passwd -u root
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system2.sh
        # uses passwd to unlock root user, returns to menu
        ;;
    4)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system.sh
        # returns to menu
        ;;
esac