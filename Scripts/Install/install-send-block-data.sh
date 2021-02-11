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
Preparing to copy data to your Backup Data Drive now...
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
    _sleep 2

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
Copying...
***
${NC}
EOF

_sleep 2

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
${RED}
***
No backup data available to send! Umounting drive now...
***
${NC}
EOF
    _sleep 2

    _pause return
    bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo2.sh
    exit
fi
# copies blockchain data to backup drive while keeping permissions so we can later restore properly

cat <<EOF
${RED}
***
Transfer Complete!
***
${NC}
EOF

_sleep 2

_pause continue

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