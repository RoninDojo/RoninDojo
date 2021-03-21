#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Iniciar"
         2 "Detener"
         3 "Reiniciar"
         4 "Registros"
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
        if ! _is_mempool ; then
            cat <<EOF
${red}
***
Mempool.space no esta instalado...
***
${nc}
EOF
            _sleep
            _pause volver
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${red}
***
Iniciando Mempool...
***
${nc}
EOF
            docker start mempool 1>/dev/null
            _sleep 5
            _pause volver
            bash -c "${ronin_mempool_menu}"
            # see defaults.sh
            # start mempool, return to menu
        fi
        ;;
    2)
        if ! _is_mempool ; then
            cat <<EOF
${red}
***
Mempool.space no esta instalado...
***
${nc}
EOF
            _sleep
            _pause volver
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${red}
***
Deteniendo Mempool...
***
${nc}
EOF
            docker stop mempool 1>/dev/null
            _pause volver
            bash -c "${ronin_mempool_menu}"
            # stop mempool, return to menu
            # see defaults.sh
        fi
        ;;
    3)
        if ! _is_mempool ; then
            cat <<EOF
${red}
***
Mempool.space no esta instalado...
***
${nc}
EOF
            _sleep
            _pause volver
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${red}
***
Reiniciando Mempool...
***
${nc}
EOF
            docker stop mempool 1>/dev/null
            _sleep 5
            docker start mempool 1>/dev/null
            _sleep

            _pause volver
            bash -c "${ronin_mempool_menu}"
            # start mempool, return to menu
            # see defaults.sh
        fi
        ;;
    4)
        if ! _is_mempool ; then
            cat <<EOF
${red}
***
Mempool.space no esta instalado...
***
${nc}
EOF
            _sleep
            _pause volver
            bash -c "${ronin_mempool_menu}"
        else
            cat <<EOF
${red}
***
Viendo registros de la Mempool...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
Pulsa Ctrl + C para salir en cualquier momento...
***
${nc}
EOF
            cd "$dojo_path_my_dojo" || exit
            ./dojo.sh logs mempool
            bash -c "${ronin_mempool_menu}"
            # view logs, return to menu
            # see defaults.sh
        fi
        ;;
    5)
        ronin
        # return to menu
        ;;
esac