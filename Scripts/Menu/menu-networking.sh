#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Firewall"
         2 "Secure Shell (SSH)"
         3 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
    1)
        bash -c "${ronin_firewall_menu}"
        ;;
    2)
        bash -c "${ronin_ssh_menu}"
        ;;
    3)
        bash -c "${ronin_system_menu2}"
        # returns to menu
        ;;
esac

exit