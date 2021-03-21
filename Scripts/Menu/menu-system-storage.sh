#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Comprobar espacio del disco"
         2 "Formatear y montar nueva copia de seguridad"
         3 "Atrás")

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
Mostrando información de espacio en disco...
***
${nc}
EOF
_sleep

        sd_free_ratio=$(printf "%s" "$(df | grep "/$" | awk '{ print $4/$2*100 }')") 2>/dev/null
        sd=$(printf "%s (%s%%)" "$(df -h | grep '/$' | awk '{ print $4 }')" "${sd_free_ratio}")
        echo "Interno: ${sd} remaining"
        hdd_free_ratio=$(printf "%s" "$(df  | grep "${install_dir}" | awk '{ print $4/$2*100 }')") 2>/dev/null
        hdd=$(printf "%s (%s%%)" "$(df -h | grep "${install_dir}" | awk '{ print $4 }')" "${hdd_free_ratio}")
        echo "Externo: ${hdd} restante"
        # disk space info

        _pause volver
        bash -c "${ronin_system_storage}"
        # press any key to return to menu
        ;;
    2)
        bash "$HOME"/RoninDojo/Scripts/Install/install-new-backup-data-drive.sh
        # formats ${secondary_storage} to ext 4 and mounts to ${storage_mount} for backing up data on "${primary_storage}" or ${install_dir}
        ;;
    3)
        bash -c "${ronin_system_menu}"
        # returns to menu
        ;;
esac