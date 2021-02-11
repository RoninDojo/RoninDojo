#!/bin/bash
# shellcheck source=/dev/null disable=SC2086,SC2154

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
            if _dojo_check; then
                cat <<EOF
${RED}
***
Dojo is already started!
***
${NC}
EOF
                _sleep 2
                _pause return
                bash -c "${ronin_dojo_menu}"
            else
                _is_dojo "${ronin_dojo_menu}"
                # is dojo installed?

                cat <<EOF
${RED}
***
Starting Dojo...
***
${NC}
EOF
                _sleep 2

                cd "${dojo_path_my_dojo}" || exit
                _source_dojo_conf

                # Start docker containers
                yamlFiles=$(_select_yaml_files)
                docker-compose $yamlFiles up --remove-orphans -d || exit # failed to start dojo
            fi
            # checks if dojo is running (check the db container), if running, tells user to dojo has already started

                _pause return
                bash -c "${ronin_dojo_menu}"
                # press any key to return to menu
                ;;
        2)
            _stop_dojo
            _pause return
            bash -c "${ronin_dojo_menu}"
            # press any key to return to menu
            ;;
        3)
            _is_dojo "${ronin_dojo_menu}"
            # is dojo installed?

            if [ -d "${dojo_path}" ]; then
                cat <<EOF
${RED}
***
Restarting Dojo...
***
${NC}
EOF
                _sleep 2
                cd "${dojo_path_my_dojo}" || exit

                cat <<DOJO
${RED}
***
Stopping Dojo...
***
${NC}
DOJO
                # Check if db container running before stopping all containers
                if _dojo_check; then
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

                _pause return
                bash -c "${ronin_dojo_menu}"
                # press any key to return to menu
            fi
            ;;
        4)
            _is_dojo "${ronin_dojo_menu}"
            # is dojo installed?

            bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            # go to dojo logs menu
            ;;
        5)
            bash -c "${ronin_dojo_menu2}"
            # takes you to ronin dojo menu2
            ;;
        6)
            ronin
            # return to main ronin menu
            ;;
esac