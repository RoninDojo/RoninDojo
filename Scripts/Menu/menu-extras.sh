#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh

OPTIONS=(1 "Boltzmann"
         2 "Whirlpool Stats Tool"
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
        bash "$RONIN_BOLTZMANN_MENU"
        # Boltzmann menu
        ;;
    2)
        cat <<WST
${RED}
***
Starting Whirlpool Stats Tool...
***
${NC}
WST
        _sleep
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh
        # check for wst install and/or launch wst, return to menu
        # see defaults.sh
        ;;
    3)
        bash ronin
        # returns to main menu
        ;;
esac