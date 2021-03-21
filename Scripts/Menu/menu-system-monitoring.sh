#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Administrador de tareas"
         2 "Comprobar Temperatura"
         3 "Comprobar estadísticas de la red"
         4 "Atrás")

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
Pulsa Ctrl + C para salir en cualquier momento del administrador de tareas...
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
Mostrando temperatura de la cpu...
***
${nc}
EOF
        _sleep
        cpu=$(cat /sys/class/thermal/thermal_zone0/temp)
        tempC=$((cpu/1000))
        echo $tempC $'\xc2\xb0'C
        # cpu temp info

        _pause volver
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-monitoring.sh
        # press any key to return to menu
        ;;
    3)
        cat <<EOF
${red}
***
Mostrando estadísticas de la red...
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

        _pause volver
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-monitoring.sh
        # press any key to return to menu
        ;;
    4)
        bash -c "${ronin_system_menu}"
        # returns to menu
        ;;
esac