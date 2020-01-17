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
         7 "Troubleshooting Logs"
         8 "Go Back")

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
            sudo ./dojo.sh logs bitcoind
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows dojo bitcoind logs
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs db
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows dojo db logs
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs tor
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows dojo tor logs
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs api
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows dojo api logs
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs tracker
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows dojo tracker logs
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
            sudo ./dojo.sh logs
            bash ~/RoninDojo/Scripts/Menu/dojo-logs-menu.sh
            # shows logs for all containers
            ;;
        7)
            bash ~/RoninDojo/Scripts/Menu/dojo-error-logs-menu.sh
            # goes to troubleshoot logs menu
            ;;
        8)
            bash ~/RoninDojo/Scripts/Menu/dojo-menu.sh
            # goes back to ronin dojo menu
            ;;
esac
