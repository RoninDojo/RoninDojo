#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if ! sudo test -d "${docker_volume_bitcoind}"/_data; then
    cat <<EOF
${RED}
***
Blockchain data not found! Did you forget to install RoninDojo?
***
${NC}
EOF
    _sleep 2

    _pause return
    bash -c "${ronin_dojo_menu2}"
fi
# if data directory is not found then warn and return to menu

cat <<EOF
${RED}
***
Preparing to copy data from your Backup Data Drive now...
***
${NC}
EOF
_sleep 3

if [ -b "${secondary_storage}" ]; then
    cat <<EOF
${RED}
***
Your backup drive partition has been detected...
***
${NC}
EOF
    _sleep 2
    # checks for ${secondary_storage}
else
    cat <<EOF
${RED}
***
No backup drive partition detected! Please make sure it is plugged in and has power if needed...
***
${NC}
EOF
    _sleep 5

    _pause return

    bash -c "${ronin_dojo_menu2}"
    # no drive detected, press any key to return to menu
fi

cat <<EOF
${RED}
***
Making sure Dojo is stopped...
***
${NC}
EOF

_sleep 2

cd "${dojo_path_my_dojo}" || exit
_stop_dojo
# stop dojo

cat <<EOF
${RED}
***
Removing old data...
***
${NC}
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

cat <<EOF
${RED}
***
Copying...
***
${NC}
EOF

_sleep 2

if sudo test -d "${bitcoin_ibd_backup_dir}"/blocks; then
    for dir in blocks chainstate indexes; do
        sudo cp -a "${bitcoin_ibd_backup_dir}"/"${dir}" "${docker_volume_bitcoind}"/_data/
        # copy blockchain data from back up drive to dojo bitcoind data directory, will take a little bit
    done
else
    sudo umount "${storage_mount}" && sudo rmdir "${storage_mount}"
    cat <<BACKUP
${RED}
***
No backup data available to receive data! Umounting drive now...
***
${NC}
BACKUP
    _sleep 2

    _pause return
    bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo2.sh
fi

cat <<EOF
${RED}
***
Transfer Complete!
***
${NC}
EOF

_sleep 2

_pause continue
# press to continue is needed because sudo password can be requested for next step, if user is AFK there may be timeout

cat <<EOF
${RED}
***
Unmounting...
***
${NC}
EOF
_sleep 2

sudo umount "${storage_mount}" && sudo rmdir "${storage_mount}"
# unmount backup drive and remove directory

cat <<EOF
${RED}
***
You can now safely unplug your backup drive!
***
${NC}
EOF
_sleep 2

cat <<EOF
${RED}
***
Starting Dojo...
***
${NC}
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