#!/bin/bash

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

cd "$HOME" || exit
git clone -b json-out https://code.samourai.io/ronindojo/boltzmann.git "$HOME"/.boltzmann
cd .boltzmann || exit

if ! hash pipenv; then
    sudo pacman -S --noconfirm python-pipenv &>/dev/null
fi

pipenv install -r requirements.txt &>/dev/null
pipenv install sympy numpy &>/dev/null

#location to run boltzmann for json-output is "$HOME"/.boltzmann/boltzmann/ludwig.py --rpc --txids=