#!/bin/bash

. ~/RoninDojo/Scripts/defaults.sh
. ~/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Lock Root User"
         2 "Unlock Root User"
         3 "Upgrade Ronin Dojo"
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
            _sleep 2
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
            _sleep 2
            sudo passwd -u root
            bash ~/RoninDojo/Scripts/Menu/menu-system2.sh
            # uses passwd to unlock root user, returns to menu
            ;;
        3)
            sudo rm -f ~/ronin-update.sh
	        # using -f here to avoid error output if ~/ronin-update.sh does not exist

            cat <<EOF
${RED}
***
Upgrading RoninDojo...
***
${NC}
EOF
            _sleep 2

            _update_ronin
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