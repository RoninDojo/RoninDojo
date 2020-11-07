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
        if ! _is_electrs; then
            bash -c "$RONIN_ELECTRS_MENU"
            exit 1
        fi
        # check if electrs is already installed

        echo -e "${RED}"
        echo "***"
        echo "Starting Electrs..."
        echo "***"
        echo -e "${NC}"
        _sleep 2
        docker start indexer 1>/dev/null
        bash -c "$RONIN_ELECTRS_MENU"
        # start electrs, return to menu
        ;;
    2)
        if ! _is_electrs; then
            bash -c "$RONIN_ELECTRS_MENU"
            exit 1
        fi
        # check if electrs is already installed

        echo -e "${RED}"
        echo "***"
        echo "Stopping Electrs..."
        echo "***"
        echo -e "${NC}"
        _sleep 2
        docker stop indexer 1>/dev/null
        bash -c "$RONIN_ELECTRS_MENU"
        # stop electrs, return to menu
        ;;
    3)
        if ! _is_electrs; then
            bash -c "$RONIN_ELECTRS_MENU"
            exit 1
        fi
        # check if electrs is already installed

        echo -e "${RED}"
        echo "***"
        echo "Restarting Electrs..."
        echo "***"
        echo -e "${NC}"
        _sleep 2
        docker restart indexer 1>/dev/null
        bash -c "$RONIN_ELECTRS_MENU"
        # restart electrs, return to menu
        ;;
    4)
        if ! _is_electrs; then
            bash -c "$RONIN_ELECTRS_MENU"
            exit 1
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
        cd "$dojo_path_my_dojo" || exit
        ./dojo.sh logs indexer
        bash -c "$RONIN_ELECTRS_MENU"
        # start electrs, return to menu
        ;;
	5)
        ronin
        # returns to main menu
        ;;
esac
