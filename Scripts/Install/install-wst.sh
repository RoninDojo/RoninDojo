#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

cat <<EOF
${red}
***
Comprobando las dependencias de los paquetes...
***
${nc}
EOF
_sleep

cd "$HOME" || exit

git clone -q "${whirlpool_stats_repo}" Whirlpool-Stats-Tool 2>/dev/null
# download whirlpool stat tool

# check for python-pip and install if not found
_check_pkg "pipenv" "python-pipenv" --update-mirrors

cd Whirlpool-Stats-Tool || exit
pipenv install &>/dev/null
# change to whirlpool stats directory, otherwise exit
# install whirlpool stat tool

bash "$HOME"/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh
# return to menu