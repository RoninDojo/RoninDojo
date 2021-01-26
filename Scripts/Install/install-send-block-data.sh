#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if ! sudo test -d "${DOCKER_VOLUME_BITCOIND}"/_data; then
    cat <<EOF
${RED}
***
Blockchain data not found! Did you forget to install RoninDojo?
***
${NC}
EOF
    _sleep 2

    _pause return
    bash -c "${RONIN_DOJO_MENU2}"
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

if [ -b "${SECONDARY_STORAGE}" ]; then
      cat <<EOF
${RED}
***
Your backup drive partition has been detected...
***
${NC}
EOF
  _sleep 2
  # checks for ${SECONDARY_STORAGE}
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
  bash -c "${RONIN_DOJO_MENU2}"
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

sudo test -d "${BITCOIN_IBD_BACKUP_DIR}" || sudo mkdir "${BITCOIN_IBD_BACKUP_DIR}"
# test for system-setup-salvage directory, if not found mkdir is used to create

if sudo test -d "${BITCOIN_IBD_BACKUP_DIR}"/blocks; then
    # Use rsync when existing IBD is found
    if ! hash rsync 2>/dev/null; then
        # Update mirrors
        _pacman_update_mirrors

        cat <<EOF
${RED}
***
Rsync package missing...
***
${NC}
EOF
        _sleep 5 --msg "Installing in"
        sudo pacman --quiet -S --noconfirm rsync &>/dev/null
    fi

    sudo rsync -vahW --no-compress --progress --delete-after "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate} "${BITCOIN_IBD_BACKUP_DIR}"
elif sudo test -d "${DOCKER_VOLUME_BITCOIND}"/_data/blocks; then
    sudo cp -av "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate} "${BITCOIN_IBD_BACKUP_DIR}"
    # use cp for initial fresh IBD copy
else
    sudo umount "${STORAGE_MOUNT}" && sudo rmdir "${STORAGE_MOUNT}"
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

sudo umount "${STORAGE_MOUNT}" && sudo rmdir "${STORAGE_MOUNT}"
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
bash -c "${RONIN_DOJO_MENU2}"
# return to menu