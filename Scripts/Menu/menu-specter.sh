#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Iniciar"
         2 "Detener"
         3 "Reiniciar"
         4 "Estado"
         5 "Atrás")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
    1)
        if _is_active specter; then
            cat <<EOF
${red}
***
Iniciando servicio de Specter...
***
${nc}
EOF
        fi

        _sleep

        _pause volver
        bash -c "${ronin_specter_menu}"
        # Start specter.service and return to same menu
        ;;
    2)
        if ! _is_active specter; then
            cat <<EOF
${red}
***
Deteniendo servicio de Specter...
***
${nc}
EOF
        sudo systemctl stop --quiet specter
        fi

        _sleep

        _pause volver
        bash -c "${ronin_specter_menu}"
        # Stop specter.service and return to same menu
        ;;
    3)
        cat <<EOF
${red}
***
Reiniciando servicio de Specter...
***
${nc}
EOF
        sudo systemctl restart --quiet specter

        _sleep

        _pause volver
        bash -c "${ronin_specter_menu}"
        # Restart specter.service and return to same menu
        ;;
    4)
        sudo systemctl status specter

        _pause return

        bash -c "${ronin_specter_menu}"
        ;;
    5)
        bash -c "${ronin_applications_menu}"
        # Return to applications menu
        ;;
esac