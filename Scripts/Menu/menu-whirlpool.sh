#!/bin/bash

RED=$(tput setaf 1)
# used for color with ${RED}
NC=$(tput sgr0)
# No Color

HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="RoninDojo"
MENU="Choose one of the following options:"

OPTIONS=(1 "View API key"
         2 "View Logs"
         3 "View Status"
         4 "Start Whirlpool"
         5 "Stop Whirlpool"
         6 "Restart Whirlpool"
         7 "Whirlpool Stat Tool"
         8 "Next Page"
         9 "Go Back")

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
            echo "Showing API pairing key for Whirlpool GUI..."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            grep cli.apiKey= ~/whirlpool/whirlpool-cli-config.properties | cut -c 12-
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # press any key to return to menu
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Viewing Whirlpool CLI Logs..."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C or q to exit at anytime..."
            echo "***"
            echo -e "${NC}"
            sudo journalctl -r -u whirlpool.service
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # view whirlpool cli logs via journalctl, return to menu
            # note that it's in order of newest to oldest, and blob means that it's repeat information
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Viewing Whirlpool Status..."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C or q to exit at anytime..."
            echo "***"
            echo -e "${NC}"
            sudo watch -n 0.2 systemctl status whirlpool --lines=10
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # view status, return to menu
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Starting Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo systemctl start whirlpool

            echo -e "${RED}"
            echo "***"
            echo "Don't forget to login to GUI to unlock mixing!"
            echo "***"
            echo -e "${NC}"
            sleep 5s
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # start whirlpool, return to menu
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Stopping Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo systemctl stop whirlpool
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # stop whirlpool, return to menu
            ;;
        6)
            echo -e "${RED}"
            echo "***"
            echo "Restarting Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo systemctl restart whirlpool
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # enable whirlpool at startup, return to menu
            ;;
        7)
            echo -e "${RED}"
            echo "***"
            echo "Starting Whirlpool Stat Tool..."
            echo "Press Ctrl+C to exit"
            echo "***"
            echo -e "${NC}"
            sleep 1s
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh
            echo -e "${NC}"
            sleep 1s
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # check for wst install and/or launch wst, return to menu
            ;;
        8)
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool2.sh
            # Go to next page
            ;;
        9)
            bash ~/RoninDojo/ronin
            # return to menu
            ;;
esac
