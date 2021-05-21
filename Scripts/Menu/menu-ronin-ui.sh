#!/bin/bash
# shellcheck source=/dev/null disable=SC2153,SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Iniciar"
         2 "Detener"
         3 "Reiniciar"
         4 "Estado"
         5 "Registros"
         6 "Reiniciar UI"
         7 "Atrás")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
	1)
        # Check if process running, otherwise start it
        if pm2 describe "RoninUI" | grep status | grep stopped 1>/dev/null; then
            cat <<EOF
${red}
***
Inicio de Ronin UI...
***
${nc}
EOF
            _sleep
            cd "${ronin_ui_path}" || exit

            pm2 start "RoninUI"
        else
            cat <<EOF
${red}
***
La interfaz de usuario del Ronin UI ya comenzó..
***
${nc}
EOF
            _sleep
        fi

        _pause volver
        # press to return is needed so the user has time to see outputs

        bash -c "${ronin_ui_menu}"
        # start Ronin UI, return to menu
        ;;
    2)
        # Check if process running before stopping it
        if pm2 describe "RoninUI" &>/dev/null; then
            cat <<EOF
${red}
***
Deteniendo a Ronin UI...
***
${nc}
EOF
            _sleep
            cd "${ronin_ui_path}" || exit

            pm2 stop "RoninUI"
        else
            cat <<EOF
${red}
***
Ronin UI ya se detuvo...
***
${nc}
EOF
        fi

        _pause volver
        # press to return is needed so the user has time to see outputs

        bash -c "${ronin_ui_menu}"
        # start Ronin UI, return to menu
        ;;
    3)
        cat <<EOF
${red}
***
Reiniciando Ronin UI...
***
${nc}
EOF
        _sleep
        cd "${ronin_ui_path}" || exit

        pm2 restart "RoninUI" 1>/dev/null
        # restart service

        _pause volver
        # press to return is needed so the user has time to see outputs

        bash -c "${ronin_ui_menu}"
        # start Ronin UI, return to menu
        ;;
    4)
        cat <<EOF
${red}
***
Mostrando el estado de Ronin UI...
***
${nc}
EOF

        cd "${ronin_ui_path}" || exit
        pm2 status

        _pause volver
        bash -c "${ronin_ui_menu}"
        ;;
    5)
        cat <<EOF
${red}
***
Mostrar registros de la interfaz de usuario de Ronin UI...
***
${nc}
EOF

        cat <<EOF
${red}
***
Presione la tecla "q" para salir en cualquier momento...
***
${nc}
EOF
        cd "${ronin_ui_path}" || exit

        _sleep 5 # Workaround until a proper FIX!!!
        less --force logs/combined.log

        bash -c "${ronin_ui_menu}"
        ;;
    6)
        cat <<EOF
${red}
***
Restablecimiento de la interfaz de usuario del Ronin UI...
***
${nc}
EOF

        cd "${ronin_ui_path}" || exit

        test -f ronin-ui.dat && rm ronin-ui.dat

        _pause volver

        bash -c "${ronin_ui_menu}"
        ;;
    7)
        ronin
        # returns to main menu
        ;;
esac