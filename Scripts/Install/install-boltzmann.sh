#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

cat <<BOLTZMANN
${RED}
***
Pulling Boltzmann from Gitlab...
***
${NC}
BOLTZMANN
_sleep

cd "$HOME" || exit
git clone "$BOLTZMANN_REPO" &>/dev/null
cd boltzmann || exit
# pull Boltzmann

cat <<BOLTZMANN
${RED}
***
Checking package dependencies...
***
${NC}
BOLTZMANN

if ! hash pipenv; then
    cat <<BOLTZMANN
${RED}
***
Installing pipenv...
***
${NC}
BOLTZMANN
    sudo pacman -S --noconfirm python-pipenv &>/dev/null
fi

cat <<BOLTZMANN
${RED}
***
Installing Boltzmann...
***
${NC}
BOLTZMANN
_sleep 3

# Setup a virtual environment to hold boltzmann dependencies. We should use this
# with all future packages that ship a requirements.txt.
pipenv install -r requirements.txt &>/dev/null

echo -e "${RED}"
echo "***"
echo "Press any letter to return..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s
# will return to menu
bash -c "$RONIN_BOLTZMANN_MENU"