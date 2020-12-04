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
echo "Preparing to copy data from your Backup Data Drive now..."
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
echo "Removing old Data..."
echo "***"
echo -e "${NC}"
_sleep 2

# Make sure we have directories to delete
if test -d "${DOCKER_VOLUME_BITCOIND}"/_data/blocks; then
    sudo rm -rf "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate}
fi

# Check to see if we have old legacy backup directory, if so rename to ${STORAGE_MOUNT}
if sudo test -d "${STORAGE_MOUNT}"/system-setup-salvage; then
    sudo mv "${STORAGE_MOUNT}"/system-setup-salvage "${BITCOIN_IBD_BACKUP_DIR}" 1>/dev/null
fi

echo -e "${RED}"
echo "***"
echo "Copying..."
echo "***"
echo -e "${NC}"
_sleep 2

if sudo test -d "${BITCOIN_IBD_BACKUP_DIR}"/blocks; then
    sudo cp -av "${BITCOIN_IBD_BACKUP_DIR}"/{blocks,chainstate} "${DOCKER_VOLUME_BITCOIND}"/_data/
    # copy blockchain data from back up drive to dojo bitcoind data directory, will take a little bit
else
    sudo umount "${STORAGE_MOUNT}" && sudo rmdir "${STORAGE_MOUNT}"
    cat <<BACKUP
${RED}
***
No backup data available to receive! Umounting drive now...
***
${NC}
BACKUP
    _sleep 5 --msg "Returning to menu in"

    bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo2.sh
fi

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
# press to continue is needed because sudo password can be requested for next step, if user is AFK there may be timeout

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