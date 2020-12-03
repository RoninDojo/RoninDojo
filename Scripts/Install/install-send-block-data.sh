#!/bin/bash
# shellcheck source=/dev/null

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
    _sleep 5 --msg "Returning to menu in"
    bash -c "${RONIN_DOJO_MENU2}"
fi
# if data directory is not found then warn and return to menu

echo -e "${RED}"
echo "***"
echo "Preparing to copy data to your Backup Data Drive now..."
echo "***"
echo -e "${NC}"
_sleep 3

if [ -b "${SECONDARY_STORAGE}" ]; then
  echo -e "${RED}"
  echo "***"
  echo "Your backup drive partition has been detected..."
  echo "***"
  echo -e "${NC}"
  _sleep 2
  # checks for ${SECONDARY_STORAGE}
else
  echo -e "${RED}"
  echo "***"
  echo "No backup drive partition detected! Please make sure it is plugged in and has power if needed."
  echo "***"
  echo -e "${NC}"
  _sleep 5

  echo -e "${RED}"
  echo "***"
  echo "Press any key to return..."
  echo "***"
  echo -e "${NC}"
  _pause
  bash -c "${RONIN_DOJO_MENU2}"
  # no drive detected, press any key to return to menu
fi

echo -e "${RED}"
echo "***"
echo "Making sure Dojo is stopped..."
echo "***"
echo -e "${NC}"
_sleep 2

cd "${dojo_path_my_dojo}" || exit
_stop_dojo
# stop dojo

echo -e "${RED}"
echo "***"
echo "Copying..."
echo "***"
echo -e "${NC}"
_sleep 2

sudo test -d "${BITCOIN_IBD_BACKUP_DIR}" || sudo mkdir "${BITCOIN_IBD_BACKUP_DIR}"
# test for system-setup-salvage directory, if not found mkdir is used to create

if sudo test -d "${BITCOIN_IBD_BACKUP_DIR}"/blocks; then
    # Use rsync when existing IBD is found
    if ! hash rsync 2>/dev/null; then
        cat <<EOF
${RED}
***
rsync package missing...
***
${NC}
EOF
        _sleep 5 --msg "Installing in"
        sudo pacman -S --noconfirm rsync &>/dev/null
    fi

    sudo rsync -vahW --no-compress --progress --delete-after "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate} "${BITCOIN_IBD_BACKUP_DIR}"
elif sudo test -d "${DOCKER_VOLUME_BITCOIND}"/_data/blocks; then
    sudo cp -av "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate} "${BITCOIN_IBD_BACKUP_DIR}"
    # use cp for initial fresh IBD copy
else
    sudo umount "${STORAGE_MOUNT}" && sudo rmdir "${STORAGE_MOUNT}"
    cat <<BACKUP
${RED}
***
No backup data available to send! Umounting drive now...
***
${NC}
BACKUP
    _sleep 5 "Returning to menu in"

    bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo2.sh
fi
# copies blockchain data to backup drive while keeping permissions so we can later restore properly

echo -e "${RED}"
echo "***"
echo "Transfer Complete!"
echo "***"
echo -e "${NC}"
_sleep 2

echo -e "${RED}"
echo "***"
echo "Press any key to continue..."
echo "***"
echo -e "${NC}"
_pause

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

echo -e "${RED}"
echo "***"
echo "You can now safely unplug your backup drive!"
echo "***"
echo -e "${NC}"
_sleep 2

echo -e "${RED}"
echo "***"
echo "Press any key to return..."
echo "***"
echo -e "${NC}"
_pause
bash -c "${RONIN_DOJO_MENU2}"
# return to menu