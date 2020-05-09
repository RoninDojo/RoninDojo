#!/bin/bash

. ~/RoninDojo/Scripts/defaults.sh

OPTIONS=(1 "View API key"
         2 "View Hiddenservice"
         3 "View Logs"
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
            echo "$WHIRLPOOL_API_KEY"
            read -n 1 -r -s
            bash $RONIN_WHIRLPOOL_MENU
            # press any key to return to menu
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Viewing Whirlpool CLI Hidden Service Address..."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C or q to exit at anytime..."
            echo "***"
            echo -e "${NC}"
            echo "Whirlpool API hidden service address = $V3_ADDR_WHIRLPOOL"
            bash $RONIN_WHIRLPOOL_MENU
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Viewing Whirlpool Logs..."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C or q to exit at anytime..."
            echo "***"
            echo -e "${NC}"
            cd $DOJO_PATH && sudo ./dojo.sh logs whirlpool
            bash $RONIN_WHIRLPOOL_MENU
            # view status, return to menu
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Starting Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo docker start whirlpool

            echo -e "${RED}"
            echo "***"
            echo "Don't forget to login to GUI to unlock mixing!"
            echo "***"
            echo -e "${NC}"
            sleep 5s
            bash $RONIN_WHIRLPOOL_MENU
            # start whirlpool, return to menu
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Stopping Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo docker stop whirlpool
            bash $RONIN_WHIRLPOOL_MENU
            # stop whirlpool, return to menu
            ;;
        6)
            echo -e "${RED}"
            echo "***"
            echo "Restarting Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo docker stop whirlpool
            sleep 5s
            sudo docker start whirlpool
            sleep 2s
            bash $RONIN_WHIRLPOOL_MENU
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
            bash $RONIN_WHIRLPOOL_MENU
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
