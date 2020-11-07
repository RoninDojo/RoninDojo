#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Clean Dojo"
         2 "Dojo Version"
         3 "Receive Block Data from Backup"
         4 "Send Block Data to Backup"
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
            if ! _dojo_check; then
                _is_dojo "${RONIN_DOJO_MENU2}"
            fi
            # is dojo installed?

            echo -e "${RED}"
            echo "***"
            echo "Deleting docker dangling images and images of previous versions in 5s..."
            echo "***"
            echo -e "${NC}"

            echo -e "${RED}"
            echo "***"
            echo "Use Ctrl+C to exit if needed!"
            echo "***"
            echo -e "${NC}"
            _sleep 5
            cd "$dojo_path_my_dojo" || exit
            ./dojo.sh clean

            bash -c "${RONIN_DOJO_MENU2}"
            # free disk space by deleting docker dangling images and images of previous versions. then returns to menu
            ;;
        2)
            if ! _dojo_check; then
                _is_dojo "${RONIN_DOJO_MENU2}"
            fi
            # is dojo installed?

            echo -e "${RED}"
            echo "***"
            echo "Displaying the version info..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            cd "$dojo_path_my_dojo" || exit
            ./dojo.sh version
            # display dojo version info

            echo -e "${RED}"
            echo "***"
            echo "Press any key to return..."
            echo "***"
            echo -e "${NC}"
            _pause
            bash -c "${RONIN_DOJO_MENU2}"
            # press any key to return
            ;;
        3)
            if ! _dojo_check; then
                _is_dojo "${RONIN_DOJO_MENU2}"
            fi
            # is dojo installed?

            bash "$HOME"/RoninDojo/Scripts/Install/install-receive-block-data.sh
            # copy block data from backup drive
            ;;
        4)
            if ! _dojo_check; then
                _is_dojo "${RONIN_DOJO_MENU2}"
            fi
            # is dojo installed?

            bash "$HOME"/RoninDojo/Scripts/Install/install-send-block-data.sh
            # copy block data to backup drive
            ;;
        5)
            bash -c "${RONIN_DOJO_MENU}"
            # return to main menu
            ;;
esac
