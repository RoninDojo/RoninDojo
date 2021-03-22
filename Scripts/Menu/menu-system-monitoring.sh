#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Task Manager"
         2 "Check Temperature"
         3 "Check Network Stats"
         4 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
    1)
        cat <<EOF
${red}
***
Use Ctrl+C at any time to exit Task Manager...
***
${nc}
EOF
        _sleep 3
        htop
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-monitoring.sh
        # returns to menu
        ;;
    2)
        cat <<EOF
${red}
***
Showing CPU temp...
***
${nc}
EOF
        _sleep
        cpu=$(cat /sys/class/thermal/thermal_zone0/temp)
        tempC=$((cpu/1000))
        echo $tempC $'\xc2\xb0'C
        # cpu temp info

        _pause return
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-monitoring.sh
        # press any key to return to menu
        ;;
    3)
        cat <<EOF
${red}
***
Showing network stats...
***
${nc}
EOF
        _sleep
        ifconfig eth0 | grep 'inet'
        network_rx=$(ifconfig eth0 | grep 'RX packets' | awk '{ print $6$7 }' | sed 's/[()]//g')
        network_tx=$(ifconfig eth0 | grep 'TX packets' | awk '{ print $6$7 }' | sed 's/[()]//g')
        echo "        Receive: $network_rx"
        echo "        Transmit: $network_tx"
        # network info, use wlan0 for wireless

        _pause return
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-monitoring.sh
        # press any key to return to menu
        ;;
    4)
        bash -c "${ronin_system_menu}"
        # returns to menu
        ;;
esac