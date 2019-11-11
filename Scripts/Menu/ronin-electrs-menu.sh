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
         2 "Start Electrs"
	 3 "Stop Electrs"
         4 "Enable Electrs at Startup"
         5 "Disable Electrs at Startup"
	 6 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
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
            sudo journalctl -e electrs.service
            bash ~/RoninDojo/Scripts/Menu/ronin-electrs-menu.sh
            # start electrs, return to menu
            ;;
	2)
            echo -e "${RED}"
            echo "***"
            echo "Starting Electrs..."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            # start here
            bash ~/RoninDojo/Scripts/Menu/ronin-electrs-menu.sh
            # start electrs, return to menu
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Stopping Electrs..."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            # stop here
            bash ~/RoninDojo/Scripts/Menu/ronin-electrs-menu.sh
            # start electrs, return to menu
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Enable Electrs at Startup..."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            # start here
            bash ~/RoninDojo/Scripts/Menu/ronin-electrs-menu.sh
            # enable electrs at startup, return to menu
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Disable Electrs at Startup..."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            # stop here
            bash ~/RoninDojo/Scripts/Menu/ronin-electrs-menu.sh
            # disable electrs at startup, return to menu
            ;;
        6)
            bash ~/RoninDojo/ronin.sh
            # returns to main menu
            ;;
esac
