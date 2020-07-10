#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Start Electrs"
         2 "Stop Electrs"
         3 "Restart Electrs"
         4 "View Logs"
         5 "Tor Hidden Service"
         6 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
	1)
            if [ ! -f "${DOJO_PATH}"/indexer/electrs.toml ]; then
                echo -e "${RED}"
                echo "***"
                echo "Electrs is not installed!"
                echo "***"
                echo -e "${NC}"
                _sleep 2

                echo -e "${RED}"
                echo "***"
                echo "Returning to menu..."
                echo "***"
                echo -e "${NC}"
                _sleep
                bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
                exit
            fi
            # check if electrs is already installed

            echo -e "${RED}"
            echo "***"
            echo "Starting Electrs..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            docker start indexer
            bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
            # start electrs, return to menu
            ;;
        2)
            if [ ! -f "${DOJO_PATH}"/indexer/electrs.toml ]; then
                echo -e "${RED}"
                echo "***"
                echo "Electrs is not installed!"
                echo "***"
                echo -e "${NC}"
                _sleep 2

                echo -e "${RED}"
                echo "***"
                echo "Returning to menu..."
                echo "***"
                echo -e "${NC}"
                _sleep
                bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
                exit
            fi
            # check if electrs is already installed

            echo -e "${RED}"
            echo "***"
            echo "Stopping Electrs..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            docker stop indexer
            bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
            # stop electrs, return to menu
            ;;
        3)
            if [ ! -f "${DOJO_PATH}"/indexer/electrs.toml ]; then
                echo -e "${RED}"
                echo "***"
                echo "Electrs is not installed!"
                echo "***"
                echo -e "${NC}"
                _sleep 2

                echo -e "${RED}"
                echo "***"
                echo "Returning to menu..."
                echo "***"
                echo -e "${NC}"
                _sleep
                bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
                exit
            fi
            # check if electrs is already installed

            echo -e "${RED}"
            echo "***"
            echo "Restarting Electrs..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            docker restart indexer
            bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
            # restart electrs, return to menu
            ;;
        4)
            if [ ! -f "${DOJO_PATH}"/indexer/electrs.toml ]; then
                echo -e "${RED}"
                echo "***"
                echo "Electrs is not installed!"
                echo "***"
                echo -e "${NC}"
                _sleep 2

                echo -e "${RED}"
                echo "***"
                echo "Returning to menu..."
                echo "***"
                echo -e "${NC}"
                _sleep
                bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
                exit
            fi
            # check if electrs is already installed

            echo -e "${RED}"
            echo "***"
            echo "Showing Electrs Logs..."
            echo "***"
            _sleep

            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs indexer
            bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
            # start electrs, return to menu
            ;;
        5)
            if [ ! -f "${DOJO_PATH}"/indexer/electrs.toml ]; then
                echo -e "${RED}"
                echo "***"
                echo "Electrs is not installed!"
                echo "***"
                echo -e "${NC}"
                _sleep 2

                echo -e "${RED}"
                echo "***"
                echo "Returning to menu..."
                echo "***"
                echo -e "${NC}"
                _sleep
                bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
                exit
            fi
            # check if electrs is already installed

            echo -e "${RED}"
            echo "***"
            echo "Displaying Electrs Tor Hiddenservice address..."
            echo "***"
            echo -e "${NC}"
            echo "Electrs hidden service address (v3) = $V3_ADDR_ELECTRS"
            _sleep
            # displaying electrs tor address to connect to electrum

            echo -e "${RED}"
            echo "***"
            echo "Check the RoninDojo Wiki for pairing information."
            echo "***"
            echo -e "${NC}"
            _sleep

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/menu-electrs.sh
            # return to menu
            ;;
	6)
            bash ~/RoninDojo/ronin
            # returns to main menu
            ;;
esac
