#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

echo -e "${RED}"
echo "***"
echo "Installing Whirlpool Stat Tool..."
echo "***"
echo -e "${NC}"

mkdir ~/wst
cd ~/wst || exit
# make wst directory and change to it, otherwise exit

git clone https://github.com/Samourai-Wallet/whirlpool_stats.git;
# download whirlpool stat tool

if find_pkg python-pip; then
  echo -e "${RED}"
  echo "***"
  echo "python-pip already installed..."
  echo "***"
  echo -e "${NC}"
  _sleep
else
  echo -e "${RED}"
  echo "***"
  echo "Installing python-pip..."
  echo "***"
  echo -e "${NC}"
  _sleep
  sudo pacman -S --noconfirm python-pip
fi
# check for python-pip and install if not found

cd whirlpool_stats || exit
sudo pip3 install -r ./requirements.txt
# change to whirlpool stats directory, otherwise exit
# install whirlpool stat tool

bash ~/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh
# return to menu
