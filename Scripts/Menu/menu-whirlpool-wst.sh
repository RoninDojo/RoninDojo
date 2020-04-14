#!/bin/bash

RED=$(tput setaf 1)
# used for color with ${RED}
NC=$(tput sgr0)
# No Color

echo -e "${RED}"
echo "***"
echo "Checking for Whirlpool Stat Tool..."
echo "***"
echo -e "${NC}"
sleep 2s

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
    cd ~/wst/whirlpool_stats/whirlpool_stats
fi

echo -e "${RED}"
echo "Whirlpool Stat Tool INSTRUCTIONS:"
echo -e "${NC}"
sleep 2s

echo -e "${NC}"
echo "Set Socks5 proxy before downloading data from OXT:"
echo -e "${NC}"
echo "socks5 127.0.0.1:9050"
sleep 2s

echo -e "${RED}"
echo "Download in the working directory a snaphot for the 0.01BTC pools:"
echo -e "${NC}"
echo "download 001"
sleep 2s

echo -e "${RED}"
echo "Load and compute the statistcs for the snaphot:"
echo -e "${NC}"
echo "load 001"
sleep 2s

echo -e "${RED}"
echo "Display the metrics computed for a transaction stored in the active snapshot:"
echo -e "${NC}"
echo "score <ENTER TXID OF DESIRED 0.01 BTC transaction>"
sleep 2s

echo -e "${RED}"
echo "Sample output..."
echo -e "${NC}"
echo "Backward-looking metrics for the outputs of this mix:"
echo   "anonset = 92"
echo   "spread = 89%"
echo "Forward-looking metrics for the outputs of Tx0s having this transaction as their first mix:"
echo   "anonset = 127"
echo   "spread = 76%"
sleep 2s

echo -e "${RED}"
echo "***"
echo "Press any letter to continue..."
echo "***"
echo -e "${NC}"

read -n 1 -r -s

python3 wst.py
