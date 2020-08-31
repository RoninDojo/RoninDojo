#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

cat <<WST
${RED}
***
Installing Whirlpool Stat Tool...
***
${NC}
WST

test -d "$HOME"/wst || mkdir "$HOME"/wst

cd "$HOME"/wst || exit
# make wst directory and change to it, otherwise exit

git clone https://github.com/Samourai-Wallet/whirlpool_stats.git 2>/dev/null
# download whirlpool stat tool

if ! hash pip; then
  cat <<PIP
${RED}
***
Installing python-pip...
***
${NC}
PIP
  _sleep
  sudo pacman -S --noconfirm python-pip
fi
# check for python-pip and install if not found

cd whirlpool_stats || exit
sudo pip3 install -r ./requirements.txt
# change to whirlpool stats directory, otherwise exit
# install whirlpool stat tool

bash "$HOME"/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh
# return to menu