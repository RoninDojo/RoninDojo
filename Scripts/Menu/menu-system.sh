#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Firewall"
         2 "Check Disk Space"
         3 "Check for System Updates"
         4 "Check Temperature"
         5 "Check Network Stats"
         6 "Restart"
         7 "Power Off"
         8 "Next Page"
         9 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
        1)
            bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-firewall.sh
            ;;
	    2)
            echo -e "${RED}"
            echo "***"
            echo "Showing Disk Space Info..."
            echo "***"
            echo -e "${NC}"
            _sleep 2

            sd_free_ratio=$(printf "%s" "$(df | grep "/$" | awk '{ print $4/$2*100 }')") 2>/dev/null
            sd=$(printf "%s (%s%%)" "$(df -h | grep '/$' | awk '{ print $4 }')" "${sd_free_ratio}")
            echo "Internal: ${sd} remaining"
            hdd_free_ratio=$(printf "%s" "$(df  | grep "${INSTALL_DIR}" | awk '{ print $4/$2*100 }')") 2>/dev/null
            hdd=$(printf "%s (%s%%)" "$(df -h | grep "${INSTALL_DIR}" | awk '{ print $4 }')" "${hdd_free_ratio}")
            echo "External: ${hdd} remaining"
            # disk space info

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-system.sh
            # press any key to return to menu
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Checking for system updates..."
            echo "***"
            echo -e "${NC}"
            _sleep 5
            sudo pacman -Syu
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-system.sh
            # check for system updates, then return to menu
            ;;
	    4)
            echo -e "${RED}"
            echo "***"
            echo "Showing CPU temp..."
            echo "***"
            echo -e "${NC}"
            _sleep
            cpu=$(cat /sys/class/thermal/thermal_zone0/temp)
            tempC=$((cpu/1000))
            echo $tempC $'\xc2\xb0'C
            # cpu temp info

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-system.sh
            # press any key to return to menu
            ;;
	    5)
            echo -e "${RED}"
            echo "***"
            echo "Showing network stats..."
            echo "***"
            echo -e "${NC}"
            _sleep
            ifconfig eth0 | grep 'inet'
            network_rx=$(ifconfig eth0 | grep 'RX packets' | awk '{ print $6$7 }' | sed 's/[()]//g')
            network_tx=$(ifconfig eth0 | grep 'TX packets' | awk '{ print $6$7 }' | sed 's/[()]//g')
            echo "        Receive: $network_rx"
            echo "        Transmit: $network_tx"
            # network info, use wlan0 for wireless

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-system.sh
            # press any key to return to menu
            ;;
        6)
            if [ -d "$HOME"/dojo ]; then
              echo -e "${RED}"
              echo "***"
              echo "Shutting down Dojo if running..."
              echo "***"
              echo -e "${NC}"
              cd "${DOJO_PATH}" || exit
              _stop_dojo
              # stop dojo

              echo -e "${RED}"
              echo "***"
              echo "Restarting in 5s, or press Ctrl + C to cancel now..."
              echo "***"
              echo -e "${NC}"
              _sleep 5
              sudo systemctl reboot
              # restart machine
	        else
              echo -e "${RED}"
              echo "***"
              echo "Restarting in 5s, or press Ctrl + C to cancel now..."
              echo "***"
              echo -e "${NC}"
              _sleep 5
              sudo systemctl reboot
              # restart machine
            fi
            ;;
        7)
            if [ -d "$HOME"/dojo ]; then
              echo -e "${RED}"
              echo "***"
              echo "Shutting down Dojo if running..."
              echo "***"
              echo -e "${NC}"
              cd "${DOJO_PATH}" || exit
              _stop_dojo
              # stop dojo

              echo -e "${RED}"
              echo "***"
              echo "Powering off in 5s, or press Ctrl + C to cancel now..."
              echo "***"
              echo -e "${NC}"
              _sleep 5
              sudo systemctl poweroff
              # power off machine
	        else
              echo -e "${RED}"
              echo "***"
              echo "Powering off in 5s, or press Ctrl + C to cancel now..."
              echo "***"
              echo -e "${NC}"
              _sleep 5
              sudo systemctl poweroff
              # power off machine
            fi
            ;;
        8)
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-system2.sh
            # goes to next page
            ;;
        9)
            bash -c ronin
            # returns to main menu
            ;;
esac
