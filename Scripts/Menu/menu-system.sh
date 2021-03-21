#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Almacenamiento de disco"
         2 "Apagar"
         3 "Reiniciar"
         4 "Actualizaciones de Software"
         5 "Monitoreo del sistema"
         6 "Configuración del sistema e instalación"
         7 "Siguiente página"
         8 "Atrás")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
    1)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh
        # System storage menu
        ;;
    2)
        if [ -d "${dojo_path}" ]; then
            cat <<EOF
${red}
***
Deteniendo Dojo si estubiera en marcha...
***
${nc}
EOF
            cd "${dojo_path_my_dojo}" || exit
            _dojo_check && _stop_dojo
            # stop dojo

            cat <<EOF
${red}
***
Apagando la máquina, presiona Ctrl + C para cancelar...
***
${nc}
EOF
            _sleep

            _pause continue

            sudo systemctl poweroff
            # power off machine
        else
            cat <<EOF
${red}
***
Apagando la máquina, presiona Ctrl + C para cancelar...
***
${nc}
EOF
            _sleep

            _pause continue

            sudo systemctl poweroff
            # power off machine
        fi
        ;;
    3)
        if [ -d "${dojo_path}" ]; then
            cat <<EOF
${red}
***
Deteniendo Dojo si estubiera en marcha...
***
${nc}
EOF
            cd "${dojo_path_my_dojo}" || exit

            _dojo_check && _stop_dojo
            # stop dojo

            cat <<EOF
${red}
***
Reiniciando la máquina, presiona Ctrl + C para cancelar...
***
${nc}
EOF
            _sleep

            _pause continue

            sudo systemctl reboot
            # restart machine
        else
            cat <<EOF
${red}
***
Reiniciando la máquina, presiona Ctrl + C para cancelar...
***
${nc}
EOF
            _sleep

            _pause continue

            sudo systemctl reboot
            # restart machine
        fi
        ;;

    4)
        bash -c "${ronin_updates_menu}"
        # System updates menu
        ;;
    5)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-monitoring.sh
        # System monitoring menu
        ;;
    6)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-install.sh
        # System Setup & Install menu
        ;;
    7)
        bash -c "${ronin_system_menu2}"
        ;;
    8)
        ronin
        # returns to main menu
        ;;
esac