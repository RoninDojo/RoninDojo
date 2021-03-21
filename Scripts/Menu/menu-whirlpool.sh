#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Iniciar"
         2 "Detener"
         3 "Reiniciar"
         4 "Registros"
         5 "Reset"
         6 "Atrás")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            _is_dojo "${ronin_whirlpool_menu}"
            cat <<EOF
${red}
***
Iniciando Whirlpool...
***
${nc}
EOF
            _sleep
            docker start whirlpool 1>/dev/null

            cat <<EOF
${red}
***
No olvides iniciar sesión en GUI para desbloquear el mezclado!
***
${nc}
EOF
            _sleep
            _pause volver
            bash -c "$ronin_whirlpool_menu"
            # see defaults.sh
            # start whirlpool, press to return to menu
            ;;
        2)
            _is_dojo "${ronin_whirlpool_menu}"
            cat <<EOF
${red}
***
Deteniendo Whirlpool...
***
${nc}
EOF
            _sleep
            docker stop whirlpool 1>/dev/null
            _pause volver
            bash -c "$ronin_whirlpool_menu"
            # stop whirlpool, press to return to menu
            # see defaults.sh
            ;;
        3)
            _is_dojo "${ronin_whirlpool_menu}"
            cat <<EOF
${red}
***
Reiniciando Whirlpool...
***
${nc}
EOF
            _sleep
            docker stop whirlpool 1>/dev/null

            docker start whirlpool 1>/dev/null
            _sleep
            _pause volver
            bash -c "$ronin_whirlpool_menu"
            # enable whirlpool at startup, press to return to menu
            # see defaults.sh
	        ;;
        4)
            _is_dojo "${ronin_whirlpool_menu}"
            cat <<EOF
${red}
***
Viendo registros de Whirlpool...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
Presiona Ctrl+C para salir en cualquier momento...
***
${nc}
EOF
            cd "$dojo_path_my_dojo" || exit
            ./dojo.sh logs whirlpool

            bash -c "$ronin_whirlpool_menu"
            # view logs, return to menu
            # see defaults.sh
            ;;
        5)
            _is_dojo "${ronin_whirlpool_menu}"
            cat <<EOF
${red}
***
Re-inicializar Whirlpool reseteará tu cuenta de mixes y generará una nueva API key...
***
${nc}
EOF
            _sleep
            cat <<EOF
${red}
***
Estás seguro de re-inicializar Whirlpool?
***
${nc}
EOF
            while true; do
                read -rp "[${green}Yes${nc}/${red}No${nc}]: " answer
                case $answer in
                    [yY][eE][sS]|[yY])
                        cat <<EOF
${red}
***
Re-inicializando Whirlpool...
***
${nc}
EOF
                        cd "$dojo_path_my_dojo" || exit

                        ./dojo.sh whirlpool reset
                        _sleep

                        cat <<EOF
${red}
***
Re-inicialización completa, deja la APIkey en blanco cuando emparejes con GUI!
***
${nc}
EOF
                        _sleep 5
                        break
                        ;;
                    [nN][oO]|[Nn])
                        _pause volver
                        break
                        ;;
                    *)
                        cat <<EOF
${red}
***
Respuesta no válida! Teclea Y or N
***
${nc}
EOF
                        ;;
                esac
            done

            _sleep

            bash -c "$ronin_whirlpool_menu"
            # re-initate whirlpool, return to menu
            # see defaults.sh
            ;;
        6)
            bash -c "${ronin_samourai_toolkit_menu}"
            # return to menu
            ;;
esac