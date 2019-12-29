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

OPTIONS=(1 "View API key"
	 2 "View Logs"
	 3 "View Status" 
         4 "Start Whirlpool"
         5 "Stop Whirlpool"
         6 "Restart"
         7 "Disable Whirlpool at Startup"
         8 "Update Whirlpool"
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
            echo "Press Ctrl + C or q to exit at anytime..."
            echo "***"
            echo -e "${NC}"
            cat ~/whirlpool/whirlpool-cli-config.properties | grep cli.apiKey= | cut -c 12-
            bash ~/RoninDojo/Scripts/Menu/whirlpool-menu.sh
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
            bash ~/RoninDojo/Scripts/Menu/whirlpool-menu.sh
            # view whirlpool cli logs via journalctl, return to menui
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
            sudo systemctl status whirlpool
            bash ~/RoninDojo/Scripts/Menu/whirlpool-menu.sh
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
            bash ~/RoninDojo/Scripts/Menu/whirlpool-menu.sh
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
            bash ~/RoninDojo/Scripts/Menu/whirlpool-menu.sh
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
            bash ~/RoninDojo/Scripts/Menu/whirlpool-menu.sh
            # enable whirlpool at startup, return to menu
            ;;
        7)
            echo -e "${RED}"
            echo "***"
            echo "Disable Whirlpool at Startup..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo systemctl disable whirlpool
            bash ~/RoninDojo/Scripts/Menu/whirlpool-menu.sh
            # disable whirlpool at startup, return to menu
            ;;
        8)
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
            bash ~/RoninDojo/Scripts/Menu/whirlpool-menu.sh
            ;;
        9)
            bash ~/RoninDojo/ronin
            # return to menu
            ;;
esac
