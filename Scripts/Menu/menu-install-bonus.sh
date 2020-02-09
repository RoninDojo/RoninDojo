#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

cmd=(dialog --title "RoninDojo" --separate-output --checklist "Use Mouse Click or Spacebar to select:" 22 76 16)
options=(1 "Install Electrs"    # any option can be set to default to "on"
         2 "Go Back" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            bash ~/RoninDojo/Scripts/Install/install-electrs.sh
            # runs electrs setup script
            ;;
        2)
            bash ~/RoninDojo/ronin
            # return to main ronin menu
            ;;
    esac
done
