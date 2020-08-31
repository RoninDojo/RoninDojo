#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh

cmd=(dialog --title "RoninDojo" --separate-output --checklist "Use Mouse Click or Spacebar to select:" 22 76 16)
options=(1 "Setup System & Install Dependencies" off    # any option can be set to default to "on"
         2 "Install RoninDojo" off
         3 "Go Back" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            bash "$HOME"/RoninDojo/Scripts/Install/install-system-setup.sh
            # runs system setup script which will installs dependencies, setup ssd, assigns local ip range to ufw, etc.
            ;;
        2)
            bash "$HOME"/RoninDojo/Scripts/Install/install-dojo.sh
            # runs dojo install script
            ;;
        3)
            bash "$HOME"/RoninDojo/ronin
            # return to main ronin menu
            ;;
    esac
done
