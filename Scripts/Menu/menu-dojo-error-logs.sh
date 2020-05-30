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

            cd "$DOJO_PATH" || exit 
            ./dojo.sh logs bitcoind -n 200
            # shows bitcoind error logs

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # press any key to return to menu
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

            cd "$DOJO_PATH" || exit
            ./dojo.sh logs db -n 500 | grep error            
            # shows db error logs
	    
	    echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # press any key to return to menu
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

            cd "$DOJO_PATH" || exit
            ./dojo.sh logs indexer -n 500
            # shows tor error logs

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
	    bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # press any key to return to menu
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

            cd "$DOJO_PATH" || exit
            ./dojo.sh logs nginx -n 500 | grep HttpServer
            # shows nginx error logs

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
	    bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # press any key to return to menu
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

            cd "$DOJO_PATH" || exit
            ./dojo.sh logs node -n 500 | grep Tracker
            # shows nodejs error logs

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
	    bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # press any key to return to menu
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

            cd "$DOJO_PATH" || exit
            ./dojo.sh logs tor -n 500
            # shows tor error logs

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
	    bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # press any key to return to menu
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

            cd "$DOJO_PATH" || exit
            ./dojo.sh logs explorer -n 500
            # shows explorer error logs

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
	    bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # press any key to return to menu
            ;;
        8)
            bash -c "$RONIN_DOJO_MENU"
            # goes back to ronin dojo menu
            ;;
esac
