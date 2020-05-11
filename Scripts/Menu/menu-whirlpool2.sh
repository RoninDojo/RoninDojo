#!/bin/bash

. ~/RoninDojo/Scripts/defaults.sh
. ~/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Re-initiate Whirlpool"
         2 "Go Back")

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
                         cd ~/dojo/docker/my-dojo && ./dojo.sh whirlpool reset
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

        2)
            bash -c $RONIN_WHIRLPOOL_MENU
	          # return to menu
	    ;;
esac
