#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Uninstall Dojo"
         2 "Clean Dojo"
         3 "Dojo Version"
         4 "Receive Block Data from Backup"
         5 "Send Block Data to Backup"
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
            if ! _dojo_check "$DOJO_PATH"; then
                # Is dojo installed?
                if [ ! -d "${DOJO_PATH%/docker/my-dojo}" ]; then
                    cat <<DOJO
${RED}
***
Missing ${DOJO_PATH%/docker/my-dojo} directory! Returning to menu
***
${NC}
DOJO
                    _sleep 2
                    bash -c "$RONIN_DOJO_MENU"
                fi
            fi

            cat <<DOJO
${RED}
***
Uninstalling Dojo in 15s...

Users with a fully synced Blockchain should answer yes to salvage!

WARNING: Data will be lost if you answer no to salvage, use Ctrl+C to exit if needed!
***
${NC}
DOJO
            _sleep 7

            echo -e "${RED}"
            echo "Do you want to salvage your Blockchain data?"
            echo -e "${NC}"
            while true; do
                read -rp "Y/N?: " yn
                case $yn in
                    [Yy]* ) echo -e "${RED}"
                            echo "***"
                            echo "Copying block data to temporary directory..."
                            echo "***"
                            echo -e "${NC}"
                            _sleep 2
                            cd "$DOJO_PATH" || exit
                            _stop_dojo
                            # stop dojo

                            test ! -d "${INSTALL_DIR_UNINSTALL}" && sudo mkdir "${INSTALL_DIR_UNINSTALL}"
                            # check if salvage directory exist

                            sudo mv -v "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate} "${INSTALL_DIR_UNINSTALL}"/
                            # copies blockchain data to uninstall-salvage to be used by the dojo install script
                            break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer yes or no.";;
                esac
            done

            echo -e "${RED}"
            echo "***"
            echo "Uninstalling Dojo..."
            echo "***"
            echo -e "${NC}"
            cd "$DOJO_PATH" || exit
            ./dojo.sh uninstall
            sudo rm -rf "${DOJO_PATH%/docker/my-dojo}"
            cd "${HOME}" || exit
            # uninstall dojo

            # Restart docker daemon
            sudo systemctl restart docker

            echo -e "${RED}"
            echo "***"
            echo "Complete!"
            echo "***"
            echo -e "${NC}"
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo2.sh
            # return to menu
            ;;
        3)
            if ! _dojo_check "$DOJO_PATH"; then
                # Is dojo installed?
                if [ ! -d "${DOJO_PATH%/docker/my-dojo}" ]; then
                    cat <<DOJO
${RED}
***
Missing ${DOJO_PATH%/docker/my-dojo} directory! Returning to menu
***
${NC}
DOJO
                    _sleep 2
                    bash -c "$RONIN_DOJO_MENU"
                fi
            fi

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
            cd "$DOJO_PATH" || exit
            ./dojo.sh clean

            bash -c "$RONIN_DOJO_MENU"
            # free disk space by deleting docker dangling images and images of previous versions. then returns to menu
            ;;
        4)
            if ! _dojo_check "$DOJO_PATH"; then
                # Is dojo installed?
                if [ ! -d "${DOJO_PATH%/docker/my-dojo}" ]; then
                    cat <<DOJO
${RED}
***
Missing ${DOJO_PATH%/docker/my-dojo} directory! Returning to menu
***
${NC}
DOJO
                    _sleep 2
                    bash -c "$RONIN_DOJO_MENU"
                fi
            fi

            echo -e "${RED}"
            echo "***"
            echo "Displaying the version info..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            cd "$DOJO_PATH" || exit
            ./dojo.sh version
            # display dojo version info

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash -c "$RONIN_DOJO_MENU"
            # press any letter to return
            ;;
        5)
            if ! _dojo_check "$DOJO_PATH"; then
                # Is dojo installed?
                if [ ! -d "${DOJO_PATH%/docker/my-dojo}" ]; then
                    cat <<DOJO
${RED}
***
Missing ${DOJO_PATH%/docker/my-dojo} directory! Returning to menu
***
${NC}
DOJO
                    _sleep 2
                    bash -c "$RONIN_DOJO_MENU"
                fi
            fi

            bash "$HOME"/RoninDojo/Scripts/Install/install-receive-block-data.sh
            # copy block data from backup drive
            ;;
        6)
            if ! _dojo_check "$DOJO_PATH"; then
                # Is dojo installed?
                if [ ! -d "${DOJO_PATH%/docker/my-dojo}" ]; then
                    cat <<DOJO
${RED}
***
Missing ${DOJO_PATH%/docker/my-dojo} directory! Returning to menu
***
${NC}
DOJO
                    _sleep 2
                    bash -c "$RONIN_DOJO_MENU"
                fi
            fi

            bash "$HOME"/RoninDojo/Scripts/Install/install-send-block-data.sh
            # copy block data to backup drive
            ;;
        7)
            bash -c "$RONIN_DOJO_MENU"
            # return to main menu
            ;;
esac
