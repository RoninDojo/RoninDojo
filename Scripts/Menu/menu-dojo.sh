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

OPTIONS=(1 "Start Dojo"
         2 "Stop Dojo"
         3 "View Logs"
         4 "Tor Hidden Service Address"
         5 "Upgrade Dojo"
         6 "Version Info"
         7 "Clean Dojo"
         8 "Next Page"
         9 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            isRunning=$(sudo docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "true" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo is already started!"
              echo "***"
              echo -e "${NC}"
              sleep 5s
              bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
              exit
            fi
            # checks if dojo is running (check the db container), if running, tells user to dojo has already started

            echo -e "${RED}"
            echo "***"
            echo "Starting Dojo..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh start

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
            # start dojo, press any letter to return to menu
            ;;
        2)
            isRunning=$(sudo docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Dojo is already stopped!"
              echo "***"
              echo -e "${NC}"
              sleep 5s
              bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
              exit
            fi
            # checks if dojo is not running (check the db container), if not running, tells user dojo is alredy stopped

            echo -e "${RED}"
            echo "***"
            echo "Stopping Dojo..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh stop

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
            # stop dojo, press any letter to return to menu
            ;;
        3)
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            # go to dojo logs menu
            ;;
        4)
            isRunning=$(sudo docker inspect --format="{{.State.Running}}" db 2> /dev/null)
            if [ $? -eq 1 ] || [ "$isRunning" == "false" ]; then
              echo -e "${RED}"
              echo "***"
              echo "Please start Dojo first!"
              echo "***"
              echo -e "${NC}"
              sleep 5s
              bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
              exit
            fi
            # checks if dojo is not running (check the db container), if not running, tells user to start dojo first

            echo -e "${RED}"
            echo "***"
            echo "Use the v3 address to connect to the Maintenance Tool."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh onion
            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
            # press any key to return to menu
            # shows .onion and returns to menu
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Upgrading Dojo in 30s..."
            echo "Use Ctrl+C to exit if needed!"
            echo "***"
            echo -e "${NC}"
            sleep 30s
            cd ~/dojo/docker/my-dojo
            sudo ./dojo.sh stop
            mkdir ~/.dojo > /dev/null 2>&1
            cd ~/.dojo
	    sudo rm -rf samourai-dojo > /dev/null 2>&1
            # Check if user has Electrs+Dojo installed

            if [ ! -f /home/$USER/dojo/docker/my-dojo/conf/docker-electrs.conf ]; then
                git clone -b master https://github.com/RoninDojo/samourai-dojo.git;
            else
                git clone -b feat_electrs https://github.com/RoninDojo/samourai-dojo.git;
            fi
            sudo cp -rv samourai-dojo/* ~/dojo
            # install new explorer

            echo -e "${RED}"
            echo "***"
            echo "Checking for Dojo-backed Bitcoin Explorer"
            echo "***"
            echo -e "${NC}"
            sleep 1s
            if [ ! -f /home/$USER/dojo/docker/my-dojo/conf/docker-explorer.conf ]; then
                echo -e "${RED}"
                echo "***"
                echo "Installing Dojo BTC-Explorer, create a Password..."
                echo "***"
                echo -e "${NC}"
                sleep 1s
                echo -e "${RED}"
                echo "***"
                echo "This password should be something you can remember and is only alphanumeric!"
                echo "***"
                echo -e "${NC}"
                read -p 'Your Dojo Explorer password: ' EXPLORER_PASS
                sleep 1s
                echo -e "${YELLOW}"
                echo "----------------"
                echo "$EXPLORER_PASS"
                echo "----------------"
                echo -e "${RED}"
                echo "Is this correct?"
                echo -e "${NC}"
                select yn in "Yes" "No"; do
                    case $yn in
                        Yes ) break;;
                        No ) read -p 'New Dojo Explorer Password: ' EXPLORER_PASS
                        echo "$EXPLORER_PASS"
                    esac
                done
                echo -e "${RED}"
                echo "$EXPLORER_PASS"
                echo -e "${NC}"
                sed -i '16i EXPLORER_KEY='$EXPLORER_PASS'' ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl
                sed -i '17d' ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl
            else
                echo -e "${RED}"
                echo "***"
                echo "Explorer is already installed!"
                echo "***"
                echo -e "${NC}"
	    fi
            cd ~/dojo/docker/my-dojo/
            sleep 2s
            sudo ./dojo.sh upgrade
            sleep 2s
            bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
            # upgrades dojo and returns to menu
            ;;
        6)
            echo -e "${RED}"
            echo "***"
            echo "Displaying the version info..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh version

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
            # display dojo version info
            # press any letter to return
            ;;
        7)
            echo -e "${RED}"
            echo "***"
            echo "Deleting docker dangling images and images of previous versions in 15s..."
            echo "***"
            echo -e "${NC}"
            sleep 1s

            echo -e "${RED}"
            echo "***"
            echo "Use Ctrl+C to exit if needed!"
            echo "***"
            echo -e "${NC}"
            sleep 14s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh clean
            sleep 2s
            bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
            # free disk space by deleting docker dangling images and images of previous versions. then returns to menu
            ;;
        8)
            bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh
            # takes you to ronin dojo menu2
            ;;
        9)
            bash ~/RoninDojo/ronin
            # return to main ronin menu
            ;;
esac
