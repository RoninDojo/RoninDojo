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

git clone https://github.com/Samourai-Wallet/whirlpool_stats.git;

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
# check for / python-pip

cd whirlpool_stats || exit
sudo pip3 install -r ./requirements.txt

bash ~/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh