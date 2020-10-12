#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh

OPTIONS=(1 "Boltzmann"
         2 "Go Back")

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
        bash ronin
        # returns to main menu
        ;;
esac