#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Upgrade Dojo"
         2 "Uninstall Dojo"
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
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-upgrade.sh
            # upgrades dojo and returns to menu
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Uninstalling Dojo in 30s..."
            echo "***"
            echo -e "${NC}"
            _sleep 5

            echo -e "${RED}"
            echo "***"
            echo "You will be asked if you wish to salvage any data..."
            echo "***"
            echo -e "${NC}"
            _sleep 5

            echo -e "${RED}"
            echo "***"
            echo "Users with a fully sync'd Blockchain should answer yes to salvage!"
            echo "***"
            echo -e "${NC}"
            _sleep 5

            echo -e "${RED}"
            echo "***"
            echo "WARNING: Data will be lost if you answer no to salvage, use Ctrl+C to exit if needed!"
            echo "***"
            echo -e "${NC}"
            _sleep 15

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
                            ./dojo.sh stop
                            # stop dojo

                            test ! -d /mnt/usb/uninstall-salvage && sudo mkdir /mnt/usb/uninstall-salvage
                            # check if salvage directory exist

                            sudo mv -v /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/{blocks,chainstate} /mnt/usb/uninstall-salvage/
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
            sudo rm -rf ~/dojo
            cd "${HOME}" || exit
            # uninstall dojo

            echo -e "${RED}"
            echo "***"
            echo "Complete!"
            echo "***"
            echo -e "${NC}"
            bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh
            # return to menu
            ;;
        3)
            bash ~/RoninDojo/Scripts/Install/install-receive-block-data.sh
            # copy block data from backup drive
            ;;
        4)
            bash ~/RoninDojo/Scripts/Install/install-send-block-data.sh
            # copy block data to backup drive
            ;;
        5)
            bash -c "$RONIN_DOJO_MENU"
            # return to main menu
            ;;
esac
