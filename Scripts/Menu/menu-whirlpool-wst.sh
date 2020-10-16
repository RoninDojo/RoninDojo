#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if [ ! -d "$HOME"/Whirlpool-Stats-Tool ]; then
    bash "$HOME"/RoninDojo/Scripts/Install/install-wst.sh
else
    _sleep 2
    cd "$HOME"/Whirlpool-Stats-Tool/whirlpool_stats || exit
fi
# if "$HOME"/whirlpool_stats is not found then run install script
# else inform user and launch

cat <<WST
${RED}
Whirlpool Stat Tool INSTRUCTIONS:
${NC}
WST

_sleep 2
# instructions are given to user

cat <<WST
${RED}
Download in the working directory a snaphot for the 0.01BTC pools:
${NC}
download 001
WST

_sleep 2

cat <<WST
${RED}
Load and compute the statistcs for the snaphot:
${NC}
load 001
WST

_sleep 2

cat <<WST
${RED}
Display the metrics computed for a transaction stored in the active snapshot:
${NC}
score <ENTER TXID OF DESIRED 0.01 BTC transaction>
WST

_sleep 2

cat <<WST
${RED}
Sample output...
${NC}
Backward-looking metrics for the outputs of this mix:
    anonset = 92
    spread = 89%

Forward-looking metrics for the outputs of Tx0s having this transaction as their first mix:
    anonset = 127
    spread = 76%
WST

_sleep 2

cat <<WST
${RED}
***
Type: 'quit' at anytime to exit the Whirlpool Statitics Tool.
***

***
Press any letter to continue...
***
${NC}
WST

read -n 1 -r -s
# press any letter to return

pipenv run python wst.py -w=/tmp
# run wst.py using python3

_sleep 3 --msg "Returning to menu in"
bash "$HOME"/RoninDojo/Scripts/Menu/menu-extras.sh