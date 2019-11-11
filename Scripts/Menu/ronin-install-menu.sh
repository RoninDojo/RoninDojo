#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

cmd=(dialog --title "Ronin UI" --separate-output --checklist "Use Spacebar to select one or multiple:" 22 76 16)
options=(1 "Setup System & Install Dependencies" off    # any option can be set to default to "on"
         2 "Install Dojo" off
         3 "Install Whirlpool" off
	 4 "Install Electrs" off
	 5 "Go Back" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            bash ~/RoninDojo/Scripts/Install/install-dependencies-setup-system.sh
	    # runs system setup script which will installs dependencies, setup ssd, assigns local ip range to ufw, etc. 
            ;;
        2)
            bash ~/RoninDojo/Scripts/Install/install-dojo.sh
            # runs dojo install script
            ;;
        3)
            bash ~/Ronin-Dojo/Scripts/Install/install-whirlpool.sh
            # runs electrs setup script
            ;;
        4)
            bash ~/RoninDojo/Scripts/Install/install-electrs.sh
            # runs electrs setup script
            ;;
        5)
            bash ~/RoninDojo/Scripts/Install/ronin
            # go back to main menu
            ;;
    esac
done
