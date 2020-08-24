#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Task Manager"
         2 "Lock Root User"
         3 "Unlock Root User"
         4 "Upgrade RoninDojo"
         5 "Mount Existing Backup Drive"
         6 "UMount Existing Backup Drive"
         7 "Format & Mount New Backup Drive"
         8 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
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
        _sleep 3
        htop
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system.sh
        # returns to main menu
        ;;
	2)
            echo -e "${RED}"
            echo "***"
            echo "Locking Root User..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            sudo passwd -l root
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-system2.sh
            # uses passwd to lock root user, returns to menu
            ;;
	3)
            echo -e "${RED}"
            echo "***"
            echo "Unlocking Root User..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            sudo passwd -u root
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-system2.sh
            # uses passwd to unlock root user, returns to menu
            ;;
    4)
            sudo rm -f "$HOME"/ronin-update.sh
	        # using -f here to avoid error output if "$HOME"/ronin-update.sh does not exist

            cat <<EOF
${RED}
***
Upgrading RoninDojo...
***
${NC}
EOF
            _sleep 2

            _update_ronin
            # see functions.sh
            ;;
    5)
        bash "$HOME"/RoninDojo/Scripts/Install/install-mount-backup-data-drive.sh
        # mounts ${SECONDARY_STORAGE} to ${SALVAGE_MOUNT} for access to backup blockchain data
        ;;
    6)
        bash "$HOME"/RoninDojo/Scripts/Install/install-umount-backup-data-drive.sh
        # umounts ${SECONDARY_STORAGE} drive
        ;;
    7)
        bash "$HOME"/RoninDojo/Scripts/Install/install-new-backup-data-drive.sh
        # formats ${SECONDARY_STORAGE} to ext 4 and mounts to ${SALVAGE_MOUNT} for backing up data on "${PRIMARY_STORAGE}" or ${INSTALL_DIR}
        ;;
    8)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system.sh
        # returns to menu
        ;;
esac