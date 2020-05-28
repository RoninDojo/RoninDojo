#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Bitcoind Logs"
         2 "Db Logs"
         3 "Tor Logs"
         4 "API Logs"
         5 "Tracker Logs"
         6 "All Container Logs"
         7 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo needs to be started first!"
              echo "***"
              echo -e "${NC}"
              _sleep 5
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
              exit
            fi
            # checks if dojo is running (check the db container), if not running tells user to start dojo first

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs bitcoind -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows dojo bitcoind error logs
            ;;
        2)
            isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo needs to be started first!"
              echo "***"
              echo -e "${NC}"
              _sleep 5
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
              exit
            fi
            # checks if dojo is running (check the db container), if not running tells user to start dojo first

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs db -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows dojo db error logs
            ;;
        3)
            isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo needs to be started first!"
              echo "***"
              echo -e "${NC}"
              _sleep 5
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
              exit
            fi
            # checks if dojo is running (check the db container), if not running tells user to start dojo first

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs tor -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows dojo tor error logs
            ;;
        4)
            isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo needs to be started first!"
              echo "***"
              echo -e "${NC}"
              _sleep 5
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
              exit
            fi
            # checks if dojo is running (check the db container), if not running tells user to start dojo first

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs api -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows dojo api error logs
            ;;
        5)
            isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo needs to be started first!"
              echo "***"
              echo -e "${NC}"
              _sleep 5
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
              exit
            fi
            # checks if dojo is running (check the db container), if not running tells user to start dojo first

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs tracker -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows dojo tracker error logs
            ;;
        6)
            isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo needs to be started first!"
              echo "***"
              echo -e "${NC}"
              _sleep 5
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
              exit
            fi
            # checks if dojo is running (check the db container), if not running tells user to start dojo first

            echo -e "${RED}"
            echo "***"
            echo "Press Ctrl + C to exit at any time."
            echo "***"
            echo -e "${NC}"
            _sleep 2

            echo -e "${RED}"
            echo "***"
            echo "This command may take some time."
            echo "***"
            echo -e "${NC}"
            _sleep
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs -d error -n 500
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows all docker container error logs
            ;;
        8)
            bash -c "$RONIN_DOJO_MENU"
            # goes back to ronin dojo menu
            ;;
esac
