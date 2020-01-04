#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="Ronin UI"
MENU="Choose one of the following options:"

OPTIONS=(1 "Uninstall Dojo"
         2 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo -e "${RED}"
            echo "***"
            echo "Uninstalling Dojo in 30s..."
            echo "***"
            echo -e "${NC}"
            sleep 3s

            echo -e "${RED}"
            echo "***"
            echo "WARNING: This will uninstall Dojo, use Ctrl+C to exit if needed!"
            echo "***"
            echo -e "${NC}"
            sleep 30s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh uninstall
            # uninstall dojo
            ;;
        2)
            bash ~/RoninDojo/Scripts/Menu/dojo-menu.sh
            # return to main menu
            ;;
esac
