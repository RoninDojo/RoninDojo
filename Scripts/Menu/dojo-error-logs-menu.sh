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

OPTIONS=(1 "Bitcoind Logs"
         2 "Db Logs"
         3 "Tor Logs"
         4 "API Logs"
	 5 "Tracker Logs"
	 6 "All Container Logs"
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
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
	    sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs bitcoind -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows dojo bitcoind error logs
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
	    sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs db -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows dojo db error logs
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
	    sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs tor -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows dojo tor error logs
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
	    sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs api -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows dojo api error logs
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
	    sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs tracker -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows dojo tracker error logs
            ;;
        6)
	    echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
	    sleep 2s    
	
            echo -e "${RED}"
            echo "***"
            echo "This command may take some time."
            echo "***"
            echo -e "${NC}"
	    sleep 1s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows all docker container error logs
            ;;
        8)
	    bash ~/RoninDojo/Scripts/Menu/dojo-menu.sh
            # goes back to ronin dojo menu
            ;;
esac
