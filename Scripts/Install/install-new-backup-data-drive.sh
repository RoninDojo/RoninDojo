#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -b "${secondary_storage}" ]; then
    # Make sure /mnt/usb UUID is not same as $secondary_storage
    if [[ $(lsblk -no UUID "$(findmnt -n -o SOURCE --target "${install_dir}")") != $(lsblk -no UUID "${secondary_storage}") ]]; then
        cat <<EOF
${red}
***
Tu nueva unidad para la copia de serguridad ha sido dectectada...
***
${nc}
EOF
        _sleep
        # checks for ${secondary_storage}
    else
        cat <<EOF
${red}
***
Se produjo una posible reorganización de la unidad, ${primary_storage} está disponible para formatear...
***
${nc}
EOF
        # Make sure device does not contain an existing filesystem
        if [ -b "${primary_storage}" ] && [ -n "$(lsblk -no FSTYPE "${primary_storage}")" ]; then
            # Drive got rearranged
            secondary_storage="${primary_storage}"
        elif [ -b "${primary_storage}" ] && [ -z "$(lsblk -no FSTYPE "${primary_storage}")" ]; then
            if ! "${backup_format}"; then
                cat <<EOF
${red}
***
${primary_storage} contiene un sistema de archivos existente y no se puede formatear. Si desea utilizar esta unidad
para fines de respaldo. colocar backup_format=true en ${HOME}/.config/RoninDojo/user.conf
***
${nc}
EOF
                _pause volver

                # press any key to return to menu-system-storage.sh
                bash -c "${ronin_system_storage}"
            else
                # Available to format
                secondary_storage="${primary_storage}"
            fi
        fi
    fi
else
    cat <<EOF
${red}
***
Ninguna unidad con copia de seguridad ha sido detectada! Asegúrate de que el disco duro esté conectado y que no le falte electricidad si así fuera necesario...
***
${nc}
EOF
    _sleep 5

    _pause volver
    bash -c "${ronin_system_storage}"
    # no drive detected, press any key to return to menu
fi

cat <<EOF
${red}
***
Preparando para formatear y montar ${secondary_storage} a ${storage_mount}...
***
${nc}
EOF
_sleep

cat <<EOF
${red}
***
CUIDADO: Cualquier dato preexistente en esta unidad para la copia seguridad será borrado!
***
${nc}
EOF
_sleep

cat <<EOF
${red}
***
Estás seguro?
***
${nc}
EOF

while true; do
    read -rp "[${green}Yes${nc}/${red}No${nc}]: " answer
    case $answer in
        [yY][eE][sS]|[yY]) break;;
        [nN][oO]|[Nn])
          bash -c "${ronin_system_storage}"
          exit
          ;;
        * )
          cat <<EOF
${red}
***
Respuesta inválida! Pulsa Y o N
***
${nc}
EOF
          ;;
    esac
done
# ask user to proceed

cat <<EOF
${red}
***
Formateando el disco para la copia de seguridad...
***
${nc}
EOF
_sleep

# Check for sgdisk dependency
_check_pkg "sgdisk" "gptfdisk" --update-mirrors

if ! create_fs --label "backup" --device "${secondary_storage}" --mountpoint "${storage_mount}"; then
    printf "\n %sFalló la creación del sistema de archivos! Saliendo ahora...%s" "${red}" "${nc}"
    _sleep 3
    exit 1
fi
# format partition, see create_fs in functions.sh

cat <<EOF
${red}
***
Mostrando el nombre en el disco externo...
***
${nc}
EOF

lsblk -o NAME,SIZE,LABEL "${secondary_storage}"
_sleep
# double-check that "${secondary_storage}" exists, and that its storage capacity is what you expected

cat <<EOF
${red}
***
Mira la respuesta de ${secondary_storage} y asegúrate de que todo parezca correcto...
***
${nc}
EOF

df -h "${secondary_storage}"
_sleep
# checks disk info

_pause volver
bash -c "${ronin_system_storage}"
# press any key to return to menu-system-storage.sh