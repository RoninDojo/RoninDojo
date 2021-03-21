#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh

cmd=(dialog --title "RoninDojo" --separate-output --checklist "Use Mouse Click or Spacebar to select:" 22 76 16)
options=(1 "Configuración del sistema" off    # any option can be set to default to "on"
         2 "Instalar RoninDojo" off)
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
    esac
done

bash -c "${ronin_system_menu}"
# return to menu