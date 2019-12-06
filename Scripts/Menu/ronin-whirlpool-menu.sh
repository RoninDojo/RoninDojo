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
            echo "Press Ctrl + C or q to exit at anytime..."
            echo "***"
            echo -e "${NC}"
            sleep 3s
            # display logs
            bash ~/RoninDojo/Scripts/Menu/ronin-whirlpool-menu.sh
            # press any key to return to menu
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Starting Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo systemctl start whirlpool
            echo "Don't forget to login to GUI to unlock mixing"
            sleep 1s
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
            sudo systemctl stop whirlpool
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
            sudo systemctl enable whirlpool
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
            sudo systemctl disable whirlpool
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
            cd ~/whirlpool
            sudo systemctl stop whirlpool > /dev/null 2>&1
            sudo rm -rf *.jar
            wget -O whirlpool.jar https://github.com/Samourai-Wallet/whirlpool-client-cli/releases/download/0.9.3/whirlpool-client-cli-0.9.3-run.jar
            sudo systemctl start whirlpool
            bash ~/RoninDojo/Scripts/Menu/ronin-whirlpool-menu.sh
            ;;
        7)
            bash ~/RoninDojo/ronin
            # return to menu
            ;;
esac
