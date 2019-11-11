#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

echo -e "${RED}"
echo "***"
echo "Updating, Installing Git, and Preparing for UI..."
echo "***"
echo -e "${NC}"
sleep 3s
sudo pacman -Syu
sudo pacman -S --noconfirm git
# initial setup for UI is deleted by sed a few lines below

echo -e "${RED}"
echo "***"
echo "Downloading UI..."
echo "***"
echo -e "${NC}"
sleep 2s
git clone https://github.com/RoninDojo/RoninDojo.git

cp ~/RoninDojo/Scripts/.dialogrc ~/.dialogrc
# config file for dialog color

sudo sed -i '11i export PATH="$PATH:~/RoninDojo/ronin.sh' ~/.bashrc
# edit bash.rc with ronin.sh path for quick launch from command line

sudo chmod +x ~/RoninDojo/Scripts/Install/*
sudo chmod +x ~/RoninDojo/Scripts/Menu/*
# set all scripts to be executable

echo -e "${RED}"
echo "***"
echo "Welcome to Ronin UI!"
echo "***"
echo -e "${NC}"
sleep 5s

sudo sed '8,44d' ~/RoninDojo/ronin.sh
# after running first time setup, then lines 8-44 are deleted by sed

HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="Ronin UI"
MENU="Choose one of the following options:"

OPTIONS=(1 "Dojo Menu"
         2 "Whirlpool Menu"
         3 "Electrs Menu"
         4 "Firewall Menu"
	 5 "System Menu"
         6 "System Setup & Installs")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            bash ~/RoninDojo/Scripts/Menu/ronin-dojo-menu.sh
            # runs dojo management menu script
            ;;
        2)
            bash ~/RoninDojo/Scripts/Menu/ronin-whirlpool-menu.sh
            # runs the whirlpool menu script
            ;;
        3)
            bash ~/RoninDojo/Scripts/Menu/ronin-electrs-menu.sh
            # runs electrs menu script
            ;;
        4)
            bash ~/RoninDojo/Scripts/Menu/ronin-firewall-menu.sh
            # runs firewall menu script
            ;;
        5)
            bash ~/RoninDojo/Scripts/Menu/ronin-system-menu.sh
            # runs system menu script
            ;;
        6)
            bash ~/RoninDojo/Scripts/Menu/ronin-install-menu.sh
	    # runs installs menu
            ;;
esac
