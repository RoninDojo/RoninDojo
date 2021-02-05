#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if [ ! -d "$HOME"/Whirlpool-Stats-Tool ]; then
    cat <<EOF
${RED}
***
Installing Whirlpool Stat Tool...
***
${NC}
EOF
    _sleep

    bash "$HOME"/RoninDojo/Scripts/Install/install-wst.sh
else
    _sleep 2
    cd "$HOME"/Whirlpool-Stats-Tool/whirlpool_stats || exit
fi
# if "$HOME"/whirlpool_stats is not found then run install script
# else inform user and launch

cat <<EOF
${RED}
Whirlpool Stat Tool INSTRUCTIONS:
${NC}
EOF

_sleep 2
# instructions are given to user

cat <<EOF
${RED}
Download in the working directory a snaphot for the 0.01BTC pools:
${NC}
download 001
EOF

_sleep 2

cat <<EOF
${RED}
Load and compute the statistcs for the snaphot:
${NC}
load 001
EOF

_sleep 2

cat <<EOF
${RED}
Display the metrics computed for a transaction stored in the active snapshot:
${NC}
score <ENTER TXID OF DESIRED 0.01 BTC transaction>
EOF

_sleep 2

cat <<EOF
${RED}
Sample output...
${NC}
Backward-looking metrics for the outputs of this mix:
    anonset = 92
    spread = 89%

Forward-looking metrics for the outputs of Tx0s having this transaction as their first mix:
    anonset = 127
    spread = 76%
EOF

_sleep 2

cat <<EOF
${RED}
***
Type: 'quit' at anytime to exit the Whirlpool Statitics Tool.
***
EOF

_pause continue
# press any key to continue

if ! pipenv run python wst.py -w=/tmp &>/dev/null; then
    _check_pkg "pipenv" "python-pipenv"

    cat <<EOF
${RED}
***
Checking for updates...
***
${NC}
EOF
    _sleep

    cd .. || exit

    # Upgrade dependencies
    pipenv update &>/dev/null
fi
# run wst.py

_pause return
bash -c "${ronin_samourai_toolkit_menu}"