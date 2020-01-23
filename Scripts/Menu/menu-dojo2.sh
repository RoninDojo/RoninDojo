#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="RoninDojo"
MENU="Choose one of the following options:"

OPTIONS=(1 "Uninstall Dojo"
         2 "Receive Block Data from Backup"
         3 "Send Block Data to Backup"
         4 "Go Back")

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

            echo -e "${RED}"
            echo "***"
            echo "Complete!"
            echo "***"
            echo -e "${NC}"
            bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh
            # return to menu
            ;;
        2)
            bash ~/RoninDojo/Scripts/Install/install-receive-block-data.sh
            # copy block data from backup drive
            ;;
        3)
            bash ~/RoninDojo/Scripts/Install/install-send-block-data.sh
            # copy block data to backup drive
            ;;
        4)
            bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
            # return to main menu
            ;;
esac
