#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Check Disk Space"
         2 "Mount Backup Drive"
         3 "Unmount Backup Drive"
         4 "Format & Mount New Backup Drive"
         5 "Go Back")

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
${RED}
***
Showing Disk Space Info...
***
${NC}
EOF
_sleep 2

        sd_free_ratio=$(printf "%s" "$(df | grep "/$" | awk '{ print $4/$2*100 }')") 2>/dev/null
        sd=$(printf "%s (%s%%)" "$(df -h | grep '/$' | awk '{ print $4 }')" "${sd_free_ratio}")
        echo "Internal: ${sd} remaining"
        hdd_free_ratio=$(printf "%s" "$(df  | grep "${INSTALL_DIR}" | awk '{ print $4/$2*100 }')") 2>/dev/null
        hdd=$(printf "%s (%s%%)" "$(df -h | grep "${INSTALL_DIR}" | awk '{ print $4 }')" "${hdd_free_ratio}")
        echo "External: ${hdd} remaining"
        # disk space info

        cat <<EOF
${RED}
***
Press any key to return...
***
${NC}
EOF
        _pause
        bash -c "${RONIN_SYSTEM_STORAGE}"
        # press any key to return to menu
        ;;
    2)
        bash "$HOME"/RoninDojo/Scripts/Install/install-mount-backup-data-drive.sh
        # mounts ${SECONDARY_STORAGE} to ${STORAGE_MOUNT} for access to backup blockchain data
        ;;
    3)
        bash "$HOME"/RoninDojo/Scripts/Install/install-umount-backup-data-drive.sh
        # umounts ${SECONDARY_STORAGE} drive
        ;;
    4)
        bash "$HOME"/RoninDojo/Scripts/Install/install-new-backup-data-drive.sh
        # formats ${SECONDARY_STORAGE} to ext 4 and mounts to ${STORAGE_MOUNT} for backing up data on "${PRIMARY_STORAGE}" or ${INSTALL_DIR}
        ;;
    5)
        bash -c "${RONIN_SYSTEM_MENU}"
        # returns to menu
        ;;
esac