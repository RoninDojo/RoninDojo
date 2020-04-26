#!/bin/bash

. ~/RoninDojo/Scripts/defaults.sh

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
            echo -e "${NC}"
            
            read -p "Are you sure you want to re-initiate Whirlpool? [y/n]" yn
            case $yn in
                [Y/y]* ) echo -e "${RED}"
                         echo "***"
                         echo "Re-initiating Whirlpool..."
                         echo "***"
                         echo -e "${NC}"
                         sudo systemctl stop whirlpool
                         cd ~/whirlpool
                         rm -rf *.json whirlpool-cli-config.properties
                         sleep 1s
                         
                         echo -e "${RED}"
                         echo "***"
                         echo "Re-pair with Whirlpool GUI"
                         echo "***"
                         echo -e "${NC}"
                         sudo systemctl start whirlpool
			             
                         echo -e "${RED}"
                         echo "***"
                         echo "Re-initation complete...Leave APIkey blank when pairing to GUI"
                         echo "***"
                         echo -e "${NC}"
                         sleep 5s;;
                         
                [N/n]* ) echo -e "${RED}"
                         echo "***"
                         echo "Returning to menu..."
                         echo "***"
                         echo -e "${NC}"
                         sleep 2s
                         break;;
                * ) echo "Please answer yes or no.";;
            esac
            sleep 1s
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # re-initate whirlpool, return to menu
            ;;
        2)  
            echo -e "${RED}"
            echo "***"
            echo "Checking for latest Whirlpool release..."
            echo "***"
            echo -e "${NC}"
            sleep 1s
            if pacman -Q jq > /dev/null ; then
                echo -e "${RED}"
                echo "***"
                echo "jq already installed..."
                echo "***"
                echo -e "${NC}"
            else
                echo -e "${RED}"
                echo "***"
                echo "Installing jq..."
                echo "***"
                echo -e "${NC}"
                sleep 1s
                sudo pacman -S --noconfirm jq
            fi

            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool-upgrade.sh
            echo -e "${RED}"
            echo "***"
            echo "You are on current Whirlpool release... head to GUI to unlock mixing."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            bash ~/RoninDojo/Scripts/Menu/menu-whirlpool.sh
            # upgrade whirlpool
            ;;

        3)
            echo -e "${RED}"
            echo "***"
            echo "Uninstalling Whirlpool..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            
            echo -e "${RED}"
            echo "***"
            echo "Do you want to uninstall Whirlpool?"
            echo "***"
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
                            echo -e "${NC}"
                            sleep 2s
                            break;;
                            
                    [Nn]* ) echo -e "${RED}"
                            echo "***"
                            echo "Returning to menu..."
                            echo "***"
                            echo -e "${NC}"
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
