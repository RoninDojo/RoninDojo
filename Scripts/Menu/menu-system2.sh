#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="RoninDojo"
MENU="Choose one of the following options:"

OPTIONS=(1 "Lock Root User"
         2 "Unlock Root User"
         3 "Upgrade Ronin"
         4 "Mount Existing Backup Drive"
         5 "Format & Mount New Backup Drive"
         6 "Go Back")

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
            echo "Locking Root User..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo passwd -l root
            bash ~/RoninDojo/Scripts/Menu/menu-system2.sh
            # uses passwd to lock root user, returns to menu
            ;;
	2)
            echo -e "${RED}"
            echo "***"
            echo "Unlocking Root User..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo passwd -u root
            bash ~/RoninDojo/Scripts/Menu/menu-system2.sh
            # uses passwd to unlock root user, returns to menu
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Upgrading Ronin..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            echo "sudo rm -rf ~/RoninDojo" > ~/ronin-update.sh
            echo "cd ~" >> ~/ronin-update.sh
            echo "git clone https://github.com/RoninDojo/RoninDojo.git" >> ~/ronin-update.sh
            echo "sudo cp ~/RoninDojo/ronin /usr/local/bin"
            echo "bash ~/RoninDojo/Scripts/Menu/menu-system2.sh" >> ~/ronin-update.sh
            sudo chmod +x ~/ronin-update.sh
            bash ~/ronin-update.sh
            # returns to menu
            ;;
        4)
            bash ~/RoninDojo/Scripts/Install/install-mount-backup-data-drive.sh
            # mounts /dev/sdb1 to /mnt/usb1 for access to backup blockchain data
            ;;
        5)
            bash ~/RoninDojo/Scripts/Install/install-new-backup-data-drive.sh
            # formats /dev/sdb1 to ext 4 and mounts to /mnt/usb1 for backing up data on /dev/sda1 or /mnt/usb
            ;;
        6)
            bash ~/RoninDojo/Scripts/Menu/menu-system.sh
            # returns to menu
            ;;
esac
