#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Añadir rango IP para Whirlpool GUI"
         2 "Añadir IP específica para Whirlpool GUI"
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
Obtén la dirección IP específica a la que deseas dar acceso a Whirlpool CLI...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
Tu direción IP en la red local debe parecerse a 192.168.4.21 o 12.34.56.78 dependiendo de tu configuración...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
Introduce la IP local a la que deseas dar acceso a Whirlpool CLI ahora...
***
${nc}
EOF

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address"/24 to any port 8899 comment 'Whirlpool CLI access restricted to local LAN only'

            cat <<EOF
${red}
***
Recargando...
***
${nc}
EOF
            sudo ufw reload
            # reload the firewall

            cat <<EOF
${red}
***
Mostrando estado...
***
${nc}
EOF
            _sleep
            sudo ufw status
            # show firewall status

            cat <<EOF
${red}
***
Asegurate de ver tu nueva regla!
***
${nc}
EOF
            _sleep

            _pause volver
            bash -c "${ronin_firewall_menu2}"
            # press any key to return to menu
            ;;
        2)
            cat <<EOF
${red}
***
Obtén la dirección IP específica a la que deseas dar acceso a Whirlpool CLI...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
Tu direción IP en la red local debe parecerse a 192.168.4.21 o 12.34.56.78 dependiendo de tu configuración...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
Introduce la IP local a la que deseas dar acceso a Whirlpool CLI ahora...
***
${nc}
EOF

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address" to any port 8899 comment 'Whirlpool CLI access restricted to local LAN only'

            cat <<EOF
${red}
***
Recargando...
***
${nc}
EOF
            sudo ufw reload
            # reload the firewall

            cat <<EOF
${red}
***
Mostrando estado...
***
${nc}
EOF
            _sleep
            sudo ufw status
            # show firewall status

            cat <<EOF
${red}
***
Asegurate de ver tu nueva regla!
***
${nc}
EOF
            _sleep

            _pause volver
            bash -c "${ronin_firewall_menu2}"
            # press any key to return to menu
            ;;
        3)
            bash -c "${ronin_firewall_menu}"
            ;;
esac