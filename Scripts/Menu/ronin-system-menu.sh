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
         4 "Restart"
         5 "Power Off"
	 6 "Lock Root User"
	 7 "Unlock Root User"
	 8 "Update Ronin UI"
	 9 "Go Back")

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
	    bash ~/RoninDojo/Scripts/Menu/ronin-system-menu.sh
            # returns to main menu
            ;;
	2)
            echo -e "${RED}"
            echo "***"
            echo "Showing Disk Space Info..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo df -h
            # disk space info
            
            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/ronin-system-menu.sh
            # press any key to return to menu
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Checking for system updates, not recommended on your own!"
            echo "***"
            echo -e "${NC}"
            sleep 5s
            sudo pacman -Syu
	    bash ~/RoninDojo/Scripts/Menu/ronin-system-menu.sh
            # check for system updates, then return to menu
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Restarting in 10s, or press Ctrl + C to cancel now..."
            echo "***"
            echo -e "${NC}"
            sleep 10s
            sudo shutdown -r now
            # disk space info
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Powering off in 10s, press Ctrl + C to cancel..."
            echo "***"
            echo -e "${NC}"
            sleep 10s
            sudo shutdown now
            # Shut down pi
            ;;
	6)
            echo -e "${RED}"
            echo "***"
            echo "Locking Root User..."
            echo "***"
            echo -e "${NC}"
	    sleep 2s
	    sudo passwd -l root
	    bash ~/RoninDojo/Scripts/Menu/ronin-system-menu.sh
            # uses passwd to lock root user, returns to menu
            ;;
	7)
            echo -e "${RED}"
            echo "***"
            echo "Unlocking Root User..."
            echo "***"
            echo -e "${NC}"
	    sleep 2s
	    sudo passwd -u root
	    bash ~/RoninDojo/Scripts/Menu/ronin-system-menu.sh
	    # uses passwd to unlock root user, returns to menu
            ;;
        8)
            echo -e "${RED}"
            echo "***"
            echo "Updating Ronin UI..."
            echo "***"
            echo -e "${NC}"
	    sleep 2s
	    echo "sudo rm -rf ~/RoninDojo" > ~/ronin-update.sh
	    echo "cd ~" >> ~/ronin-update.sh
	    echo "git clone -b development https://github.com/RoninDojo/RoninDojo.git" >> ~/ronin-update.sh
	    echo "bash ~/RoninDojo/Scripts/Menu/ronin-system-menu.sh" >> ~/ronin-update.sh
	    sudo chmod +x ~/ronin-update.sh
	    bash ~/ronin-update.sh
            # returns to main menu
            ;;

        9)
            bash ~/RoninDojo/ronin
            # returns to main menu
            ;;
esac
