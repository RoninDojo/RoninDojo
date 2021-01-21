#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

cmd=(dialog --title "RoninDojo" --separate-output --checklist "Use Mouse Click or Spacebar to select:" 22 76 16)
options=(1 "Uninstall Mempool Visualizer" off    # any option can be set to default to "on"
         2 "Uninstall Specter" off
         3 "Disable Bisq Connection" off
         4 "Go Back" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            sed -i 's/MEMPOOL_INSTALL=.*$/MEMPOOL_INSTALL=off/' "$dojo_path_my_dojo"/conf/docker-mempool.conf
            # Turns mempool install set to off
            ;;
        2)
            if systemctl is-active specter; then
                sudo systemctl stop specter
                sudo systemctl disable specter 1>/dev/null
            fi

            sudo rm -rf "$HOME"/.specter "$HOME"/specter-* /etc/systemd/system/specter.service
            # Deletes the .specter dir, source dir, and specter.service file
            ;;
        3)
            rm "${INSTALL_DIR_USER}"/bisq.txt
            # Deletes bisq.txt file
            ;;
        4)
            bash -c "$RONIN_APPLICATIONS_MENU"
            # Return to application menu
            ;;
    esac
done