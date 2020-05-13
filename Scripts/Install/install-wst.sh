#!/bin/bash

. ~/RoninDojo/Scripts/defaults.sh
. ~/RoninDojo/Scripts/functions.sh

echo -e "${RED}"
echo "***"
echo "Installing Whirlpool Stat Tool..."
echo "***"
echo -e "${NC}"

mkdir ~/wst && cd ~/wst

git clone https://github.com/Samourai-Wallet/whirlpool_stats.git;

if find_pkg python-pip; then
  echo -e "${RED}"
  echo "***"
  echo "python-pip already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing python-pip..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm python-pip
fi
# check for / python-pip

cd whirlpool_stats
sudo pip3 install -r ./requirements.txt

bash ~/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh