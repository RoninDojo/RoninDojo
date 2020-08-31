#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Start"
         2 "Stop"
         3 "Restart"
         4 "Logs"
         5 "Reset"
         6 "Credentials"
         7 "Whirlpool Stat Tool"
         8 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo -e "${RED}"
            echo "***"
            echo "Starting Whirlpool..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            docker start whirlpool 1>/dev/null

            echo -e "${RED}"
            echo "***"
            echo "Don't forget to login to GUI to unlock mixing!"
            echo "***"
            echo -e "${NC}"
            _sleep 5
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # see defaults.sh
            # start whirlpool, return to menu
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Stopping Whirlpool..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            docker stop whirlpool 1>/dev/null
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # stop whirlpool, return to menu
            # see defaults.sh
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Restarting Whirlpool..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            docker stop whirlpool 1>/dev/null
            _sleep 5
            docker start whirlpool 1>/dev/null
            _sleep 2
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # enable whirlpool at startup, return to menu
            # see defaults.sh
	        ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Viewing Whirlpool Logs..."
            echo "***"
            echo -e "${NC}"
            _sleep 2

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl+C to exit at anytime..."
            echo "***"
            echo -e "${NC}"
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs whirlpool
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # view logs, return to menu
            # see defaults.sh
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Re-initiating Whirlpool will reset your mix count and generate new API key..."
            echo "***"
            echo -e "${NC}"

            read -rp "Are you sure you want to re-initiate Whirlpool? [y/n]" yn
            case $yn in
                [Y/y]* ) echo -e "${RED}"
                         echo "***"
                         echo "Re-initiating Whirlpool..."
                         echo "***"
                         echo -e "${NC}"
                         cd "$DOJO_PATH" || exit
                         ./dojo.sh whirlpool reset
                         _sleep
                         echo -e "${RED}"
                         echo "***"
                         echo "Re-initation complete...Leave APIkey blank when pairing to GUI"
                         echo "***"
                         echo -e "${NC}"
                         _sleep 5
                         ;;

                [N/n]* ) echo -e "${RED}"
                         echo "***"
                         echo "Returning to menu..."
                         echo "***"
                         echo -e "${NC}"
                         _sleep 2
                         ;;
                * ) echo "Please answer yes or no.";;
            esac
            _sleep
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # re-initate whirlpool, return to menu
            # see defaults.sh
            ;;
        6)
            cat << WHIRLPOOL
${RED}
***
Samourai Whirlpool CLI Credentials
***

***
${NC}
Whirlpool API Key      = ${WHIRLPOOL_API_KEY:-Whirlpool not Initiated yet. Pair wallet with GUI}
Whirlpool Tor URL      = http://${V3_ADDR_WHIRLPOOL}
${RED}
***
Press any letter to return...
***
${NC}
WHIRLPOOL
            read -n 1 -r -s
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # press any key to return to menu
            # see defaults.sh
            ;;
        7)
            echo -e "${RED}"
            echo "***"
            echo "Starting Whirlpool Stat Tool..."
            echo "Press Ctrl+C to exit"
            echo "***"
            echo -e "${NC}"
            _sleep
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh
            echo -e "${NC}"
            _sleep
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # check for wst install and/or launch wst, return to menu
            # see defaults.sh
            ;;
        8)
            bash "$HOME"/RoninDojo/ronin
            # return to menu
            ;;
esac
