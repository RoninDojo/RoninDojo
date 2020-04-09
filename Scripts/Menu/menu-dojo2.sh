#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="RoninDojo"
MENU="Choose one of the following options:"

OPTIONS=(1 "Uninstall Dojo"
         2 "Receive Block Data from Backup"
         3 "Send Block Data to Backup"
         4 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo -e "${RED}"
            echo "***"
            echo "Uninstalling Dojo in 30s..."
            echo "***"
            echo -e "${NC}"
            sleep 5s

            echo -e "${RED}"
            echo "***"
            echo "You will be asked if you wish to salvage any data..."
            echo "***"
            echo -e "${NC}"
            sleep 5s

	    echo -e "${RED}"
            echo "***"
            echo "Users with a fully sync'd Blockchain should answer yes to salvage!"
            echo "***"
            echo -e "${NC}"
            sleep 5s

            echo -e "${RED}"
            echo "***"
            echo "WARNING: Data will be lost if you answer no to salvage, use Ctrl+C to exit if needed!"
            echo "***"
            echo -e "${NC}"
            sleep 15s

            echo -e "${RED}"
            echo "Do you want to salvage your Blockchain data?"
            echo -e "${NC}"
            while true; do
                read -p "Y/N?: " yn
                case $yn in
                    [Yy]* ) echo -e "${RED}"
                            echo "***"
                            echo "Copying block data to temporary directory..."
                            echo "***"
                            echo -e "${NC}"
                            sleep 2s
			    bash ~/RoninDojo/Scripts/Standalone/dojo-stop.sh
                            sudo mkdir /uninstall-salvage/
                            sudo cp -rv /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/chainstate/ /mnt/usb/uninstall-salvage/
                            sudo cp -rv /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/blocks/ /mnt/usb/uninstall-salvage/
                            # stops dojo, copies blockchain data to uninstall-salvage to be used by the dojo install script
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
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh uninstall
	    sudo rm -rf ~/dojo
            # uninstall dojo

	    echo -e "${RED}"
            echo "***"
            echo "Complete!"
            echo "***"
            echo -e "${NC}"
            bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh
            # return to menu
            ;;
        2)
            bash ~/RoninDojo/Scripts/Install/install-receive-block-data.sh
            # copy block data from backup drive
            ;;
        3)
            bash ~/RoninDojo/Scripts/Install/install-send-block-data.sh
            # copy block data to backup drive
            ;;
        4)
            bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
            # return to main menu
            ;;
esac
