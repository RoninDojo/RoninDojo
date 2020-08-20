#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

cat <<WST
${RED}
***
Checking for Whirlpool Stat Tool...
***
${NC}
WST

_sleep 2

if [ ! -f "$HOME"/wst/whirlpool_stats/whirlpool_stats/wst.py ]; then
    bash "$HOME"/RoninDojo/Scripts/Install/install-wst.sh
else
    cat <<WST
${RED}
***
Whirlpool Stat Tool Already Installed!
***
${NC}
WST
    _sleep 2

    cat <<WST
${RED}
***
Launching Whirlpool Stat Tool...
***
${NC}
WST
    _sleep 2
    cd "$HOME"/wst/whirlpool_stats/whirlpool_stats || exit
fi
# if wst.py is not found then run install script
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
Type: 'quit' at anytime to exit WST.
***

***
Press any letter to continue...
***
${NC}
WST

read -n 1 -r -s
# press any letter to return

python3 wst.py -w=/tmp
# run wst.py using python3