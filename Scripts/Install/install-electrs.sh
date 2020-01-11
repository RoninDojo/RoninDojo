 
#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
YELLOW='\033[1;33m'
# used for color with ${YELLOW}
NC='\033[0m'
# No Color

echo -e "${RED}"
echo "***"
echo "Adding Electrs into Dojo stack..."
sleep 1s
echo "This will update your Dojo...this may take some time"
echo "***"
echo -e "${NC}"
sleep 5s

# electrs branch of Dojo
cd ~/dojo/docker/my-dojo
sudo ./dojo.sh stop
mkdir ~/.dojo > /dev/null 2>&1
cd ~/.dojo
git clone -b feat_electrs https://github.com/RoninDojo/samourai-dojo.git
sudo cp -rv samourai-dojo/* ~/dojo
cd ~/dojo/docker/my-dojo/
sudo ./dojo.sh upgrade

echo "Electrum Wallet: To connect through Tor, open the Tor Browser, and start with the following options:" 
sleep 1s
echo "For pairing with GUI see full guide: https://github.com/BTCxZelko/Ronin-Dojo/blob/master/RPi4/Manjaro/Minimal/Electrs.md"
sleep 5s

echo -e "${RED}"
echo "***"
echo "Complete!"
echo "***"
echo -e "${NC}"
sleep 2s
bash ~/RoninDojo/ronin
