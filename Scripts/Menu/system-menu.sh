#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="Ronin UI"
MENU="Choose one of the following options:"

OPTIONS=(1 "Task Manager"
         2 "Check Disk Space"
	 3 "Check for System Updates"
	 4 "Check Temperature"
	 5 "Check Network Stats"
         6 "Restart"
         7 "Power Off"
	 8 "Lock Root User"
	 9 "Unlock Root User"
	 10 "Update Ronin UI"
	 11 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo -e "${RED}"
            echo "***"
            echo "Use Ctrl+C at any time to exit Task Manager."
            echo "***"
            echo -e "${NC}"
	    sleep 3s
	    htop
	    bash ~/RoninDojo/Scripts/Menu/system-menu.sh
            # returns to main menu
            ;;
	2)
            echo -e "${RED}"
            echo "***"
            echo "Showing Disk Space Info..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
	    
            sd_free_ratio=$(printf "%s" "$(df | grep "/$" | awk '{ print $4/$2*100 }')") 2>/dev/null
            sd=$(printf "%s (%s%%)" "$(df -h | grep '/$' | awk '{ print $4 }')" "${sd_free_ratio}")
            echo "Internal: "${sd} "remaining"
            hdd_free_ratio=$(printf "%s" "$(df  | grep "/mnt/usb" | awk '{ print $4/$2*100 }')") 2>/dev/null
            hdd=$(printf "%s (%s%%)" "$(df -h | grep "/mnt/usb" | awk '{ print $4 }')" "${hdd_free_ratio}")
            echo "External: " ${hdd} "remaining"
            # disk space info
            
            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/system-menu.sh
            # press any key to return to menu
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Checking for system updates..."
            echo "***"
            echo -e "${NC}"
            sleep 5s
            sudo pacman -Syu
	    bash ~/RoninDojo/Scripts/Menu/system-menu.sh
            # check for system updates, then return to menu
            ;;
	4)
            echo -e "${RED}"
            echo "***"
            echo "Showing CPU temp..."
            echo "***"
            echo -e "${NC}"
            sleep 1s
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
            bash ~/RoninDojo/Scripts/Menu/system-menu.sh
            # press any key to return to menu
            ;;
	5)
            echo -e "${RED}"
            echo "***"
            echo "Showing network stats..."
            echo "***"
            echo -e "${NC}"
            sleep 1s
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
            bash ~/RoninDojo/Scripts/Menu/system-menu.sh
            # press any key to return to menu
            ;;
        6)
            echo -e "${RED}"
            echo "***"
            echo "Restarting in 10s, or press Ctrl + C to cancel now..."
            echo "***"
            echo -e "${NC}"
            sleep 10s

            echo -e "${RED}"
            echo "***"
            echo "Shutting down Dojo if running..."
            echo "***"
            echo -e "${NC}"
            cd ~/dojo/docker/my-dojo/
            sudo ./dojo.sh stop
            sudo shutdown -r now
            # stop dojo and restart machine
            ;;
        7)
            echo -e "${RED}"
            echo "***"
            echo "Powering off in 10s, press Ctrl + C to cancel..."
            echo "***"
            echo -e "${NC}"
            sleep 10s

            sudo shutdown now
            # stop dojo and restart machine
            ;;
	8)
            echo -e "${RED}"
            echo "***"
            echo "Locking Root User..."
            echo "***"
            echo -e "${NC}"
	    sleep 2s
	    sudo passwd -l root
	    bash ~/RoninDojo/Scripts/Menu/system-menu.sh
            # uses passwd to lock root user, returns to menu
            ;;
	9)
            echo -e "${RED}"
            echo "***"
            echo "Unlocking Root User..."
            echo "***"
            echo -e "${NC}"
	    sleep 2s
	    sudo passwd -u root
	    bash ~/RoninDojo/Scripts/Menu/system-menu.sh
	    # uses passwd to unlock root user, returns to menu
            ;;
        10)
            echo -e "${RED}"
            echo "***"
            echo "Updating Ronin UI..."
            echo "***"
            echo -e "${NC}"
	    sleep 2s
	    echo "sudo rm -rf ~/RoninDojo" > ~/ronin-update.sh
	    echo "cd ~" >> ~/ronin-update.sh
	    echo "git clone https://github.com/RoninDojo/RoninDojo.git" >> ~/ronin-update.sh
	    echo "sudo cp ~/RoninDojo/ronin /usr/local/bin"
	    echo "bash ~/RoninDojo/Scripts/Menu/system-menu.sh" >> ~/ronin-update.sh
	    sudo chmod +x ~/ronin-update.sh
	    bash ~/ronin-update.sh
            # returns to menu
            ;;

        11)
            bash ~/RoninDojo/ronin
            # returns to main menu
            ;;
esac
