#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

cd "$HOME" || exit
git clone "$BOLTZMANN_REPO" &>/dev/null
cd boltzmann || exit
# pull Boltzmann

cat <<EOF
${RED}
***
Checking package dependencies...
***
${NC}
EOF
_sleep

if ! hash pipenv; then
    cat <<EOF
${RED}
***
Installing pipenv...
***
${NC}
EOF
    sudo pacman --quiet -S --noconfirm python-pipenv &>/dev/null
fi

# Setup a virtual environment to hold boltzmann dependencies. We should use this
# with all future packages that ship a requirements.txt.
pipenv install &>/dev/null

_pause continue

# will return to boltzmann menu option script
bash -c "$RONIN_BOLTZMANN_MENU"
