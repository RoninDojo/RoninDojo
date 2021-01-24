#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

upgrade=false
cmd=(dialog --title "RoninDojo" --separate-output --checklist "Use Mouse Click or Spacebar to select:" 22 76 16)
options=(1 "Uninstall Mempool Visualizer" off    # any option can be set to default to "on"
         2 "Uninstall Specter" off
         3 "Disable Bisq Connection" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            sed -i 's/MEMPOOL_INSTALL=.*$/MEMPOOL_INSTALL=off/' "$dojo_path_my_dojo"/conf/docker-mempool.conf
            # Turns mempool install set to off
            upgrade=true
            ;;
        2)
            if _is_specter; then
                _specter_uninstall
                upgrade=true
            else
                cat <<EOF
${RED}
***
Specter Server is not available to uninstall...
***
${NC}
EOF
            _pause return
            ronin
            fi
            ;;
        3)
            rm "${ronin_data_dir}"/bisq.txt
            # Deletes bisq.txt file

            upgrade=true
            ;;
    esac
done

if $upgrade; then
    _dojo_upgrade
else
    cat <<EOF
${RED}
***
Nothing to install...
***
${NC}
EOF
    _pause return
    ronin
fi