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
La unidad de tú nueva copia de serguridad ha sido dectectada...
***
${nc}
EOF
        _sleep
        # checks for ${secondary_storage}
    else
        cat <<EOF
${red}
***
Possible drive rearrangement occured. Checking if ${primary_storage} is available to mount...
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
    _sleep

    _pause volver
    bash -c "${ronin_dojo_menu2}"
    # no drive detected, press any key to return to menu
fi

if ! findmnt "${storage_mount}" 1>/dev/null; then
    cat <<EOF
${red}
***
Preparing to Mount ${secondary_storage} to ${storage_mount}...
***
${nc}
EOF
    _sleep 3

    cat <<EOF
${red}
***
Are you ready to mount?
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
Invalid answer! Enter Y or N
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
Mounting ${secondary_storage} to ${storage_mount}...
***
${nc}
EOF
    _sleep

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
Copiando...
***
${nc}
EOF

_sleep

sudo test -d "${bitcoin_ibd_backup_dir}" || sudo mkdir -p "${bitcoin_ibd_backup_dir}"
# test for system-setup-salvage directory, if not found mkdir is used to create

if sudo test -d "${bitcoin_ibd_backup_dir}"/blocks; then
    # Use rsync when existing IBD is found

    _check_pkg rsync --update-mirrors

    sudo rsync -vahW --no-compress --progress --delete-after "${docker_volume_bitcoind}"/_data/{blocks,chainstate,indexes} "${bitcoin_ibd_backup_dir}"
elif sudo test -d "${docker_volume_bitcoind}"/_data/blocks; then
    sudo cp -av "${docker_volume_bitcoind}"/_data/{blocks,chainstate,indexes} "${bitcoin_ibd_backup_dir}"
    # use cp for initial fresh IBD copy
else
    sudo umount "${storage_mount}" && sudo rmdir "${storage_mount}"

    cat <<EOF
${red}
***
No hay datos disponibles en la copia de seguridad! Desmontando la unidad ahora...
***
${nc}
EOF
    _sleep

    _pause volver
    bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo2.sh
    exit
fi
# copies blockchain data to backup drive while keeping permissions so we can later restore properly

cat <<EOF
${red}
***
Transferencia completa!
***
${nc}
EOF

_sleep

_pause continue

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
Comenzando Dojo...
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