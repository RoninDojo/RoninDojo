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

OPTIONS=(1 "View API key"
         2 "View Logs"
         3 "View Status"
         4 "Start Whirlpool"
         5 "Stop Whirlpool"
         6 "Restart"
         7 "Re-initiate Whirlpool"
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
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            cat ~/whirlpool/whirlpool-cli-config.properties | grep cli.apiKey= | cut -c 12-
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
            sudo systemctl status whirlpool
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
            echo "Re-initiating Whirlpool will reset your mix count and generate new API key..."
            echo "***"
            read -p "Are you sure you want to re-initiate Whirlpool? [y/n]" yn
            case $yn in
                [Y/y]* ) echo "Re-initiating Whirlpool...";
                        sudo systemctl stop whirlpool;
                        cd ~/whirlpool;
                        rm -rf *.json whirlpool-cli-config.properties;
                        sudo systemctl start whirlpool;
                        echo "Re-initation complete...";
                        sleep 1s;
                        echo "Paste your pairing payload into whirlpool GUI";;
                [N/n]* ) echo "Returning to menu...";;
                     * ) echo "Please answer yes or no.";;
            esac
            echo -e "${NC}"
            sleep 1s
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # re-initate whirlpool, return to menu
            ;;
        8)
            echo -e "${RED}"
            echo "***"
            echo "Checking for updates..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            echo "Upgrading to Whirlpool Client CLI 0.10.2..."
            sleep 2s
            echo "Press Ctrl+C to exit..."
            sleep 5s
            cd ~/whirlpool
            sudo systemctl stop whirlpool > /dev/null 2>&1
            sudo rm -rf *.jar
            wget -O whirlpool.jar https://github.com/Samourai-Wallet/whirlpool-client-cli/releases/download/0.10.2/whirlpool-client-cli-0.10.2-run.jar
            sudo systemctl start whirlpool
            echo "Upgrade complete... head to GUI to unlock mixing."
            sleep 2s
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            ;;
        9)
            bash ~/RoninDojo/ronin
            # return to menu
            ;;
esac
