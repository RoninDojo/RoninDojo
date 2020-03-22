#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

echo -e "${RED}"
echo "Checking for Whirlpool Stat Tool..."
echo -e "${NC}"
if [ ! -f ~/wst/whirlpool_stats/whirlpool_stats/wst.py ]; then
    echo -e "${RED}"
    echo "***"
    echo "Installing Whirlpool Stat Tool..."
    echo "***"
    echo -e "${NC}"
    mkdir ~/wst;
    cd ~/wst;
    git clone https://github.com/Samourai-Wallet/whirlpool_stats.git;
    sudo pacman -Syyu
    sudo pacman -S python-pip 19.3.1-1;
    cd whirlpool_stats;
    pip3 install -r ./requirements.txt;
    cd whirlpool_stats;
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
    cd ~/wst/whirlpool_stats/whirlpool_stats
fi

echo -e "${RED}"
echo "Whirlpool Stat Tool INSTRUCTIONS"
sleep 2s
echo "Set Socks5 proxy before downloading data from OXT"
echo -e "${NC}"
echo "socks5 127.0.0.1:9050"
sleep 2s
echo -e "${RED}"
echo "Download in the working directory a snaphot for the 0.01BTC pools"
echo -e "${NC}"
echo "download 001"
sleep 2s
echo -e "${RED}"
echo "Load and compute the statistcs for the snaphot"
echo -e "${NC}"
echo "load 001"
sleep 2s
echo -e "${RED}"
echo "Display the metrics computed for a transaction stored in the active snapshot"
echo -e "${NC}"
echo "score <ENTER TXID OF DESIRED 0.01 BTC transaction>"
echo -e "${RED}"
echo "Sample output..."
echo -e "${NC}"
echo "Backward-looking metrics for the outputs of this mix:"
echo   "anonset = 92"
echo   "spread = 89%"
echo "Forward-looking metrics for the outputs of Tx0s having this transaction as their first mix:"
echo   "anonset = 127"
echo   "spread = 76%"

echo -e "${RED}"
echo "***"
echo "Press any letter to continue..."
echo "***"
echo -e "${NC}"

read -n 1 -r -s

python3 wst.py
