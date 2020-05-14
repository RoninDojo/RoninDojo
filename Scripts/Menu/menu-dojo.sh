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
            echo "Displaying your Tor Onion addresses..."
            echo "***"
            echo -e "${NC}"

            V3_ADDR_API=$(sudo docker exec -it tor cat /var/lib/tor/hsv3dojo/hostname )
            NODE_ADMIN_KEY=$(cat ~/dojo/docker/my-dojo/conf/docker-node.conf | grep NODE_ADMIN_KEY | cut -c 16-)
            # Maintenance Tool Onion and Password

            echo -e "${RED}"
            echo "***"
            echo -e "${NC}"
            echo "Dojo Maintenance Tool hidden service address (v3) = $V3_ADDR_API"
            echo "Dojo Maintenance Tool Password = $NODE_ADMIN_KEY"
            echo -e "${RED}"
            echo "***"
            echo -e "${NC}"

	        if [ -f ~/dojo/docker/my-dojo/conf/docker-explorer.conf ]; then
    	        V3_ADDR_EXPLORER=$(sudo docker exec -it tor cat /var/lib/tor/hsv3explorer/hostname )
                EXPLORER_KEY=$(cat ~/dojo/docker/my-dojo/conf/docker-explorer.conf | grep EXPLORER_KEY | cut -c 14-)
                # if Explorer is installed then display Onion and Password

                echo -e "${RED}"
                echo "***"
                echo -e "${NC}"
                echo "Explorer hidden service address (v3) = $V3_ADDR_EXPLORER"
                echo "No username required. Explorer Password = $EXPLORER_KEY"
                echo -e "${RED}"
                echo "***"
                echo -e "${NC}"
	        fi

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
            bash ~/RoninDojo/Scripts/Menu/menu-dojo-upgrade.sh
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
