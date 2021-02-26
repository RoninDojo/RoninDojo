#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

cd "$HOME" || exit
git clone -q "$boltzmann_repo" &>/dev/null
cd boltzmann || exit
# pull Boltzmann

_check_pkg "pipenv" "python-pipenv"

# Setup a virtual environment to hold boltzmann dependencies. We should use this
# with all future packages that ship a requirements.txt.
pipenv install &>/dev/null

_pause continue

# will return to boltzmann menu option script
bash -c "$ronin_boltzmann_menu"
