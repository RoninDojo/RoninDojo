#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Bitcoind Logs"
         2 "Db Logs"
         3 "Tor Logs"
         4 "API Logs"
         5 "Tracker Logs"
         6 "Indexer Logs"
         7 "All Container Logs"
         8 "Troubleshooting Logs"
         9 "Go Back")

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
              sleep 5s
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
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
            ./dojo.sh logs bitcoind
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            # shows dojo bitcoind logs
            ;;
        2)
            isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo needs to be started first!"
              echo "***"
              echo -e "${NC}"
              sleep 5s
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
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
            ./dojo.sh logs db
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            # shows dojo db logs
            ;;
        3)
            isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo needs to be started first!"
              echo "***"
              echo -e "${NC}"
              sleep 5s
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
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
            ./dojo.sh logs tor
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            # shows dojo tor logs
            ;;
        4)
            isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo needs to be started first!"
              echo "***"
              echo -e "${NC}"
              sleep 5s
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
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
            ./dojo.sh logs api
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            # shows dojo api logs
            ;;
        5)
            isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo needs to be started first!"
              echo "***"
              echo -e "${NC}"
              sleep 5s
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
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
            ./dojo.sh logs tracker
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            # shows dojo tracker logs
            ;;
        6)
            isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo needs to be started first!"
              echo "***"
              echo -e "${NC}"
              sleep 5s
              bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
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
            sleep 1s
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs indexer
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            # shows logs for indexer
            ;;
        7)
          isRunning=$(docker inspect --format="{{.State.Running}}" db 2> /dev/null)
          if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
            echo -e "${RED}"
            echo "***"
            echo "Dojo needs to be started first!"
            echo "***"
            echo -e "${NC}"
            sleep 5s
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
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
          sleep 1s
          cd "$DOJO_PATH" || exit
          ./dojo.sh logs
          bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
          # shows logs for all containers
          ;;

        8)
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # goes to troubleshoot logs menu
            ;;
        9)
            bash -c "$RONIN_DOJO_MENU"
            # goes back to ronin dojo menu
            ;;
esac
