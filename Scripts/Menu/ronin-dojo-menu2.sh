#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="Ronin UI"
MENU="Choose one of the following options:"

OPTIONS=(1 "Enable Dojo at Startup"
         2 "Disable Dojo at Startup"
         3 "Uninstall Dojo"
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
            echo "Creating executable start for service..."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            USER=$(sudo cat /etc/passwd | grep 1000 | awk -F: '{ print $1}' | cut -c 1-)
            echo ""
            echo "
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh start
            " | sudo tee -a /bin/dojo

            sleep 1s
            echo -e "${RED}"
            echo "***"
            echo "Making dojo.service file..."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo "
            [Unit]
            Description=Dojo
            After=docker.service
            [Service]
            WorkingDirectory=/home/$USER/dojo/docker/my-dojo
            ExecStart=/bin/dojo
            User=root
            Group=root
            Type=simple
            KillMode=process
            TimeoutSec=60
            Restart=always
            RestartSec=60
            [Install]
            WantedBy=multi-user.target
            " | sudo tee -a /etc/systemd/system/dojo.service

            sudo systemctl enable dojo
            # enables dojo system service

            echo -e "${RED}"
            echo "***"
            echo "Dojo.service is enabled and will launch at system start up."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu2.sh
            # start dojo, return to menu
            ;; 
        2)
            echo -e "${RED}"
            echo "***"
            echo "Disable Dojo At Startup..."
            echo "***"
            echo -e "${NC}"
            sudo systemctl disable dojo
            sleep 2s
            
            sudo rm /etc/systemd/system/dojo.service
            sudo rm /bin/dojo
            sleep 2s
            
            echo -e "${RED}"
            echo "***"
            echo "Dojo.service is enabled and will launch at system start up."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu2.sh
            # start dojo, return to menu
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Uninstalling Dojo in 30s..."
            echo "***"
            echo -e "${NC}"
            sleep 5s

            echo -e "${RED}"
            echo "***"
            echo "WARNING: This will uninstall Dojo, use Ctrl+C to exit if needed!"
            echo "***"
            echo -e "${NC}"
            sleep 30s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh uninstall
            # uninstall dojo
            ;;
        4)
            bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu.sh
            # return to main menu
            ;;
esac
