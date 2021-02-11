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
        hdd_free_ratio=$(printf "%s" "$(df  | grep "${install_dir}" | awk '{ print $4/$2*100 }')") 2>/dev/null
        hdd=$(printf "%s (%s%%)" "$(df -h | grep "${install_dir}" | awk '{ print $4 }')" "${hdd_free_ratio}")
        echo "External: ${hdd} remaining"
        # disk space info

        _pause return
        bash -c "${ronin_system_storage}"
        # press any key to return to menu
        ;;
    2)
        bash "$HOME"/RoninDojo/Scripts/Install/install-mount-backup-data-drive.sh
        # mounts ${secondary_storage} to ${storage_mount} for access to backup blockchain data
        ;;
    3)
        bash "$HOME"/RoninDojo/Scripts/Install/install-umount-backup-data-drive.sh
        # umounts ${secondary_storage} drive
        ;;
    4)
        bash "$HOME"/RoninDojo/Scripts/Install/install-new-backup-data-drive.sh
        # formats ${secondary_storage} to ext 4 and mounts to ${storage_mount} for backing up data on "${primary_storage}" or ${install_dir}
        ;;
    5)
        bash -c "${ronin_system_menu}"
        # returns to menu
        ;;
esac