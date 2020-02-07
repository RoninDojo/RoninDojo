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

OPTIONS=(1 "View Logs"
         2 "Start Electrs"
         3 "Stop Electrs"
         4 "Restart Electrs"
         5 "Show Tor Hiddenservice Address"
         6 "Go Back")

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
            echo "Showing Electrs Logs..."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo ~/dojo/docker/my-dojo/dojo.sh logs indexer
            bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
            # start electrs, return to menu
            ;;
	2)
            echo -e "${RED}"
            echo "***"
            echo "Starting Electrs..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo docker start indexer
            bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
            # start electrs, return to menu
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Stopping Electrs..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo docker stop indexer
            bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
            # start electrs, return to menu
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Restart Electrs"
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo docker restart indexer
            bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
            # enable electrs at startup, return to menu
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Displaying Electrs Tor Hiddenservice Address to connect to Electrum..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            V3_ADDR_ELECTRS=$( sudo docker exec -it tor cat /var/lib/tor/hsv3electrs/hostname )
            echo "Electrs hidden service address (v3) = $V3_ADDR_ELECTRS"
            sleep 1s
            echo "The command to connect to electrum desktop wallet is the follow:"
	    echo "electrum --oneserver --server $V3_ADDR_ELECTRS:50001:t --proxy socks5:127.0.0.1:9050"
            # displaying electrs tor address to connect to electrum

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
            # press any letter return to menu
            ;;
	6)
            bash ~/RoninDojo/ronin
            # returns to main menu
            ;;
esac