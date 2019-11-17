#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
YELLOW='\033[1;33m'
# used for color with ${YELLOW}
NC='\033[0m'
# No Color

echo -e "${RED}"
echo "***"
echo "Installing Electrs..."
echo "***"
echo -e "${NC}"
sleep 5s

# Install Rust and Clang
echo -e "${RED}"
echo "***"
echo "Installing Rust and Clang for Electrs..."
echo "***"
echo -e "${NC}"
sleep 2s
USER=$(sudo cat /etc/passwd | grep 1000 | awk -F: '{ print $1}' | cut -c 1-)
cd $HOME
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup install 1.37.0 --force
rustup override set 1.37.0
sudo pacman -S clang -y
sleep 2s

# Make electrs database dir and give permissions
echo -e "${RED}" 
echo "***"
echo "Creating Database location for Electrs..."
echo "***"
echo -e "${NC}"
sleep 1s
sudo mkdir /mnt/usb/electrs
sudo mkdir /mnt/usb/electrs/db
sudo chown -R $USER:$USER /mnt/usb/electrs/
sudo chmod 755 /mnt/usb/electrs/
sudo chmod 755 /mnt/usb/electrs/db
sleep 3s

# Installing Electrs
echo -e "${RED}" 
echo "***"
echo "Installing Electrs, this may take some time..."
echo "***"
echo -e "${NC}"
sleep 1s
cd $HOME
git clone https://github.com/romanz/electrs /home/$USER/electrs
cd /home/$USER/electrs
cargo build --release
sleep 3s

# Configure Electrs
echo -e "${RED}" 
echo "***"
echo "Editing the Electrs config.toml file..."
echo "***"
echo -e "${NC}"
sleep 1s
RPC_USER=$(sudo cat /home/$USER/dojo/docker/my-dojo/conf/docker-bitcoind.conf | grep BITCOIND_RPC_USER= | cut -c 19-)
RPC_PASS=$(sudo cat /home/$USER/dojo/docker/my-dojo/conf/docker-bitcoind.conf | grep BITCOIND_RPC_PASSWORD= | cut -c 23-)
sudo mkdir /home/electrs/.electrs
touch /home/$USER/config.toml
chmod 600 /home/$USER/config.toml || exit 1 
cat > /home/$USER/config.toml <<EOF
verbose = 4
timestamp = true
jsonrpc_import = true
db_dir = "/mnt/usb/electrs/db"
cookie = "$RPC_USER:$RPC_PASS"
server_banner = "Welcome to your Ronin Personal Electrs Server!"
daemon_dir = "/mnt/usb/docker/volumes/my-dojo_bitcoind_data/_data" 
daemon_rpc_addr = "127.0.0.1:28256"
EOF

sudo mv /home/$USER/config.toml /home/$USER/.electrs/config.toml
# move config file
sleep 3s

# edit torrc
echo -e "${RED}" 
echo "***"
echo "Editting torrc..."
echo "***"
echo -e "${NC}"
sleep 1s
sudo sed -i '78i HiddenServiceDir /mnt/usb/tor/hidden_service/' /etc/tor/torrc
sudo sed -i '79i HiddenServiceVersion 3' /etc/tor/torrc
sudo sed -i '80i HiddenServicePort 50001 127.0.0.1:50001' /etc/tor/torrc

echo -e "${RED}"
echo "***"
echo "Restarting Tor..."
echo "***"
echo -e "${NC}"
sleep 2s
sudo systemctl restart tor

# sudo nano /etc/systemd/system/electrs.service 
echo "
[Unit]
Description=Electrs
After=dojo.service
[Service]
WorkingDirectory=/home/$USER/electrs
ExecStart=/home/$USER/electrs/target/release/electrs --electrum-rpc-addr="0.0.0.0:50001"
User=$USER
Group=$USER
Type=simple
KillMode=process
TimeoutSec=60
Restart=always
RestartSec=60
[Install]
WantedBy=multi-user.target
" | sudo tee -a /etc/systemd/system/electrs.service 

sudo systemctl enable electrs
sudo systemctl start electrs

echo -e "${RED}"
echo "***"
echo "Electrs will run in the background, and at startup. To disable go to Electrs menu."
echo "***"
echo -e "${NC}"
sleep 5s

echo -e "${RED}"
echo "***"
echo "Electrs is running!"
echo "***"
echo -e "${NC}"
sleep 5s

TOR_ADDRESS=$(sudo cat /mnt/ssd/tor/hidden_service/hostname)
echo "The Tor Hidden Service address for electrs is:"
echo "$TOR_ADDRESS"
sleep 5s 

echo "Electrum Wallet: To connect through Tor, open the Tor Browser, and start with the following options:" 
sleep 5s
echo "\`electrum --oneserver --server=$TOR_ADDRESS:50001:s --proxy socks5:127.0.0.1:9050\`"
echo "***"
sleep 5s

echo "Electrum Wallet: To connect through Tor Daemon, start with the following options:"
sleep 5s
echo "\`electrum --oneserver --server=$TOR_ADDRESS:50001:s --proxy socks5:127.0.0.1:9050\`"
sleep 5s
echo "For pairing with GUI see full guide: https://github.com/BTCxZelko/Ronin-Dojo/blob/master/RPi4/Manjaro/Minimal/Electrs.md"
sleep 5s

echo -e "${RED}"
echo "***"
echo "Complete!"
echo "***"
echo -e "${NC}"
sleep 2s
