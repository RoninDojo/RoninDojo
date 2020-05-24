#!/bin/bash
# shellcheck disable=SC2154
# shellcheck source=/dev/null
. ~/RoninDojo/Scripts/defaults.sh
. ~/RoninDojo/Scripts/functions.sh

if [ -d ~/dojo ]; then
  echo -e "${RED}"
  echo "***"
  echo "Dojo directory found, please uninstall Dojo first!"
  echo "***"
  echo -e "${NC}"
  sleep 5s
  bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh
else
  echo -e "${RED}"
  echo "***"
  echo "Setting up system and installing Dependencies in 15s..."
  echo "***"
  echo -e "${NC}"
  sleep 5s
fi
# checks for ~/dojo directory, if found kicks back to menu

echo -e "${RED}"
echo "***"
echo "If you have already setup your system, use Ctrl+C to exit now!"
echo "***"
echo -e "${NC}"
sleep 5s

~/RoninDojo/Scripts/.logo

# system setup starts

test -f /etc/motd && sudo rm /etc/motd
# remove ssh banner for the script logo

# Disable Bluetooth
if _disable_bluetooth; then
  echo -e "${RED}"
  echo "***"
  echo "Disabling Bluetooth..."
  echo "***"
  echo -e "${NC}"
fi

# Disable IPV6 if needed
if _disable_ipv6; then
  echo -e "${RED}"
  echo "***"
  echo "Disabling Ipv6..."
  echo "***"
  echo -e "${NC}"
fi

if ! grep RoninDojo ~/.bashrc 1>/dev/null; then
  cat << EOF >> ~/.bashrc
~/RoninDojo/Scripts/.logo

~/RoninDojo/ronin
EOF
fi
# place main ronin menu script symbolic link at /usr/local/bin folder
# because most likely that will be path already added to your $PATH variable
# place logo and ronin main menu script ~/.bashrc to run at each login

# Install system dependencies
for pkg in "${package_depedencies[@]}"; do
  if find_pkg "${pkg}"; then
    cat <<EOF
${RED}
***
${pkg} already installed...
***
${NC}
EOF
    _sleep 1
  else
    cat <<EOF
${RED}
***
Installing ${pkg}...
***
${NC}
EOF
    _sleep 1
    sudo pacman -S --noconfirm "${pkg}"
  fi
done

# Check if torrc was modified
if ! grep /mnt/usb/tor /etc/torrc 1>/dev/null; then
  sudo sed -i -e 's/^DataDirectory .*$/DataDirectory /mnt/usb/tor' \
    -e 's/^ControlPort .*$/ControlPort 9051' \
    -e 's/^#CookieAuthentication/CookieAuthentication/' \
    -e '/CookieAuthentication/a CookieAuthFileGroupReadable 1' /etc/tor/torrc
fi

if sudo ufw status | grep 22 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "SSH firewall rule already setup..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  # ufw setup starts
  echo -e "${RED}"
  echo "***"
  echo "Setting up UFW..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo ufw default deny incoming
  sudo ufw default allow outgoing

  echo -e "${RED}"
  echo "***"
  echo "Enabling UFW..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo ufw --force enable
  sudo systemctl enable ufw
  # enabling ufw so /etc/ufw/user.rules file configures properly, then edit using awk and sed below

  ip addr | sed -rn '/state UP/{n;n;s:^ *[^ ]* *([^ ]*).*:\1:;s:[^.]*$:0/24:p}' > ~/ip_tmp.txt
  # creates ip_tmp.txt with IP address listed in ip addr, and makes ending .0/24

  while read -r ip ; do echo "### tuple ### allow any 22 0.0.0.0/0 any $ip" > ~/rule_tmp.txt; done <~/ip_tmp.txt
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 19 in /etc/ufw/user.rules

  while read -r ip ; do echo "-A ufw-user-input -p tcp --dport 22 -s $ip -j ACCEPT" >> ~/rule_tmp.txt; done <~/ip_tmp.txt
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 20 /etc/ufw/user.rules

  while read -r ip ; do echo "-A ufw-user-input -p udp --dport 22 -s $ip -j ACCEPT" >> ~/rule_tmp.txt; done <~/ip_tmp.txt
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 21 /etc/ufw/user.rules

  awk 'NR==1{a=$0}NR==FNR{next}FNR==19{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 1 in rule_tmp.txt to line 19 in /etc/ufw/user.rules
  # using awk to get /lib/ufw/user.rules output, including newly added values, then makes a tmp file
  # after temp file is made it is mv to /lib/ufw/user.rules
  # awk does not have -i to write changes like sed does, that's why I took this approach

  awk 'NR==2{a=$0}NR==FNR{next}FNR==20{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 2 in rule_tmp.txt to line 20 in /etc/ufw/user.rules

  awk 'NR==3{a=$0}NR==FNR{next}FNR==21{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 3 in rule_tmp.txt to line 21 in /etc/ufw/user.rules

  sudo sed -i "18G" /etc/ufw/user.rules
  # adds a space to keep things formatted nicely

  sudo chown root:root /etc/ufw/user.rules
  # this command changes ownership back to root:root
  # when /etc/ufw/user.rules is edited using awk or sed, the owner gets changed from Root to whatever User that edited that file
  # that causes a warning to be displayed as /etc/ufw/user.rules does need to be owned by root:root

  sudo rm ~/ip_tmp.txt ~/rule_tmp.txt
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
  echo "Checking UFW status..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo ufw status
  sleep 4s

  echo -e "${RED}"
  echo "***"
  echo "Now that UFW is enabled, any computer connected to the same local network as your RoninDojo will have SSH access."
  echo "***"
  echo -e "${NC}"
  sleep 5s

  echo -e "${RED}"
  echo "***"
  echo "Leaving this setting default is NOT RECOMMENDED for users who are conncting to something like University, Public Internet, Etc."
  echo "***"
  echo -e "${NC}"
  sleep 5s

  echo -e "${RED}"
  echo "***"
  echo "Firewall rules can be adjusted using the RoninDojo Firewall Menu."
  echo "***"
  echo -e "${NC}"
  sleep 5s
  # ufw setup ends
fi

echo -e "${RED}"
echo "***"
echo "All Dojo dependencies installed..."
echo "***"
echo -e "${NC}"
sleep 3s

cat <<EOF
${RED}
***
Creating /mnt/usb directory...
***
${NC}
EOF

test -d /mnt/usb || sudo mkdir /mnt/usb
sleep 2s

if [ -b /dev/sda1 ]; then
  echo -e "${RED}"
  echo "***"
  echo "Creating /mnt/salvage directory..."
  echo "***"
  echo -e "${NC}"
  sudo mkdir /mnt/salvage
  sleep 2s

  echo -e "${RED}"
  echo "***"
  echo "Attempting to mount drive for Blockchain data salvage..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo mount /dev/sda1 /mnt/salvage
else
  echo -e "${RED}"
  echo "***"
  echo "Did not find /dev/sda1 for Blockchain data salvage."
  echo "***"
  echo -e "${NC}"
  sleep 2s
fi
# mount main storage drive to /mnt/salvage directory if found in prep for data salvage

if sudo test -d /mnt/salvage/uninstall-salvage; then
  echo -e "${RED}"
  echo "***"
  echo "Found Blockchain data for salvage!"
  echo "***"
  echo -e "${NC}"
  sudo rm -rf /mnt/salvage/{swapfile,docker,tor}
  sudo umount /mnt/salvage
  sudo rmdir /mnt/salvage
  # if uninstall-salvage directory is found, delete older {docker,tor} directory and swapfile

  echo -e "${RED}"
  echo "***"
  echo "Mounting drive..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo mount /dev/sda1 /mnt/usb
  sleep 1s
  # mount main storage drive to /mnt/usb directory

  echo -e "${RED}"
  echo "***"
  echo "Displaying the name on the external disk..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  lsblk -o NAME,SIZE,LABEL /dev/sda1
  sleep 2s
  # double-check that /dev/sda exists, and that its storage capacity is what you expected

  echo -e "${RED}"
  echo "***"
  echo "Check output above for /dev/sda1 and make sure everything looks ok."
  echo "***"
  echo -e "${NC}"
  df -h /dev/sda1
  sleep 4s
  # checks disk info

  create_swap --file /mnt/usb/swapfile --size 2G
  # created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

  _docker_datadir_setup

  echo -e "${RED}"
  echo "***"
  echo "Dojo is ready to be installed!"
  echo "***"
  echo -e "${NC}"
  sleep 3s
  exit
else
  echo -e "${RED}"
  echo "***"
  echo "No Blockchain data found for salvage check 1..."
  echo "***"
  echo -e "${NC}"
  sleep 3s
fi
# checks for blockchain data to salvage, if found exits this script to dojo install, and if not found continue to salvage check 2 below

if sudo test -d /mnt/salvage/docker/volumes/my-dojo_data-bitcoind/_data/blocks; then
  echo -e "${RED}"
  echo "***"
  echo "Found Blockchain data for salvage!"
  echo "***"
  echo -e "${NC}"
  sleep 2s

  echo -e "${RED}"
  echo "***"
  echo "Moving to temporary directory..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo mkdir /mnt/salvage/system-setup-salvage
  sudo mv -v /mnt/salvage/docker/volumes/my-dojo_data-bitcoind/_data/{blocks,chainstate} /mnt/salvage/system-setup-salvage/

  echo -e "${RED}"
  echo "***"
  echo "Blockchain data prepared for salvage!"
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo rm -rf /mnt/salvage/{docker,tor,swapfile}
  sudo umount /mnt/salvage
  sudo rmdir /mnt/salvage
  # copies blockchain salvage data to /mnt/salvage if found

  echo -e "${RED}"
  echo "***"
  echo "Mounting drive..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo mount /dev/sda1 /mnt/usb
  sleep 1s
  # mount main storage drive to /mnt/usb directory

  echo -e "${RED}"
  echo "***"
  echo "Displaying the name on the external disk..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  lsblk -o NAME,SIZE,LABEL /dev/sda1
  sleep 2s
  # double-check that /dev/sda exists, and that its storage capacity is what you expected

  echo -e "${RED}"
  echo "***"
  echo "Check output for /dev/sda1 and make sure everything looks ok."
  echo "***"
  echo -e "${NC}"
  df -h /dev/sda1
  sleep 4s
  # checks disk info

  create_swap --file /mnt/usb/swapfile --size 2G
  # created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

  _docker_datadir_setup

  echo -e "${RED}"
  echo "***"
  echo "Dojo is ready to be installed!"
  echo "***"
  echo -e "${NC}"
  sleep 3s
  exit
else
  echo -e "${RED}"
  echo "***"
  echo "No Blockchain data found for salvage check 2..."
  echo "***"
  echo -e "${NC}"
  sleep 3s
  sudo umount /mnt/salvage
  sudo rmdir /mnt/salvage
fi
# checks for blockchain data to salvage, if found continue to dojo install, and if not found continue to format drive

echo -e "${RED}"
echo "***"
echo "Formatting the SSD..."
echo "***"
echo -e "${NC}"
sleep 2s

if [ -b /dev/sda1 ]
then
  echo -e "${RED}"
  echo "***"
  echo "Wiping /dev/sda drive clean"
  echo "***"
  echo -e "${NC}"
  sudo wipefs --all --force /dev/sda1 && sudo sfdisk --delete /dev/sda &>/dev/null
fi
# if sda1 exists, use wipefs to erase possible sig

# Create a partition table with a single partition that takes the whole disk
echo 'type=83' | sudo sfdisk /dev/sda &>/dev/null

if ! create_fs --label "main" --device "/dev/sda1" --mountpoint "/mnt/usb"; then
  echo -e "${RED}Filesystem creation failed! Exiting${NC}"
  exit
fi
# format partition

echo -e "${RED}"
echo "***"
echo "Displaying the name on the external disk..."
echo "***"
echo -e "${NC}"
lsblk -o NAME,SIZE,LABEL /dev/sda1
sleep 2s
# double-check that /dev/sda exists, and that its storage capacity is what you expected

echo -e "${RED}"
echo "***"
echo "Check output for /dev/sda1 and make sure everything looks ok."
echo "***"
echo -e "${NC}"
df -h /dev/sda1
sleep 2s
# checks disk info

create_swap --file /mnt/usb/swapfile --size 2G
# created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

echo -e "${RED}"
echo "***"
echo "Creating Tor directory on the external SSD..."
echo "***"
echo -e "${NC}"
sleep 3s
test -d /mnt/usb/tor || sudo mkdir /mnt/usb/tor
sudo chown -R tor:tor /mnt/usb/tor

_docker_datadir_setup

echo -e "${RED}"
echo "***"
echo "Dojo is ready to be installed!"
echo "***"
echo -e "${NC}"
sleep 3s
# will continue to dojo install if it was selected on the install menu