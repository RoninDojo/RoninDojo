#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if [ ! -d "$HOME"/Whirlpool-Stats-Tool ]; then
    cat <<EOF
${red}
***
Installing Whirlpool Stat Tool...
***
${nc}
EOF
    _sleep

    bash "$HOME"/RoninDojo/Scripts/Install/install-wst.sh
else
    _sleep
    cd "$HOME"/Whirlpool-Stats-Tool/whirlpool_stats || exit
fi
# if "$HOME"/whirlpool_stats is not found then run install script
# else inform user and launch

cat <<EOF
${red}
Whirlpool Stat Tool INSTRUCTIONS:
${nc}
EOF

_sleep
# instructions are given to user

cat <<EOF
${red}
Download in the working directory a snaphot for the 0.01BTC pools:
${nc}
download 001
EOF

_sleep

cat <<EOF
${red}
Load and compute the statistcs for the snaphot:
${nc}
load 001
EOF

_sleep

cat <<EOF
${red}
Display the metrics computed for a transaction stored in the active snapshot:
${nc}
score <ENTER TXID OF DESIRED 0.01 BTC transaction>
EOF

_sleep

cat <<EOF
${red}
Sample output...
${nc}
Backward-looking metrics for the outputs of this mix:
    anonset = 92
    spread = 89%

Forward-looking metrics for the outputs of Tx0s having this transaction as their first mix:
    anonset = 127
    spread = 76%
EOF

_sleep

cat <<EOF
${red}
***
Type: 'quit' at anytime to exit the Whirlpool Statitics Tool.
***
EOF

_pause continue
# press any key to continue

if ! pipenv run python wst.py -w=/tmp 2>/dev/null; then
    _check_pkg "pipenv" "python-pipenv"

    cat <<EOF
${red}
***
Checking for updates...
***
${nc}
EOF
    _sleep

    cd .. || exit

    # Upgrade dependencies
    pipenv update &>/dev/null

    cd - &>/dev/null || exit
    pipenv run python wst.py -w=/tmp
fi
# run wst.py

_pause return
bash -c "${ronin_samourai_toolkit_menu}"