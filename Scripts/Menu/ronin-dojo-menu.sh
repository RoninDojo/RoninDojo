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
            echo -e "${RED}"
            echo "***"
            echo "Starting Dojo..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh start
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
            sleep 2s
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh logs $requested_logs
            # utilizing user input from $requested_logs for ./dojo.sh logs
            bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu.sh
            # return to main menu
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Showing the Tor Hidden Service Address."
            echo "This .onion address allows your wallet to access your Dojo."
	    echo "Use the v3 address to connect to the Maintenance Tool"
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
	    cd ~/dojo/docker/my-dojo
	    sudo ./dojo.sh stop
	    mkdir ~/.dojo > /dev/null 2>&1
	    cd ~/.dojo
	    git clone -b master https://github.com/Samourai-Wallet/samourai-dojo.git
	    sudo cp -rv samourai-dojo/* ~/dojo
	    sed -i '9d' ~/dojo/docker/my-dojo/bitcoin/Dockerfile
	    sed -i '9i             ENV     BITCOIN_URL         https://bitcoincore.org/bin/bitcoin-core-0.19.0.1/bitcoin-0.19.0.1-aarch64-linux-gnu.tar.gz' ~/dojo/docker/my-dojo/bitcoin/Dockerfile
	    sed -i '10d' ~/dojo/docker/my-dojo/bitcoin/Dockerfile
	    sed -i '10i            ENV     BITCOIN_SHA256      c258c6416225afb08c4396847eb3d5da61a124f1b5c61cccb5a2e903e453ce7f' ~/dojo/docker/my-dojo/bitcoin/Dockerfile
	    sed -i '1d' ~/dojo/docker/my-dojo/mysql/Dockerfile
	    sed -i '1i             FROM    mariadb:latest' ~/dojo/docker/my-dojo/mysql/Dockerfile
	    sed -i '12d' ~/dojo/docker/my-dojo/tor/Dockerfile
	    sed -i '12i ENV     GOLANG_ARCHIVE      go1.13.5.linux-arm64.tar.gz' ~/dojo/docker/my-dojo/tor/Dockerfile
	    sed -i '13d' ~/dojo/docker/my-dojo/tor/Dockerfile
	    sed -i '13i ENV     GOLANG_SHA256       227b718923e20c846460bbecddde9cb86bad73acc5fb6f8e1a96b81b5c84668b' ~/dojo/docker/my-dojo/tor/Dockerfile
            cd ~/dojo/docker/my-dojo/	   
            sleep 2s
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
            sleep 2s
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
            bash ~/RoninDojo/ronin
            # return to main ronin.sh menu
            ;;
esac
