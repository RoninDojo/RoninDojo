#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Boltzmann Calculator"
         2 "Whirlpool Stat Tool"
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
            bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-boltzmann.sh
            # sent to Boltzmann Calculator
            break;;
        
        2)
            bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh
            # send to WST menu
            break;;
        3)
            ronin
            # returns to main menu
            break;;
esac