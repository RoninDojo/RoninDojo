#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Bitcoind"
         2 "MariaDB"
         3 "Indexer"
         4 "Node.js"
         5 "Tor"
         6 "Whirlpool"
         7 "Registro de errores"
         8 "Todos los registros"
         9 "Atrás")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            # checks if dojo is running (check the db container), if not running tells user to start dojo first
            if ! _dojo_check; then
                cat <<EOF
${red}
***
Por favor primero inicia Dojo!
***
${nc}
EOF
                _sleep 5

                _pause volver

                bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            else
                cat <<EOF
${red}
***
Pulsa Ctrl + C para salir en cualquier momento...
***
${nc}
EOF
              _sleep

              cd "${dojo_path_my_dojo}" || exit

              ./dojo.sh logs bitcoind

              bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
              # shows logs for bitcoind
            fi
            ;;
        2)
            if ! _dojo_check; then
                cat <<EOF
${red}
***
Por favor primero inicia Dojo!
***
${nc}
EOF
                _sleep 5

                _pause volver

                bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            else
              cat <<EOF
${red}
***
Pulsa Ctrl + C para salir en cualquier momento...
***
${nc}
EOF
              _sleep

              cd "${dojo_path_my_dojo}" || exit
              ./dojo.sh logs db

              bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
              # shows logs for db
            fi
            ;;
        3)
            if ! _dojo_check; then
                cat <<EOF
${red}
***
Por favor primero inicia Dojo!
***
${nc}
EOF
                _sleep 5

                _pause volver

                bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            else
                if grep "INDEXER_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
                    cat <<EOF
${red}
***
El servidor de Electrum Rust es tu indexador actual....
***
${nc}
EOF
                    _sleep
                    cat <<EOF
${red}
***
Por favor en su lugar comprueba los registros de Electum rust...
***
${nc}
EOF
                    _sleep

                    _pause volver

                    bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
                    exit 1
                elif grep "INDEXER_INSTALL=off" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null; then
                    cat <<EOF
${red}
***
No hay indexador instalado...
***
${nc}
EOF
                    _sleep
                    cat <<EOF
${red}
***
Instala usando el menú de instalación de aplicaciones...
***
${nc}
EOF
                    _sleep

                    _pause volver

                    bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
                    exit
                else
                    cat <<EOF
${red}
***
Pulsa Ctrl + C para salir en cualquier momento...
***
${nc}
EOF
                    _sleep

                    cd "${dojo_path_my_dojo}" || exit

                    ./dojo.sh logs indexer

                    bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
                    # shows logs for nginx
                fi
            fi
            ;;
        4)
            if ! _dojo_check; then
                cat <<EOF
${red}
***
Por favor primero inicia Dojo!
***
${nc}
EOF
                _sleep 5

                _pause volver

                bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            else
              cat <<EOF
${red}
***
Pulsa Ctrl + C para salir en cualquier momento...
***
${nc}
EOF
              _sleep

              cd "${dojo_path_my_dojo}" || exit
              ./dojo.sh logs node

              bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
              # shows logs for nodejs
            fi
            ;;
        5)
            if ! _dojo_check; then
                cat <<EOF
${red}
***
Por favor primero inicia Dojo!
***
${nc}
EOF
                _sleep 5

                _pause volver

                bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            else
              cat <<EOF
${red}
***
Pulsa Ctrl + C para salir en cualquier momento...
***
${nc}
EOF
              _sleep

              cd "${dojo_path_my_dojo}" || exit
              ./dojo.sh logs tor

              bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
              # shows logs for tor
            fi
            ;;
        6)
            if ! _dojo_check; then
                cat <<EOF
${red}
***
Por favor primero inicia Dojo!
***
${nc}
EOF
                _sleep 5

                _pause volver

                bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            else
              _sleep

              cat <<EOF
${red}
***
Pulsa Ctrl + C para salir en cualquier momento...
***
${nc}
EOF
              cd "${dojo_path_my_dojo}" || exit
              ./dojo.sh logs whirlpool

              bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
              # view logs, return to menu
              # see defaults.sh
            fi
            ;;
        7)
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # goes to error logs menu
            ;;
        8)
            if ! _dojo_check; then
                cat <<EOF
${red}
***
Por favor primero inicia Dojo!
***
${nc}
EOF
                _sleep 5

                _pause volver

                bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            else
              _sleep

              cat <<EOF
${red}
***
Pulsa Ctrl + C para salir en cualquier momento...
***
${nc}
EOF
              cd "${dojo_path_my_dojo}" || exit
              ./dojo.sh logs

              bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
              # view logs, return to menu
              # see defaults.sh
            fi
            ;;
        9)
            bash -c "${ronin_dojo_menu}"
            # goes back to ronin dojo menu
            ;;
esac
