#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Visualizador de la mempool"
         2 "Servidor de Specter"
         3 "Servidor de Electrum"
         4 "Estado de la conexión con Bisq"
         5 "Control de los ventiladores"
         6 "Menú de instalación de aplicaciones"
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
        if ! _is_mempool ; then
            cat <<EOF
${red}
***
Mempool no esta instalado!
***
${nc}
EOF
            _sleep
            cat <<EOF
${red}
***
Instala Mempool usando el menú de instalación de aplicaciones...
***
${nc}
EOF
            _sleep
            _pause volver
            bash -c "${ronin_applications_menu}"
        else
            bash -c "${ronin_mempool_menu}"
        # Mempool Space Visualizer menu
        fi
        ;;
    2)
        if ! _is_specter ; then
            cat <<EOF
${red}
***
Servidor de Specter no instalado!
***
${nc}
EOF
            _sleep
            cat <<EOF
${red}
***
Install Specter Server using the manage applications menu...
***
${nc}
EOF
            _sleep
            _pause volver
            bash -c "${ronin_applications_menu}"
        else
            bash -c "${ronin_specter_menu}"
        fi
        # Specter menu
        ;;
    3)
        if ! _is_electrs; then
            bash -c "${ronin_applications_menu}"
            exit 1
        fi
        # check if electrs is already installed

        bash -c "${ronin_electrs_menu}"
        # runs electrs menu script
        ;;
    4)
        cat <<EOF
${red}
***
Verificando la compatibilidad de tu RoninDojo con Bisq...
***
${nc}
EOF
        _sleep
        if ! _is_bisq ; then
            cat <<EOF
${red}
***
Las conexiones con bisq no están habilitadas...
***
${nc}
EOF
            _sleep
            cat <<EOF
${red}
***
Habilita las conexiones de Bisq usando el menú de instalación de aplicaciones...
***
${nc}
EOF
            _sleep
            _pause volver
            bash -c "$ronin_applications_menu"
        else
            cat <<EOF
${red}
***
Las conexiones con Bisq están habilitadas...
***
${nc}
EOF
            _sleep
            cat <<EOF
${red}
***
Disfruta esos sats sin KYC...
***
${nc}
EOF
            _sleep
            _pause volver
            bash -c "$ronin_applications_menu"
        fi
        # Bisq check
        ;;
    5)
        if ! which_sbc rockpro64; then
            cat <<EOF
${red}
***
Placa sin soporte detectada para el control de los ventiladores...
***
EOF
            _sleep
            cat <<EOF
${red}
***
Los dispositivos soportados són Rockpro64 y Rockpi4...
***
${nc}
EOF
            _sleep

            _pause volver
            bash -c "$ronin_applications_menu"
            exit
        fi

        # Check for package dependencies
        for pkg in go gcc; do
            _check_pkg "${pkg}"
        done

        _check_pkg "ldd" "glibc"

        if [ ! -f /etc/systemd/system/bbbfancontrol.service ]; then
            cat <<EOF
${red}
***
Instalando control de ventiladores...
***
${nc}
EOF
            cd "${HOME}" || exit

            _fan_control_install || exit 1

            _pause volver

            bash -c "${ronin_applications_menu}"
            # Manage applications menu
        else
            cat <<EOF
${red}
***
Control de ventiladores ya instalado...
***
${nc}
EOF

            _sleep

            cat <<EOF
${red}
***
Comprobando actualizaciones del control de ventiladores...
***
${nc}
EOF

            if ! _fan_control_install; then
                cat <<EOF
${red}
***
Control de ventiladores ya actualizado...
***
${nc}
EOF
            fi
        fi

        _pause volver

        bash -c "${ronin_applications_menu}"
        ;;
    6)
        bash -c "${ronin_applications_manage_menu}"
        # Manage applications menu
        ;;
    7)
        ronin
        # returns to main menu
        ;;
esac
