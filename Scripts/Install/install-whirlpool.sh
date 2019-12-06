#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

echo -e "${RED}"
echo "***"
echo "Installing Whirlpool..."
echo "***"
echo -e "${NC}"
sleep 5s

echo -e "${RED}"
echo "***"
echo "First, a UFW rule will be made for Whirlpool."
echo "***"
echo -e "${NC}"
sleep 2s

echo -e "${RED}"
echo "***"
echo "Whirlpool GUI will be able to access Whirlpool CLI from any machine on your Dojo's local network."
echo "***"
echo -e "${NC}"
sleep 2s

ip addr | sed -rn '/state UP/{n;n;s:^ *[^ ]* *([^ ]*).*:\1:;s:[^.]*$:0/24:p}' > ~/ip_tmp.txt
# creates ip_tmp.txt with IP address listed in ip addr, and makes ending .0/24

sed -i '2,10d' ~/ip_tmp.txt
# delete lines 2-10

cat ~/ip_tmp.txt | while read ip ; do echo "### tuple ### allow any 8899 0.0.0.0/0 any ""$ip" > ~/whirlpool_rule_tmp.txt; done
# pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
# for line 19 in /etc/ufw/user.rules 

cat ~/ip_tmp.txt | while read ip ; do echo "-A ufw-user-input -p tcp --dport 8899 -s "$ip" -j ACCEPT" >> ~/whirlpool_rule_tmp.txt; done
# pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
# for line 20 /etc/ufw/user.rules 

cat ~/ip_tmp.txt | while read ip ; do echo "-A ufw-user-input -p udp --dport 8899 -s "$ip" -j ACCEPT" >> ~/whirlpool_rule_tmp.txt; done
# pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
# for line 21 /etc/ufw/user.rules

sudo awk 'NR==1{a=$0}NR==FNR{next}FNR==19{print a}1' ~/whirlpool_rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
# copying from line 1 in whirlpool_rule_tmp.txt to line 19 in /etc/ufw/user.rules
# using awk to get /lib/ufw/user.rules output, including newly added values, then makes a tmp file
# after temp file is made it is mv to /lib/ufw/user.rules
# awk does not have -i to write changes like sed does, that's why I took this approach

sudo awk 'NR==2{a=$0}NR==FNR{next}FNR==20{print a}1' ~/whirlpool_rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
# copying from line 2 in whirlpool_rule_tmp.txt to line 20 in /etc/ufw/user.rules

sudo awk 'NR==3{a=$0}NR==FNR{next}FNR==21{print a}1' ~/whirlpool_rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
# copying from line 3 in whirlpool_rule_tmp.txt to line 21 in /etc/ufw/user.rules 

sudo sed -i "18G" /etc/ufw/user.rules
# adds a space to keep things formatted nicely

sudo chown root:root /etc/ufw/user.rules
# this command changes ownership back to root:root
# when /etc/ufw/user.rules is edited using awk or sed, the owner gets changed from Root to whatever User that edited that file
# that causes a warning to be displayed as /etc/ufw/user.rules does need to be owned by root:root

sudo rm ~/ip_tmp.txt ~/whirlpool_rule_tmp.txt
# removes txt files that are no longer needed

echo -e "${RED}"
echo "***"
echo "Reloading UFW..."
echo "***"
echo -e "${NC}"
sleep 2s
sudo ufw reload

echo -e "${RED}"
echo "***"
echo "Checking UFW status."
echo "***"
echo -e "${NC}"
sleep 2s
sudo ufw status
sleep 5s

echo -e "${RED}"
echo "***"
echo "Take a moment to check the rule that was just created."
echo "***"
echo -e "${NC}"
sleep 10s

echo -e "${RED}"
echo "***"
echo "Installing Whirlpool Dependencies..."
echo "***"
echo -e "${NC}"
sleep 1s
sudo pacman -S --noconfirm jdk11-openjdk
sleep 3s
# install install openjdk

echo -e "${RED}" 
echo "***"
echo "Created a Whirlpool directory."
echo "***"
echo -e "${NC}"
sleep 1s
cd $HOME
mkdir whirlpool
cd whirlpool
sleep 3s
# create whirlpool directory

echo -e "${RED}" 
echo "***"
echo "Pulling Whirlpool from github..."
echo "***"
echo -e "${NC}"
sleep 2s
wget -O whirlpool.jar https://github.com/Samourai-Wallet/whirlpool-client-cli/releases/download/0.9.3/whirlpool-client-cli-0.9.3-run.jar
sleep 3s
# pull Whirlpool run times

echo -e "${RED}" 
echo "***"
echo "Installing Tor..."
echo "***"
echo -e "${NC}"
sleep 1s
sudo pacman -S --noconfirm tor
sleep 2s
# install tor

# edit torrc
echo -e "${RED}" 
echo "***"
echo "Editing torrc..."
echo "***"
echo -e "${NC}"
sleep 3s
sudo sed -i '52d' /etc/tor/torrc
sudo sed -i '52i DataDirectory /mnt/usb/tor' /etc/tor/torrc
sudo sed -i '56d' /etc/tor/torrc
sudo sed -i '56i ControlPort 9051' /etc/tor/torrc
sudo sed -i '60d' /etc/tor/torrc
sudo sed -i '60i CookieAuthentication 1' /etc/tor/torrc
sudo sed -i '61i CookieAuthFileGroupReadable 1' /etc/tor/torrc
sudo mkdir /mnt/usb/tor/
sudo chown -R tor:tor /mnt/usb/tor/

echo -e "${RED}"
echo "***"
echo "Restarting..."
echo "***"
sleep 1s
sudo systemctl restart tor
sleep 3s

echo -e "${RED}" 
echo "***"
echo "Be prepared to paste Whirlpool Pairing Code from Mobile Wallet and Passphrase."
echo "***"
echo -e "${NC}"
sleep 1s
java -jar whirlpool.jar --init --tor
sleep 3s
# initate Whirlpool

echo "Record this APIkey to connect your Whirlpool GUI:"
APIkey=$(sudo cat /home/$HOME/whirlpool/whirlpool-cli-config.properties | grep cli.Apikey= | cut -c 12-)
echo "$APIkey"
echo ""
sleep 2s

echo -e "${RED}"
echo "***"
echo "Press any letter to continue..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s

echo -e "${RED}"
echo "***"
echo "Opening tmux session and starting Whirlpool..."
echo "***"
echo -e "${NC}"
# setting whirlpool as a Service
echo -e "${NC}" 
USER=$(sudo cat /etc/passwd | grep 1000 | awk -F: '{ print $1}' | cut -c 1-)
# adding tor location to whirlpool configuration
sed -i '25i cli.torConfig.executable=/usr/bin/tor' /home/$USER/whirlpool/whirlpool-cli-config.properties

# create whirlpool tmux session and start Whirlpool
echo -e "${RED}"
echo "***"
echo "Opening tmux session and Start Whirlpool"
echo "***"
echo -e "${NC}"
sleep 1s
echo "
[Unit]
Description=Whirlpool
After=tor.service

[Service]
WorkingDirectory=/home/$USER/whirlpool
ExecStart=/usr/bin/java -jar /home/$USER/whirlpool/whirlpool.jar --server=mainnet --tor --auto-mix --mixs-target=3 --listen
User=$USER
Group=$USER
Type=simple
KillMode=process
TimeoutSec=60
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
" | sudo tee -a /etc/systemd/system/whirlpool.service
sudo systemctl daemon-reload
sudo systemctl start whirlpool

echo -e "${RED}"
echo ""
echo "***"
echo "Starting whirlpool in the background"
echo "***"
sleep 2s
echo "***"
echo "Pair with GUI to unlock wallet and begin mixing"
echo "$APIkey"
echo "***"
sleep 3s

echo "For pairing with GUI head to full guide at:" 
sleep 1s
echo "https://github.com/BTCxZelko/Ronin-Dojo/blob/master/RPi4/Raspbian/Whirlpool-Guide.md#pairing-your-with-the-whirlpool-gui"
sleep 5s
echo -e "${RED}"
echo "***"
echo "Press any letter to return..."
echo "***"
echo -e "${NC}"
read -n 1 -r -s
bash ~/RoninDojo/Scripts/Menu/ronin-whirlpool-menu.sh
