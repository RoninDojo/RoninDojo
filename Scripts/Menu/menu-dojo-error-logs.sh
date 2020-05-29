#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Bitcoind Logs"
         2 "Db Logs"
         3 "Indexer Logs"
         4 "Nginx Logs"
         5 "Nodejs Logs"
         6 "Tor Logs"
         7 "Explorer Logs"
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
            sleep 2s
            cd "$DOJO_PATH" || exit 
            ./dojo.sh logs bitcoind -n 200
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows bitcoind error logs
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
            sleep 2s
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs db -n 500 | grep error
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows db error logs
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
            sleep 2s
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs indexer -n 500
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows tor error logs
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
            sleep 2s
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs nginx -n 500 | grep HttpServer
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows nginx error logs
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
            sleep 2s
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs nodejs -n 500 | grep Tracker
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows nodejs error logs
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
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs tor -n 500
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows tor error logs
            ;;
        7)
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
            ./dojo.sh logs explorer -n 500
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # shows explorer error logs
            ;;
        8)
            bash -c "$RONIN_DOJO_MENU"
            # goes back to ronin dojo menu
            ;;
esac
