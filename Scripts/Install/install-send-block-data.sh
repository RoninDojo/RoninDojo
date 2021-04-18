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
    _sleep 1

    _pause return
    bash -c "${ronin_dojo_menu2}"
fi
# if data directory is not found then warn and return to menu

cat <<EOF
${red}
***
Preparing to copy data to your Backup Data Drive now...
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
        _sleep 1
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
    _sleep 1

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

_sleep 1

cd "${dojo_path_my_dojo}" || exit
_dojo_check && _stop_dojo
# stop dojo

cat <<EOF
${red}
***
Copying...
***
${nc}
EOF

_sleep 1

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
No backup data available to send! Umounting drive now...
***
${nc}
EOF
    _sleep 1

    _pause return
    bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo2.sh
    exit
fi
# copies blockchain data to backup drive while keeping permissions so we can later restore properly

cat <<EOF
${red}
***
Transfer Complete!
***
${nc}
EOF

_sleep 1

_pause continue

cat <<EOF
${red}
***
Unmounting...
***
${nc}
EOF

_sleep 1

sudo umount "${storage_mount}" && sudo rmdir "${storage_mount}"
# unmount backup drive and remove directory

cat <<EOF
${red}
***
You can now safely unplug your backup drive!
***
${nc}
EOF

_sleep 1

cat <<EOF
${red}
***
Starting Dojo...
***
${nc}
EOF

_sleep 1

cd "${dojo_path_my_dojo}" || exit
_source_dojo_conf

# Start docker containers
yamlFiles=$(_select_yaml_files)
docker-compose $yamlFiles up --remove-orphans -d || exit # failed to start dojo

_pause return

bash -c "${ronin_dojo_menu2}"
# return to menu