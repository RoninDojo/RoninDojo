#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Boltzmann"
         2 "Whirlpool Stats Tool"
         3 "Mempool Visualizer"
         4 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
    1)
        bash -c "$RONIN_BOLTZMANN_MENU"
        # Boltzmann menu
        ;;
    2)
        bash -c "$RONIN_WHIRLPOOL_STAT_MENU"
        # check for wst install and/or launch wst, return to menu
        # see defaults.sh
        ;;
    3)
        bash -c "$RONIN_MEMPOOL_MENU"
        # Mempool menu
        ;;
    4)
        bash ronin
        # returns to main menu
        ;;
esac