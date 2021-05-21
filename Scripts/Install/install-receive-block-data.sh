#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if ! sudo test -d "${docker_volume_bitcoind}"/_data; then
    cat <<EOF
${red}
***
No se han encontrado datos de la Blockchain! Te has olvidado de instalar RoninDojo?
***
${nc}
EOF
    _sleep

    _pause volver
    bash -c "${ronin_dojo_menu2}"
fi
# if data directory is not found then warn and return to menu

cat <<EOF
${red}
***
Preparando para copiar los datos de la copia de seguridad de tú unidad ahora...
***
${nc}
EOF
_sleep 3

if [ -b "${secondary_storage}" ]; then
    # Make sure /mnt/usb UUID is not same as $secondary_storage
    if [[ $(lsblk -no UUID "$(findmnt -n -o SOURCE --target "${install_dir}")") != $(lsblk -no UUID "${secondary_storage}") ]]; then
        cat <<EOF
${red}
***
La partición de tu copia de seguridad ha sido detectada...
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
        secondary_storage="${primary_storage}"
    fi
else
    cat <<EOF
${red}
***
Ninguna partición con copia de seguridad ha sido detectada! Asegúrate de que el disco duro esté conectado y que no le falte electricidad si así fuera necesario...
***
${nc}
EOF
    _sleep 5

    _pause volver

    bash -c "${ronin_dojo_menu2}"
    # no drive detected, press any key to return to menu
fi

if ! findmnt "${storage_mount}" 1>/dev/null; then
    cat <<EOF
${red}
***
Preparando para montar ${secondary_storage} a ${storage_mount}...
***
${nc}
EOF
    _sleep 3

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
            bash "$HOME"/RoninDojo/Scripts/Menu/system-menu2.sh
            exit
            ;;
            *)
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

    test ! -d "${storage_mount}" && sudo mkdir "${storage_mount}"
    # create mount directory if not available

    cat <<EOF
${red}
***
Montando ${secondary_storage} ah ${storage_mount}...
***
${nc}
EOF
    _sleep 1

    sudo mount "${secondary_storage}" "${storage_mount}"
    # mount backup drive to ${storage_mount} directory
fi

cat <<EOF
${red}
***
Asegurando que Dojo esté parado...
***
${nc}
EOF

_sleep

cd "${dojo_path_my_dojo}" || exit
_dojo_check && _stop_dojo
# stop dojo

cat <<EOF
${red}
***
Borrando datos viejos...
***
${nc}
EOF

_sleep

# Make sure we have directories to delete
for dir in blocks chainstate indexes; do
    if sudo test -d "${docker_volume_bitcoind}"/_data/"${dir}"; then
        sudo rm -rf "${docker_volume_bitcoind}"/_data/"${dir}"
    fi
done

# Check to see if we have old legacy backup directory, if so rename to ${storage_mount}
if sudo test -d "${storage_mount}"/system-setup-salvage; then
    sudo mv "${storage_mount}"/system-setup-salvage "${bitcoin_ibd_backup_dir}" 1>/dev/null
fi

# Migrate from old $bitcoin_ibd_backup_dir path to new
if sudo test -d "${storage_mount}"/bitcoin; then
    sudo test -d "${bitcoin_ibd_backup_dir}" || sudo mkdir -p "${bitcoin_ibd_backup_dir}"
    sudo mv "${storage_mount}"/bitcoin/* "${bitcoin_ibd_backup_dir}"/
    sudo rm -rf "${storage_mount}"/bitcoin
fi

cat <<EOF
${red}
***
Copiando...
***
${nc}
EOF

_sleep

if sudo test -d "${bitcoin_ibd_backup_dir}"/blocks; then
    # copy blockchain data from back up drive to dojo bitcoind data directory, will take a little bit
    sudo cp -av "${bitcoin_ibd_backup_dir}"/{blocks,chainstate,indexes} "${docker_volume_bitcoind}"/_data/
else
    sudo umount "${storage_mount}" && sudo rmdir "${storage_mount}"
    cat <<BACKUP
${red}
***
No hay datos disponibles en la copia de seguridad! Desmontando la unidad ahora..
***
${nc}
BACKUP
    _sleep

    _pause volver
    bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo2.sh
    exit
fi

cat <<EOF
${red}
***
Transferencia completa!
***
${nc}
EOF

_sleep

_pause seguir
# press to continue is needed because sudo password can be requested for next step, if user is AFK there may be timeout

cat <<EOF
${red}
***
Desmontando...
***
${nc}
EOF
_sleep

sudo umount "${storage_mount}" && sudo rmdir "${storage_mount}"
# unmount backup drive and remove directory

cat <<EOF
${red}
***
Ahora ya puedes desconectar el disco duro sin peligro!
***
${nc}
EOF
_sleep

cat <<EOF
${red}
***
Iniciando Dojo...
***
${nc}
EOF

_sleep

cd "${dojo_path_my_dojo}" || exit
_source_dojo_conf

# Start docker containers
yamlFiles=$(_select_yaml_files)
docker-compose $yamlFiles up --remove-orphans -d || exit # failed to start dojo

_pause volver
bash -c "${ronin_dojo_menu2}"
# return to menu