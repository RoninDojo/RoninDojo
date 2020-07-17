#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if ! sudo test -d "${DOCKER_VOLUME_BITCOIND}"/_data; then
    cat <<EOF
${RED}
***
IBD not found! Did you forget to install dojo?
***
${NC}
EOF
    _sleep 5 --msg "Returning to menu in"
    bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh
fi
# if data directory is not found then warn and return to menu

echo -e "${RED}"
echo "***"
echo "Preparing to copy data to your Backup Data Drive now..."
echo "***"
echo -e "${NC}"
_sleep 3

echo -e "${RED}"
echo "Have you mounted the Backup Data Drive?"
echo -e "${NC}"
while true; do
    read -rp "Y/N?: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh;exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
# ask to user proceed

echo -e "${RED}"
echo "This will take some time, are you sure that you want to do this?"
echo -e "${NC}"
while true; do
    read -rp "Y/N?: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh;exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
# ask to user proceed

echo -e "${RED}"
echo "***"
echo "Making sure Dojo is stopped..."
echo "***"
echo -e "${NC}"
_sleep 2

cd "${DOJO_PATH}" || exit
./dojo.sh stop
# stop dojo

echo -e "${RED}"
echo "***"
echo "Copying..."
echo "***"
echo -e "${NC}"
_sleep 2
sudo test -d "${SALVAGE_MOUNT}"/system-setup-salvage || sudo mkdir "${SALVAGE_MOUNT}"/system-setup-salvage
# test for system-setup-salvage directory, if not found mkdir is used to create

if sudo test -d "${SALVAGE_MOUNT}"/system-setup-salvage/blocks; then
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

    sudo rsync -vahW --no-compress --progress --delete-after "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate} "${SALVAGE_MOUNT}"/system-setup-salvage
else
  sudo cp -av "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate} "${SALVAGE_MOUNT}"/system-setup-salvage
  # use cp for initial fresh IBD copy
fi
# copies blockchain data to backup drive while keeping permissions so we can later restore properly

echo -e "${RED}"
echo "***"
echo "Complete!"
echo "***"
echo -e "${NC}"
_sleep 2

echo -e "${RED}"
echo "***"
echo "Press any letter to return..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s
bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh
# return to menu
