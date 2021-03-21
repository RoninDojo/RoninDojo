#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Activar"
         2 "Desactivar"
         3 "Estado"
         4 "Eliminar regla"
         5 "Recargar"
         6 "Añadir rango IP para SSH"
         7 "Añadir IP específica para SSH"
         8 "Siguiente página"
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
            cat <<EOF
${red}
***
Activando cortafuegos...
***
${nc}
EOF
            _sleep
            sudo ufw enable
            _pause volver
            bash -c "${ronin_firewall_menu}"
            # enable firewall, press any key to return to menu
            ;;
        2)
            cat <<EOF
${red}
***
Desactivando cortafuegos...
***
${nc}
EOF
            _sleep
            sudo ufw disable
            _pause volver
            bash -c "${ronin_firewall_menu}"
            # disable firewall, press any key to return to menu
            ;;
        3)
            cat <<EOF
${red}
***
Mostrando el estado...
***
${nc}
EOF
            _sleep
            sudo ufw status
            _pause volver
            bash -c "${ronin_firewall_menu}"
            # show ufw status, press any key to return to menu
            ;;
        4)
            cat <<EOF
${red}
***
Encuentra la regla que quieras eliminar y pulsa su número para eliminarla...
***
${nc}
EOF
            _sleep
            sudo ufw status
            # show firewall status

            cat <<EOF
${red}
***
Ten cuidado al eliminar las reglas antiguas del cortafuegos!No te dejes a ti mismo sin acceso por SSH...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
Ejemplo: Si quieres eliminar la 3a regla listada, apreta el número 3 y pulsa Enter...
***
${nc}
EOF
            _sleep

            read -rp "Please type the rule number to delete now: " ufw_rule_number
            sudo ufw delete "$ufw_rule_number"
            # request user input to delete a ufw rule

            cat <<EOF
${red}
***
Recargando...
***
${nc}
EOF
            sudo ufw reload
            # reload firewall

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

            _pause volver
            bash -c "${ronin_firewall_menu}"
            # press any key to return to menu
            ;;
        5)
            cat <<EOF
${red}
***
Recargando...
***
${nc}
EOF
            sudo ufw reload
            _pause volver
            bash -c "${ronin_firewall_menu}"
            # reload firewall, press any key to return to menu
            ;;
        6)
            cat <<EOF
${red}
***
Obtén la IP de cualquier máquina conectada en la misma red local que tu RoninDojo...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
La dirección IP introducida debe ser adaptada en su final con el rango .0/24 ...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
Esto permitirá a cualquier máquina conectada a la misma red local conectarse via SSH...
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
Introduce la IP local a la que deseas dar acceso por SSh ahora...
***
${nc}
EOF

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address"/24 to any port 22 comment 'SSH access restricted to local network'

            cat <<EOF
${red}
***
Recargando...
***
${nc}
EOF
            sudo ufw reload
            # reload firewall

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
            bash -c "${ronin_firewall_menu}"
            # press any key to return to menu
            ;;
        7)
            cat <<EOF
${red}
***
Obtén la dirección IP específica a la que deseas dar acceso por SSH...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
El acceso por SSh será restringido solo para esta dirección IP...
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
Introduce la IP local a la que deseas dar acceso por SSh ahora...
***
${nc}
EOF

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address" to any port 22 comment 'SSH access restricted to specific IP'

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
            bash -c "${ronin_firewall_menu}"
            # press any key to return to menu
            ;;
        8)
            bash -c "${ronin_firewall_menu2}"
            # go to next menu page
            ;;
        9)
            bash -c "${ronin_system_menu2}"
            # return system menu page 2
            ;;
esac