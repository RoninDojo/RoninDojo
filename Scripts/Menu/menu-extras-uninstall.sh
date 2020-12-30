#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

cmd=(dialog --title "RoninDojo" --separate-output --checklist "Use Mouse Click or Spacebar to select:" 22 76 16)
options=(1 "Uninstall Mempool Visualizer" off    # any option can be set to default to "on"
         2 "Uninstall Specter" off
         3 "Remove Bisq Connetivity" off
         4 "Finalize Changes" on
         3 "Go Back" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            sed -i 's/MEMPOOL_INSTALL=.*$/MEMPOOL_INSTALL=off/' "$dojo_path_my_dojo"/conf/docker-mempool.conf
            # turns mempool install set to off
            ;;
        2)
            sudo rm -rf "$HOME"/.specter "$HOME"/specter-* /etc/systemd/system/specter.service
            # deletes the .specter dir, source dir, and specter.service file
            ;;
        3)
            rm -rf "${INSTALL_DIR_USER}"/bisq.txt
            # deletes bisq.txt file
            ;;
        4)
            cat <<EOF
${RED}
***
Performing Local "upgrade" of Dojo to complete install process...
***
${NC}
EOF
            _sleep 5 --msg "Press Ctrl+C to exit...otherwise, upgrading Dojo in..."
            cd "${dojo_path_my_dojo}" || exit
            ./dojo.sh upgrade --nologs
            # upgrade dojo. default to on.
            ;;
        5)
            bash -c "$RONIN_EXTRAS_MENU"
            # return to extras menu
            ;;
    esac
done