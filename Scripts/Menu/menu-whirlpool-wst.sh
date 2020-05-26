#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

echo -e "${RED}"
echo "***"
echo "Checking for Whirlpool Stat Tool..."
echo "***"
echo -e "${NC}"
_sleep 2

if [ ! -f ~/wst/whirlpool_stats/whirlpool_stats/wst.py ]; then
    bash ~/RoninDojo/Scripts/Install/install-wst.sh
else
    echo -e "${RED}"
    echo "***"
    echo "Whirlpool Stat Tool Already Installed!";
    echo "***"
    echo -e "${NC}"
    sleep 2s

    echo -e "${RED}"
    echo "***"
    echo "Launching Whirlpool Stat Tool..."
    echo "***"
    echo -e "${NC}"
    sleep 2s
    cd "$HOME"/wst/whirlpool_stats/whirlpool_stats || exit
fi

echo -e "${RED}"
echo "Whirlpool Stat Tool INSTRUCTIONS:"
echo -e "${NC}"
_sleep 2

echo -e "${RED}"
echo "Download in the working directory a snaphot for the 0.01BTC pools:"
echo -e "${NC}"
echo "download 001"
_sleep 2

echo -e "${RED}"
echo "Load and compute the statistcs for the snaphot:"
echo -e "${NC}"
echo "load 001"
_sleep 2

echo -e "${RED}"
echo "Display the metrics computed for a transaction stored in the active snapshot:"
echo -e "${NC}"
echo "score <ENTER TXID OF DESIRED 0.01 BTC transaction>"
_sleep 2

echo -e "${RED}"
echo "Sample output..."
echo -e "${NC}"
echo "Backward-looking metrics for the outputs of this mix:"
echo   "anonset = 92"
echo   "spread = 89%"
echo "Forward-looking metrics for the outputs of Tx0s having this transaction as their first mix:"
echo   "anonset = 127"
echo   "spread = 76%"
_sleep 2

echo -e "${RED}"
echo "***"
echo "Type: 'quit' at anytime to exit WST."
echo "***"
echo ""
echo "***"
echo "Press any letter to continue..."
echo "***"
echo -e "${NC}"

read -n 1 -r -s

python3 wst.py -w=/tmp -s=127.0.0.1:9050
