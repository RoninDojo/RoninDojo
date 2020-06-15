#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if ! sudo test -d /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data; then
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

echo -e "${RED}"
echo "***"
echo "Making sure Dojo is stopped..."
echo "***"
echo -e "${NC}"
_sleep 2

cd "${DOJO_PATH}" || exit
./dojo.sh stop

echo -e "${RED}"
echo "***"
echo "Copying..."
echo "***"
echo -e "${NC}"
_sleep 2
sudo test -d /mnt/usb1/system-setup-salvage || sudo mkdir /mnt/usb1/system-setup-salvage

if sudo test -d /mnt/usb1/system-setup-salvage/blocks; then
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
        sudo pacman -S --noconfirm rsync
    fi

    sudo rsync -vahW --no-compress --progress --delete-after /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/{blocks,chainstate} /mnt/usb1/system-setup-salvage
else
    # Use cp for initial fresh IBD copy
    sudo cp -av /mnt/usb/docker/volumes/my-dojo_data-bitcoind/_data/{blocks,chainstate} /mnt/usb1/system-setup-salvage
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
