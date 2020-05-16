#!/bin/bash

. ~/RoninDojo/Scripts/defaults.sh

OPTIONS=(1 "View API key and Hiddenservice"
         2 "View Logs"
         3 "Start Whirlpool"
         4 "Stop Whirlpool"
         5 "Restart Whirlpool"
         6 "Whirlpool Stat Tool"
         7 "Reset Whirlpool"
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
            echo "Showing API pairing key for Whirlpool GUI..."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo -e "${RED}"
            echo "***"
            echo -e "${NC}"
            echo "Whirlpool API key = $WHIRLPOOL_API_KEY"
            echo ""
            echo "Whirlpool API hidden service address = $V3_ADDR_WHIRLPOOL"
            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            read -n 1 -r -s
            bash -c $RONIN_WHIRLPOOL_MENU
            # press any key to return to menu
            ;;
        2)
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
            cd $DOJO_PATH && ./dojo.sh logs whirlpool
            bash -c $RONIN_WHIRLPOOL_MENU
            # view status, return to menu
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Starting Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            docker start whirlpool

            echo -e "${RED}"
            echo "***"
            echo "Don't forget to login to GUI to unlock mixing!"
            echo "***"
            echo -e "${NC}"
            sleep 5s
            bash -c $RONIN_WHIRLPOOL_MENU
            # start whirlpool, return to menu
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Stopping Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            docker stop whirlpool
            bash -c $RONIN_WHIRLPOOL_MENU
            # stop whirlpool, return to menu
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Restarting Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            docker stop whirlpool
            sleep 5s
            docker start whirlpool
            sleep 2s
            bash -c $RONIN_WHIRLPOOL_MENU
            # enable whirlpool at startup, return to menu
            ;;
        6)
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
            bash -c $RONIN_WHIRLPOOL_MENU
            # check for wst install and/or launch wst, return to menu
            ;;
        7)
           echo -e "${RED}"
            echo "***"
            echo "Re-initiating Whirlpool will reset your mix count and generate new API key..."
            echo "***"
            echo -e "${NC}"

            read -p "Are you sure you want to re-initiate Whirlpool? [y/n]" yn
            case $yn in
                [Y/y]* ) echo -e "${RED}"
                         echo "***"
                         echo "Re-initiating Whirlpool..."
                         echo "***"
                         echo -e "${NC}"
                         cd $DOJO_PATH && ./dojo.sh whirlpool reset
                         sleep 1s
                         echo -e "${RED}"
                         echo "***"
                         echo "Re-initation complete...Leave APIkey blank when pairing to GUI"
                         echo "***"
                         echo -e "${NC}"
                         sleep 5s;;

                [N/n]* ) echo -e "${RED}"
                         echo "***"
                         echo "Returning to menu..."
                         echo "***"
                         echo -e "${NC}"
                         sleep 2s
                         break;;
                * ) echo "Please answer yes or no.";;
            esac
            sleep 1s
            bash -c $RONIN_WHIRLPOOL_MENU
            # re-initate whirlpool, return to menu
            ;;
        8)
            bash ~/RoninDojo/ronin
            # return to menu
            ;;
esac
