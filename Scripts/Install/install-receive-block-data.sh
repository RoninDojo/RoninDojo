#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if ! sudo test -d "${docker_volume_bitcoind}"/_data; then
    cat <<EOF
${red}
***
Blockchain data not found! Did you forget to install RoninDojo?
***
${nc}
EOF
    _sleep 2

    _pause return
    bash -c "${ronin_dojo_menu2}"
fi
# if data directory is not found then warn and return to menu

cat <<EOF
${red}
***
Preparing to copy data from your Backup Data Drive now...
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
Your new backup drive has been detected...
***
${nc}
EOF
        _sleep 2
        # checks for ${secondary_storage}
    else
        cat <<EOF
${red}
***
Possible drive rearrangement occured. Checking if ${primary_storage} is available to format...
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
${primary_storage} contains an existing filesystem and cannot be formatted. If you wish to use this drive
for backup purposes. Set backup_format=true in ${HOME}/.config/RoninDojo/user.conf
***
${nc}
EOF
                _pause return

                # press any key to return to menu-system-storage.sh
                bash -c "${ronin_system_storage}"
            else
                secondary_storage="${primary_storage}"
            fi
        fi
    fi
else
    cat <<EOF
${red}
***
No backup drive partition detected! Please make sure it is plugged in and has power if needed...
***
${nc}
EOF
    _sleep 5

    _pause return

    bash -c "${ronin_dojo_menu2}"
    # no drive detected, press any key to return to menu
fi

cat <<EOF
${red}
***
Making sure Dojo is stopped...
***
${nc}
EOF

_sleep 2

cd "${dojo_path_my_dojo}" || exit
_dojo_check && _stop_dojo
# stop dojo

cat <<EOF
${red}
***
Removing old data...
***
${nc}
EOF

_sleep 2

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
Copying...
***
${nc}
EOF

_sleep 2

if sudo test -d "${bitcoin_ibd_backup_dir}"/blocks; then
    # copy blockchain data from back up drive to dojo bitcoind data directory, will take a little bit
    sudo cp -av "${bitcoin_ibd_backup_dir}"/{blocks,chainstate,indexes} "${docker_volume_bitcoind}"/_data/
else
    sudo umount "${storage_mount}" && sudo rmdir "${storage_mount}"
    cat <<BACKUP
${red}
***
No backup data available to receive data! Umounting drive now...
***
${nc}
BACKUP
    _sleep 2

    _pause return
    bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo2.sh
fi

cat <<EOF
${red}
***
Transfer Complete!
***
${nc}
EOF

_sleep 2

_pause continue
# press to continue is needed because sudo password can be requested for next step, if user is AFK there may be timeout

cat <<EOF
${red}
***
Unmounting...
***
${nc}
EOF
_sleep 2

sudo umount "${storage_mount}" && sudo rmdir "${storage_mount}"
# unmount backup drive and remove directory

cat <<EOF
${red}
***
You can now safely unplug your backup drive!
***
${nc}
EOF
_sleep 2

cat <<EOF
${red}
***
Starting Dojo...
***
${nc}
EOF

_sleep 2

cd "${dojo_path_my_dojo}" || exit
_source_dojo_conf

# Start docker containers
yamlFiles=$(_select_yaml_files)
docker-compose $yamlFiles up --remove-orphans -d || exit # failed to start dojo

_pause return
bash -c "${ronin_dojo_menu2}"
# return to menu