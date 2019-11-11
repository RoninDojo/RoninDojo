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

OPTIONS=(1 "Start Dojo"
         2 "Stop Dojo"
         3 "View Logs"
         4 "API Hidden Service Address"
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
            echo -e "${RED}"
            echo "***"
            echo "Starting Dojo..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh start
            sleep 3s
            bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu.sh
            # start dojo, return to menu
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Stopping Dojo..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh stop
            sleep 3s
	    bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu.sh
            # stop dojo, return to menu
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Type one of the following options now: (bitcoind, db, tor, api, tracker, pushtx, pushtx-orchest)"
            echo "Or just press 'Enter' to show logs for all containers, which will take some time."
            echo "***"
            echo -e "${NC}"
            
            read -p "Which logs would you like to view?: " requested_logs
            # get user input for logs

            echo -e "${RED}"
            echo "Running" $requested_logs "logs now. Use Ctrl+C at any time to exit and return to menu."
            echo -e "${NC}"
            sleep 5s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs $requested_logs
            # utilizing user input from $requested_logs for ./dojo.sh logs
            bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu.sh
            # return to main menu
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Showing the API Hidden Service Address."
            echo "This .onion address allows your wallet to access your Dojo."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh onion
            
            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu.sh
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
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh upgrade
            bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu.sh
            # upgrades dojo
            ;;
        6)
            echo -e "${RED}"
            echo "***"
            echo "Displaying the version info..."
            echo "***"
            echo -e "${NC}"
            sleep 3s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh version
            
            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu.sh
            # display dojo version info
            # press any letter to return
            ;;
        7)
            echo -e "${RED}"
            echo "***"
            echo "Deleting docker dangling images and images of previous versions in 15s..."
            echo "Use Ctrl+C to exit if needed!"
            echo "***"
            echo -e "${NC}"
            sleep 15s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh clean
            # free disk space by deleting docker dangling images and images of previous versions
            ;;
        8)
            bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu2.sh
            # takes you to ronin dojo menu2
            ;;
        9)
            bash ~/RoninDojo/ronin.sh
            # return to main ronin.sh menu
            ;;
esac
