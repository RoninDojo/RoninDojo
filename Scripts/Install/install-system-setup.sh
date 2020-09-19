#!/bin/bash
# shellcheck disable=SC2154 source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -d "$HOME"/dojo ]; then
  echo -e "${RED}"
  echo "***"
  echo "Dojo directory found, please uninstall Dojo first!"
  echo "***"
  echo -e "${NC}"
  _sleep 5
  bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo2.sh
else
  echo -e "${RED}"
  echo "***"
  echo "Setting up system and installing Dependencies in 10s..."
  echo "***"
  echo -e "${NC}"
fi
# checks for "$HOME"/dojo directory, if found kicks back to menu

cat <<SYSTEM
${RED}
***
Use Ctrl+C to exit now if needed!
***
${NC}
SYSTEM
_sleep 10

"$HOME"/RoninDojo/Scripts/.logo
# display ronindojo logo

test -f /etc/motd && sudo rm /etc/motd
# remove ssh banner for the script logo

if _disable_bluetooth; then
  echo -e "${RED}"
  echo "***"
  echo "Disabling Bluetooth..."
  echo "***"
  echo -e "${NC}"
fi
# disable bluetooth, see functions.sh

if _disable_ipv6; then
  echo -e "${RED}"
  echo "***"
  echo "Disabling Ipv6..."
  echo "***"
  echo -e "${NC}"
fi
# disable ipv6, see functions.sh

# Install system dependencies
for pkg in "${!package_dependencies[@]}"; do
  if hash "${pkg}" 2>/dev/null; then
    cat <<EOF
${RED}
***
${package_dependencies[$pkg]} already installed...
***
${NC}
EOF
    _sleep
  else
    cat <<EOF
${RED}
***
Installing ${package_dependencies[$pkg]}...
***
${NC}
EOF
    _sleep
    sudo pacman -S --noconfirm "${package_dependencies[$pkg]}"
  fi
done
# install system dependencies, see defaults.sh
# websearch "bash associative array" for info

if sudo ufw status | grep 22 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "SSH firewall rule already setup..."
  echo "***"
  echo -e "${NC}"
  _sleep
else
  echo -e "${RED}"
  echo "***"
  echo "Setting up UFW..."
  echo "***"
  echo -e "${NC}"
  _sleep
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  # setting up uncomplicated firewall

  echo -e "${RED}"
  echo "***"
  echo "Enabling UFW..."
  echo "***"
  echo -e "${NC}"
  _sleep
  sudo ufw --force enable
  sudo systemctl enable ufw 2>/dev/null
  # enabling ufw so /etc/ufw/user.rules file configures properly

  ip addr | sed -rn '/state UP/{n;n;s:^ *[^ ]* *([^ ]*).*:\1:;s:[^.]*$:0/24:p}' > "$HOME"/ip_tmp.txt
  # creates ip_tmp.txt with IP addresses listed in ip addr

  while read -r ip ; do echo "### tuple ### allow any 22 0.0.0.0/0 any $ip" > "$HOME"/rule_tmp.txt; done <"$HOME"/ip_tmp.txt
  # make rule_tmp.txt with needed changes plus the ip address

  while read -r ip ; do echo "-A ufw-user-input -p tcp --dport 22 -s $ip -j ACCEPT" >> "$HOME"/rule_tmp.txt; done <"$HOME"/ip_tmp.txt
  # edit rule_tmp.txt

  while read -r ip ; do echo "-A ufw-user-input -p udp --dport 22 -s $ip -j ACCEPT" >> "$HOME"/rule_tmp.txt; done <"$HOME"/ip_tmp.txt
  # edit rule_tmp.txt

  awk 'NR==1{a=$0}NR==FNR{next}FNR==19{print a}1' "$HOME"/rule_tmp.txt /etc/ufw/user.rules > "$HOME"/user.rules_tmp.txt && sudo mv "$HOME"/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 1 in rule_tmp.txt to line 19 in /etc/ufw/user.rules
  # using awk to get /lib/ufw/user.rules output, including newly added values, then makes a tmp file
  # after temp file is made it is mv to /lib/ufw/user.rules
  # awk does not have -i to write changes like sed does, that's why I took this approach

  awk 'NR==2{a=$0}NR==FNR{next}FNR==20{print a}1' "$HOME"/rule_tmp.txt /etc/ufw/user.rules > "$HOME"/user.rules_tmp.txt && sudo mv "$HOME"/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 2 in rule_tmp.txt to line 20 in /etc/ufw/user.rules

  awk 'NR==3{a=$0}NR==FNR{next}FNR==21{print a}1' "$HOME"/rule_tmp.txt /etc/ufw/user.rules > "$HOME"/user.rules_tmp.txt && sudo mv "$HOME"/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 3 in rule_tmp.txt to line 21 in /etc/ufw/user.rules

  sudo sed -i "18G" /etc/ufw/user.rules
  # adds a space to keep things formatted nicely

  sudo chown root:root /etc/ufw/user.rules
  # this command changes ownership back to root:root
  # when /etc/ufw/user.rules is edited using awk or sed, the owner gets changed from Root to whatever User that edited that file
  # that causes a warning to be displayed as /etc/ufw/user.rules does need to be owned by root:root

  sudo rm "$HOME"/ip_tmp.txt "$HOME"/rule_tmp.txt
  # removes txt files that are no longer needed

  echo -e "${RED}"
  echo "***"
  echo "Reloading UFW..."
  echo "***"
  echo -e "${NC}"
  _sleep
  sudo ufw reload

  echo -e "${RED}"
  echo "***"
  echo "Checking UFW status..."
  echo "***"
  echo -e "${NC}"
  _sleep
  sudo ufw status

  UFW_IP=$(sudo ufw status | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
  sudo ufw allow from "$UFW_IP"/24 to any port 22 comment 'SSH access restricted to local network'
  # add comment to initial ufw rule

  echo -e "${RED}"
  echo "***"
  echo "Now that UFW is enabled, any computer connected to the same local network as your RoninDojo will have SSH access."
  echo "***"
  echo -e "${NC}"

  echo -e "${RED}"
  echo "***"
  echo "Leaving this setting default is NOT RECOMMENDED for users who are connecting to something like University, Public Internet, Etc."
  echo "***"
  echo -e "${NC}"

  echo -e "${RED}"
  echo "***"
  echo "Firewall rules can be adjusted using the RoninDojo Firewall Menu."
  echo "***"
  echo -e "${NC}"
  _sleep 10
fi

echo -e "${RED}"
echo "***"
echo "All Dojo dependencies installed..."
echo "***"
echo -e "${NC}"
_sleep 2

cat <<EOF
${RED}
***
Creating "${INSTALL_DIR}" directory...
***
${NC}
EOF

test -d "${INSTALL_DIR}" || sudo mkdir "${INSTALL_DIR}"
# test for ${INSTALL_DIR} directory, otherwise creates using mkdir
# websearch "bash Logical OR (||)" for info

if [ -b "${PRIMARY_STORAGE}" ]; then
  echo -e "${RED}"
  echo "***"
  echo "Creating ${SALVAGE_MOUNT} directory..."
  echo "***"
  echo -e "${NC}"
  test ! -d "${SALVAGE_MOUNT}" && sudo mkdir "${SALVAGE_MOUNT}"

  echo -e "${RED}"
  echo "***"
  echo "Attempting to mount drive for Blockchain data salvage..."
  echo "***"
  echo -e "${NC}"
  _sleep
  sudo mount "${PRIMARY_STORAGE}" "${SALVAGE_MOUNT}"
else
  echo -e "${RED}"
  echo "***"
  echo "Did not find ${PRIMARY_STORAGE} for Blockchain data salvage."
  echo "***"
  echo -e "${NC}"
  _sleep
fi
# mount main storage drive to "${SALVAGE_MOUNT}" directory if found in prep for data salvage

if sudo test -d "${SALVAGE_BITCOIN_IBD_DATA}/blocks"; then
  echo -e "${RED}"
  echo "***"
  echo "Found Blockchain data for salvage!"
  echo "***"
  echo -e "${NC}"

  # Check if swap in use
  if ! check_swap "${SALVAGE_MOUNT}/swapfile"; then
    test -f "${SALVAGE_MOUNT}/swapfile" && sudo swapoff "${SALVAGE_MOUNT}/swapfile"
  fi

  if [ -f "${SALVAGE_MOUNT}"/swapfile ]; then
    sudo rm -rf "${SALVAGE_MOUNT}"/{swapfile,docker,tor}
  fi

  if findmnt "${SALVAGE_MOUNT}" 1>/dev/null; then
    sudo umount "${SALVAGE_MOUNT}"
    sudo rmdir "${SALVAGE_MOUNT}"
  fi
  # if uninstall-salvage directory is found, delete older {docker,tor} directory and swapfile

  echo -e "${RED}"
  echo "***"
  echo "Mounting drive..."
  echo "***"
  echo -e "${NC}"

  # Mount primary drive if not already mounted
  findmnt "${PRIMARY_STORAGE}" 1>/dev/null || sudo mount "${PRIMARY_STORAGE}" "${INSTALL_DIR}"

  _sleep
  # mount main storage drive to ${INSTALL_DIR} directory

  echo -e "${RED}"
  echo "***"
  echo "Displaying the name on the external disk..."
  echo "***"
  echo -e "${NC}"
  lsblk -o NAME,SIZE,LABEL "${PRIMARY_STORAGE}"
  # double-check that /dev/sda exists, and that its storage capacity is what you expected

  echo -e "${RED}"
  echo "***"
  echo "Check output above for ${PRIMARY_STORAGE} and make sure everything looks ok."
  echo "***"
  echo -e "${NC}"
  df -h "${PRIMARY_STORAGE}"
  _sleep 5
  # checks disk info

  create_swap --file "${INSTALL_DIR_SWAP}" --size 2G
  # created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

  _setup_tor
  # tor configuration setup, see functions.sh

  _docker_datadir_setup
  # docker data directory setup, see functions.sh

  echo -e "${RED}"
  echo "***"
  echo "Dojo is ready to be installed!"
  echo "***"
  echo -e "${NC}"
  _sleep 3
  exit
else
  echo -e "${RED}"
  echo "***"
  echo "No Blockchain data found for salvage check 1..."
  echo "***"
  echo -e "${NC}"
  _sleep 2
fi
# checks for blockchain data to salvage, if found exits this script to dojo install, and if not found continue to salvage check 2 below

if sudo test -d "${SALVAGE_MOUNT}/${BITCOIND_DATA_DIR}/_data/blocks"; then
  echo -e "${RED}"
  echo "***"
  echo "Found Blockchain data for salvage!"
  echo "***"
  echo -e "${NC}"

  echo -e "${RED}"
  echo "***"
  echo "Moving to temporary directory..."
  echo "***"
  echo -e "${NC}"
  _sleep 2

  test -d "${SALVAGE_BITCOIN_IBD_DATA}" || mkdir "${SALVAGE_BITCOIN_IBD_DATA}"

  sudo mv -v "${SALVAGE_MOUNT}/${BITCOIND_DATA_DIR}/_data/"{blocks,chainstate} "${SALVAGE_BITCOIN_IBD_DATA}"/
  # moves blockchain salvage data to ${SALVAGE_MOUNT} if found

  echo -e "${RED}"
  echo "***"
  echo "Blockchain data prepared for salvage!"
  echo "***"
  echo -e "${NC}"
  _sleep 2

  # Check if swap in use
  if ! check_swap "${SALVAGE_MOUNT}/swapfile"; then
    test -f "${SALVAGE_MOUNT}/swapfile" && sudo swapoff "${SALVAGE_MOUNT}/swapfile"
  fi

  sudo rm -rf "${SALVAGE_MOUNT}"/{docker,tor,swapfile}

  if findmnt "${SALVAGE_MOUNT}" 1>/dev/null; then
    sudo umount "${SALVAGE_MOUNT}"
    sudo rmdir "${SALVAGE_MOUNT}"
  fi
  # remove docker, tor, swap file directories from ${SALVAGE_MOUNT}
  # then unmount and remove ${SALVAGE_MOUNT}

  echo -e "${RED}"
  echo "***"
  echo "Mounting drive..."
  echo "***"
  echo -e "${NC}"

  # Mount primary drive if not already mounted
  findmnt "${PRIMARY_STORAGE}" 1>/dev/null || sudo mount "${PRIMARY_STORAGE}" "${INSTALL_DIR}"

  _sleep

  echo -e "${RED}"
  echo "***"
  echo "Displaying the name on the external disk..."
  echo "***"
  echo -e "${NC}"
  lsblk -o NAME,SIZE,LABEL "${PRIMARY_STORAGE}"
  # lsblk lists disk by device
  # double-check that ${PRIMARY_STORAGE} exists, and its storage capacity is what you expected

  echo -e "${RED}"
  echo "***"
  echo "Check output for ${PRIMARY_STORAGE} and make sure everything looks ok."
  echo "***"
  echo -e "${NC}"
  df -h "${PRIMARY_STORAGE}"
  _sleep 5
  # checks disk info

  create_swap --file "${INSTALL_DIR_SWAP}" --size 2G
  # created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

  _setup_tor
  # tor configuration setup, see functions.sh

  _docker_datadir_setup
  # docker data directory setup, see functions.sh

  echo -e "${RED}"
  echo "***"
  echo "Dojo is ready to be installed!"
  echo "***"
  echo -e "${NC}"
  _sleep 2
  exit
else
  echo -e "${RED}"
  echo "***"
  echo "No Blockchain data found for salvage check 2..."
  echo "***"
  echo -e "${NC}"
  _sleep 2

  # Check if swap in use
  if ! check_swap "${SALVAGE_MOUNT}/swapfile" ; then
    test -f "${SALVAGE_MOUNT}/swapfile" && sudo swapoff "${SALVAGE_MOUNT}/swapfile"
  fi

  if findmnt "${SALVAGE_MOUNT}" 1>/dev/null; then
    sudo umount "${SALVAGE_MOUNT}"
    sudo rmdir "${SALVAGE_MOUNT}"
  fi
fi
# checks for blockchain data to salvage, if found exit to dojo install, and if not found continue to format drive

echo -e "${RED}"
echo "***"
echo "Formatting the SSD..."
echo "***"
echo -e "${NC}"
_sleep 2

if ! create_fs --label "main" --device "${PRIMARY_STORAGE}" --mountpoint "${INSTALL_DIR}"; then
  echo -e "${RED}Filesystem creation failed! Exiting${NC}"
  exit 1
fi
# create a partition table with a single partition that takes the whole disk
# format partition

echo -e "${RED}"
echo "***"
echo "Displaying the name on the external disk..."
echo "***"
echo -e "${NC}"
lsblk -o NAME,SIZE,LABEL "${PRIMARY_STORAGE}"
# double-check that ${PRIMARY_STORAGE} exists, and its storage capacity is what you expected

echo -e "${RED}"
echo "***"
echo "Check output for ${PRIMARY_STORAGE} and make sure everything looks ok..."
echo "***"
echo -e "${NC}"
df -h "${PRIMARY_STORAGE}"
_sleep 5
# checks disk info

create_swap --file "${INSTALL_DIR_SWAP}" --size 2G
# created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

if [ ! -d "${RONIN_UI_BACKEND_DIR}" ]; then
  _install_ronin_ui_backend
  # Install Ronin UI Backend service
fi

_setup_tor
# tor configuration setup, see functions.sh

_docker_datadir_setup
# docker data directory setup, see functions.sh

echo -e "${RED}"
echo "***"
echo "Dojo is ready to be installed!"
echo "***"
echo -e "${NC}"
_sleep 3
# will continue to dojo install if it was selected on the install menu
