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

OPTIONS=(1 "View Logs"
         2 "Start Whirlpool"
         3 "Stop Whirlpool"
         4 "Enable Whirlpool at Startup"
         5 "Disable Whirlpool at Startup"
         6 "Update Whirlpool"
         7 "Go Back")

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
            echo "Showing Logs..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            
            echo -e "${RED}"
            echo "***"
            echo "Use Ctrl+C to exit anytime."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            sudo journalctl -e whirlpool.service
            bash ~/RoninDojo/Scripts/Menu/ronin-whirlpool-menu.sh
            # start whirlpool, return to menu
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Starting Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            # start here
            bash ~/RoninDojo/Scripts/Menu/ronin-whirlpool-menu.sh
            # start whirlpool, return to menu
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Stopping Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            # stop here
            bash ~/RoninDojo/Scripts/Menu/ronin-whirlpool-menu.sh
            # stop whirlpool, return to menu
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Enable Whirlpool at Startup..."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            # start here
            bash ~/RoninDojo/Scripts/Menu/ronin-whirlpool-menu.sh
            # enable whirlpool at startup, return to menu
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Disable Whirlpool at Startup..."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            # stop here
            bash ~/RoninDojo/Scripts/Menu/ronin-whirlpool-menu.sh
            # disable whirlpool at startup, return to menu
            ;;
        6)
            echo -e "${RED}"
            echo "***"
            echo "Checking for updates..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            # check for updates here
            bash ~/RoninDojo/Scripts/Menu/ronin-whirlpool-menu.sh
            # check for updates, return to menu
            ;;
        7)
            bash ~/RoninDojo/ronin
            # return to menu
            ;;
esac
