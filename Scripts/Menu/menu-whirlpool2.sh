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

OPTIONS=(1 "Re-initiate Whirlpool"
         2 "Upgrade Whirlpool"
         3 "Uninstall Whirlpool"
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
            echo "Re-initiating Whirlpool will reset your mix count and generate new API key..."
            echo "***"
            read -p "Are you sure you want to re-initiate Whirlpool? [y/n]" yn
            case $yn in
                [Y/y]* ) echo "Re-initiating Whirlpool..."
			echo -e "${NC}"
                        sudo systemctl stop whirlpool
                        cd ~/whirlpool
                        rm -rf *.json whirlpool-cli-config.properties
                        sleep 1s
                        echo "Re-pair with Whirlpool GUI"
                        echo -e "${NC}"
			            sudo systemctl start whirlpool
			            echo -e "${RED}"
			            echo "Re-initation complete...Leave APIkey blank when pairing to GUI"
                        sleep 5s;;
                [N/n]* ) echo "Returning to menu...";;
                     * ) echo "Please answer yes or no.";;
            esac
            echo -e "${NC}"
            sleep 1s
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # re-initate whirlpool, return to menu
            ;;
        2)  
            echo -e "${RED}"
            echo "***"
            echo "Upgrading to Whirlpool Client CLI 0.10.4..."
            echo "***"            
            sleep 2s
            echo "Press Ctrl+C to exit..."
            sleep 5s
            cd ~/whirlpool
            sudo systemctl stop whirlpool > /dev/null 2>&1
            sudo rm -rf *.jar
            wget -O whirlpool.jar https://github.com/Samourai-Wallet/whirlpool-client-cli/releases/download/0.10.4/whirlpool-client-cli-0.10.4-run.jar
            sudo systemctl start whirlpool
            echo "Upgrade complete... head to GUI to unlock mixing."
            sleep 2s
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # upgrade whirlpool
            ;;

        3)
            echo -e "${RED}"
            echo "***"
            echo "Uninstalling Whirlpool..."
            echo "***"
            sleep 2s
            echo "Do you want to uninstall Whirlpool?"
            echo -e "${NC}"
            while true; do
                read -p "Y/N?: " yn
                case $yn in
                    [Yy]* ) echo -e "${RED}"
                            echo "***"
                            echo "Uninstalling Whirlpool..."
                            echo "***"
                            echo -e "${NC}"
                            sleep 2s
                            sudo systemctl stop whirlpool 
                            sudo rm -rf /etc/systemd/system/whirlpool.service
                            sudo rm -rf ~/whirlpool
                            sudo systemctl daemon-reload
                            echo -e "${RED}"
                            echo "***"
                            echo "Whirlpool is uninstalled... returning to menu"
                            echo "***"
                            sleep 2s
                            break;;
                    [Nn]* ) echo -e "${RED}"
                            echo "***"
                            echo "Returning to menu..."
                            echo "***"
                            sleep 2s
                            break;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
            
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool2.sh
            # uninstall whirlpool after confirmation else return to menu
            ;;
        
        4)
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
	    # return to menu
	    ;;
esac
