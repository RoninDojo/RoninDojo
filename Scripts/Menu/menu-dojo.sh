#!/bin/bash
# shellcheck source=/dev/null disable=SC2086

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Start"
         2 "Stop"
         3 "Restart"
         4 "Logs"
         5 "Next Page"
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
            if _dojo_check "$DOJO_PATH"; then
                echo -e "${RED}"
                echo "***"
                echo "Dojo is already started!"
                echo "***"
                echo -e "${NC}"
                _sleep 5
                bash -c "$RONIN_DOJO_MENU"
            else
                _is_dojo "${RONIN_DOJO_MENU}"
                # is dojo installed?

                echo -e "${RED}"
                echo "***"
                echo "Starting Dojo..."
                echo "***"
                echo -e "${NC}"
                _sleep 2

                cd "$DOJO_PATH" || exit

                _source_dojo_conf

                # Start docker containers
                yamlFiles=$(_select_yaml_files)
                docker-compose $yamlFiles up --remove-orphans -d || exit # failed to start dojo
            fi
            # checks if dojo is running (check the db container), if running, tells user to dojo has already started

            echo -e "${RED}"
            echo "***"
            echo "Press any key to return..."
            echo "***"
            echo -e "${NC}"
            _pause
            bash -c "${RONIN_DOJO_MENU}"
            # press any key to return to menu
            ;;
        2)
            _stop_dojo

            echo -e "${RED}"
            echo "***"
            echo "Press any key to return..."
            echo "***"
            echo -e "${NC}"
            _pause
            bash -c "${RONIN_DOJO_MENU}"
            # press any key to return to menu
            ;;
        3)
            _is_dojo "${RONIN_DOJO_MENU}"
            # is dojo installed?

            if [ -d "${DOJO_PATH%/docker/my-dojo}" ]; then
                echo -e "${RED}"
                echo "***"
                echo "Restarting Dojo..."
                echo "***"
                echo -e "${NC}"
                _sleep 2
                cd "$DOJO_PATH" || exit

                cat <<DOJO
${RED}
***
Stopping Dojo...
***
${NC}
DOJO
                # Check if db container running before stopping all containers
                if _dojo_check "$DOJO_PATH"; then
                    _stop_dojo
                fi

                cat <<DOJO
${RED}
***
Starting Dojo...
***
${NC}
DOJO

                # Start docker containers
                yamlFiles=$(_select_yaml_files)
                docker-compose $yamlFiles up --remove-orphans -d || exit # failed to start dojo
                # restart dojo

                echo -e "${RED}"
                echo "***"
                echo "Press any key to return..."
                echo "***"
                echo -e "${NC}"
                _pause
                bash -c "${RONIN_DOJO_MENU}"
                # press any key to return to menu
            fi
            ;;
        4)
            _is_dojo "${RONIN_DOJO_MENU}"
            # is dojo installed?

            bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            # go to dojo logs menu
            ;;
        5)
            bash -c "${RONIN_DOJO_MENU2}"
            # takes you to ronin dojo menu2
            ;;
        6)
            ronin
            # return to main ronin menu
            ;;
esac
