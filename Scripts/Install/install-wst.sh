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

cd "$HOME" || exit

git clone "$WHIRLPOOL_STATS_REPO" Whirlpool-Stats-Tool 2>/dev/null
# download whirlpool stat tool

if ! hash pipenv; then
  cat <<PIP
${RED}
***
Installing python-pipenv...
***
${NC}
PIP
  _sleep
  sudo pacman -S --noconfirm python-pipenv &>/dev/null
fi
# check for python-pip and install if not found

cd Whirlpool-Stats-Tool || exit
pipenv install -r requirements.txt &>/dev/null
# change to whirlpool stats directory, otherwise exit
# install whirlpool stat tool

bash "$HOME"/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh
# return to menu