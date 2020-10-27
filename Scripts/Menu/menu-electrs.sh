#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Start"
         2 "Stop"
         3 "Restart"
         4 "Logs"
         5 "Go Back")

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
                bash "$HOME"/RoninDojo/Scripts/Menu/menu-electrs.sh
                exit
            fi
            # check if electrs is already installed

            echo -e "${RED}"
            echo "***"
            echo "Starting Electrs..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            docker start indexer 1>/dev/null
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-electrs.sh
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
                bash "$HOME"/RoninDojo/Scripts/Menu/menu-electrs.sh
                exit
            fi
            # check if electrs is already installed

            echo -e "${RED}"
            echo "***"
            echo "Stopping Electrs..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            docker stop indexer 1>/dev/null
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-electrs.sh
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
                bash "$HOME"/RoninDojo/Scripts/Menu/menu-electrs.sh
                exit
            fi
            # check if electrs is already installed

            echo -e "${RED}"
            echo "***"
            echo "Restarting Electrs..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            docker restart indexer 1>/dev/null
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-electrs.sh
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
                bash "$HOME"/RoninDojo/Scripts/Menu/menu-electrs.sh
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
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-electrs.sh
            # start electrs, return to menu
            ;;
	5)
            ronin
            # returns to main menu
            ;;
esac
