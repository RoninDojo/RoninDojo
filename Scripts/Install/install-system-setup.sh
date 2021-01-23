#!/bin/bash
# shellcheck disable=SC2154 source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -d "$HOME"/dojo ]; then
    cat <<EOF
${RED}
***
Dojo directory found, please uninstall Dojo first!
***
${NC}
EOF
    _sleep 2

    _pause return
    bash "$HOME"/RoninDojo/Scripts/Menu/menu-install.sh
else
    cat <<EOF
${RED}
***
Setting up system and installing dependencies...
***
${NC}
EOF
fi
_sleep 2
# checks for "$HOME"/dojo directory, if found kicks back to menu

cat <<EOF
${RED}
***
Use Ctrl+C to exit now if needed!
***
${NC}
EOF
_sleep 10 --msg "Installing in"

"$HOME"/RoninDojo/Scripts/.logo
# display ronindojo logo

test -f /etc/motd && sudo rm /etc/motd
# remove ssh banner for the script logo

if _disable_bluetooth; then
    cat <<EOF
${RED}
***
Disabling Bluetooth...
***
${NC}
EOF
fi
# disable bluetooth, see functions.sh

if _disable_ipv6; then
    cat <<EOF
${RED}
***
Disabling Ipv6...
***
${NC}
EOF
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

sudo sed -i "s:^#IgnorePkg   =.*$:IgnorePkg   = tor docker docker-compose bridge-utils:" /etc/pacman.conf
# add packages to Ignore durink upgrades if user runs pacman -Syyu to prevent breaking changes

if sudo ufw status | grep 22 > /dev/null ; then
    cat <<EOF
${RED}
***
SSH firewall rule already setup...
***
${NC}
EOF
    _sleep
else
    cat <<EOF
${RED}
***
Setting up UFW...
***
${NC}
EOF
    _sleep

    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    # setting up uncomplicated firewall

    cat <<EOF
${RED}
***
Enabling UFW...
***
${NC}
EOF
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

    cat <<EOF
${RED}
***
Reloading UFW...
***
${NC}
EOF
    _sleep

    sudo ufw reload

    cat <<EOF
${RED}
***
Checking UFW status...
***
${NC}
EOF
    _sleep

    sudo ufw status

    UFW_IP=$(sudo ufw status | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
    sudo ufw allow from "$UFW_IP"/24 to any port 22 comment 'SSH access restricted to local network'
    # add comment to initial ufw rule

    cat <<EOF
${RED}
***
Now that UFW is enabled, any computer connected to the same local network as your RoninDojo will have SSH access.
***
${NC}
EOF

    cat <<EOF
${RED}
***
Leaving this setting default is NOT RECOMMENDED for users who are connecting to something like University, Public Internet, Etc.
***
${NC}
EOF

    cat <<EOF
${RED}
***
Firewall rules can be adjusted using the RoninDojo Firewall Menu.
***
${NC}
EOF
    _sleep 10
fi

cat <<EOF
${RED}
***
All Dojo dependencies installed...
***
${NC}
EOF
_sleep

cat <<EOF
${RED}
***
Creating ${INSTALL_DIR} directory...
***
${NC}
EOF
_sleep

test -d "${INSTALL_DIR}" || sudo mkdir "${INSTALL_DIR}"
# test for ${INSTALL_DIR} directory, otherwise creates using mkdir
# websearch "bash Logical OR (||)" for info

if [ -b "${PRIMARY_STORAGE}" ]; then
    cat <<EOF
${RED}
***
Creating ${STORAGE_MOUNT} directory...
***
${NC}
EOF
    _sleep

    test ! -d "${STORAGE_MOUNT}" && sudo mkdir "${STORAGE_MOUNT}"

    cat <<EOF
${RED}
***
Attempting to mount drive for Blockchain data salvage...
***
${NC}
EOF
    _sleep
    sudo mount "${PRIMARY_STORAGE}" "${STORAGE_MOUNT}"
else
    cat <<EOF
${RED}
***
Did not find ${PRIMARY_STORAGE} for Blockchain data salvage.
***
${NC}
EOF
    _sleep
fi
# mount main storage drive to "${STORAGE_MOUNT}" directory if found in prep for data salvage

if sudo test -d "${BITCOIN_IBD_BACKUP_DIR}/blocks"; then
    cat <<EOF
${RED}
***
Found Blockchain data for salvage!
***
${NC}
EOF
_sleep

    # Check if swap in use
    if check_swap "${STORAGE_MOUNT}/swapfile"; then
        test -f "${STORAGE_MOUNT}/swapfile" && sudo swapoff "${STORAGE_MOUNT}/swapfile" &>/dev/null
    fi

    if [ -f "${STORAGE_MOUNT}"/swapfile ]; then
        sudo rm -rf "${STORAGE_MOUNT}"/{swapfile,docker,tor}
    fi

    if findmnt "${STORAGE_MOUNT}" 1>/dev/null; then
        sudo umount "${STORAGE_MOUNT}"
        sudo rmdir "${STORAGE_MOUNT}"
    fi
    # if uninstall-salvage directory is found, delete older {docker,tor} directory and swapfile

    cat <<EOF
${RED}
***
Mounting drive...
***
${NC}
EOF
_sleep

    # Mount primary drive if not already mounted
    findmnt "${PRIMARY_STORAGE}" 1>/dev/null || sudo mount "${PRIMARY_STORAGE}" "${INSTALL_DIR}"

    cat <<EOF
${RED}
***
Displaying the name on the external disk...
***
${NC}
EOF
_sleep

    lsblk -o NAME,SIZE,LABEL "${PRIMARY_STORAGE}"
    # double-check that /dev/sda exists, and that its storage capacity is what you expected

    cat <<EOF
${RED}
***
Check output for ${PRIMARY_STORAGE} and make sure everything looks ok...
***
${NC}
EOF

    df -h "${PRIMARY_STORAGE}"
    _sleep 5
    # checks disk info

    create_swap --file "${INSTALL_DIR_SWAP}" --size 2G
    # created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

    _setup_tor
    # tor configuration setup, see functions.sh

    _docker_datadir_setup
    # docker data directory setup, see functions.sh

    _create_ronin_data_dir
    # create directory to store user info, see functions.sh

    cat <<EOF
${RED}
***
Dojo is ready to be installed!
***
${NC}
EOF
    _sleep 3
    exit
else
    cat <<EOF
${RED}
***
No Blockchain data found for salvage check 1...
***
${NC}
EOF
    _sleep 2
fi
# checks for blockchain data to salvage, if found exits this script to dojo install, and if not found continue to salvage check 2 below

if sudo test -d "${STORAGE_MOUNT}/${BITCOIND_DATA_DIR}/_data/blocks"; then
    cat <<EOF
${RED}
***
Found Blockchain data for salvage!
***
${NC}
EOF
    _sleep

    cat <<EOF
${RED}
***
Moving to temporary directory...
***
${NC}
EOF
    _sleep 2

    test -d "${BITCOIN_IBD_BACKUP_DIR}" || sudo mkdir "${BITCOIN_IBD_BACKUP_DIR}"

    sudo mv -v "${STORAGE_MOUNT}/${BITCOIND_DATA_DIR}/_data/"{blocks,chainstate} "${BITCOIN_IBD_BACKUP_DIR}"/ 1>/dev/null
    # moves blockchain salvage data to ${STORAGE_MOUNT} if found

    cat <<EOF
${RED}
***
Blockchain data prepared for salvage!
***
${NC}
EOF
    _sleep 2

    # Check if swap in use
    if check_swap "${STORAGE_MOUNT}/swapfile"; then
        test -f "${STORAGE_MOUNT}/swapfile" && sudo swapoff "${STORAGE_MOUNT}/swapfile" &>/dev/null
    fi

    sudo rm -rf "${STORAGE_MOUNT}"/{docker,tor,swapfile}

    if findmnt "${STORAGE_MOUNT}" 1>/dev/null; then
        sudo umount "${STORAGE_MOUNT}"
        sudo rmdir "${STORAGE_MOUNT}"
    fi
    # remove docker, tor, swap file directories from ${STORAGE_MOUNT}
    # then unmount and remove ${STORAGE_MOUNT}

    cat <<EOF
${RED}
***
Mounting drive...
***
${NC}
EOF
    _sleep

    # Mount primary drive if not already mounted
    findmnt "${PRIMARY_STORAGE}" 1>/dev/null || sudo mount "${PRIMARY_STORAGE}" "${INSTALL_DIR}"

    _sleep

    cat <<EOF
${RED}
***
Displaying the name on the external disk...
***
${NC}
EOF
    _sleep

    lsblk -o NAME,SIZE,LABEL "${PRIMARY_STORAGE}"
    # lsblk lists disk by device
    # double-check that ${PRIMARY_STORAGE} exists, and its storage capacity is what you expected

    cat <<EOF
${RED}
***
Check output for ${PRIMARY_STORAGE} and make sure everything looks ok...
***
${NC}
EOF

    df -h "${PRIMARY_STORAGE}"
    _sleep 5
    # checks disk info

    create_swap --file "${INSTALL_DIR_SWAP}" --size 2G
    # created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

    _setup_tor
    # tor configuration setup, see functions.sh

    _docker_datadir_setup
    # docker data directory setup, see functions.sh

    cat <<EOF
${RED}
***
Dojo is ready to be installed!
***
${NC}
EOF
    _sleep 2
    exit
else
    cat <<EOF
${RED}
***
No Blockchain data found for salvage check 2...
***
${NC}
EOF
    _sleep 2

    # Check if swap in use
    if check_swap "${STORAGE_MOUNT}/swapfile" ; then
        test -f "${STORAGE_MOUNT}/swapfile" && sudo swapoff "${STORAGE_MOUNT}/swapfile" &>/dev/null
    fi

    if findmnt "${STORAGE_MOUNT}" 1>/dev/null; then
        sudo umount "${STORAGE_MOUNT}"
        sudo rmdir "${STORAGE_MOUNT}"
    fi
fi
# checks for blockchain data to salvage, if found exit to dojo install, and if not found continue to format drive

cat <<EOF
${RED}
***
Formatting the SSD...
***
${NC}
EOF
_sleep 2

if ! create_fs --label "main" --device "${PRIMARY_STORAGE}" --mountpoint "${INSTALL_DIR}"; then
    printf "\n %sFilesystem creation failed! Exiting now...%s" "${RED}" "${NC}"
    _sleep 3
    exit 1
fi
# create a partition table with a single partition that takes the whole disk
# format partition

cat <<EOF
${RED}
***
Displaying the name on the external disk...
***
${NC}
EOF
_sleep

lsblk -o NAME,SIZE,LABEL "${PRIMARY_STORAGE}"
# double-check that ${PRIMARY_STORAGE} exists, and its storage capacity is what you expected

cat <<EOF
${RED}
***
Check output for ${PRIMARY_STORAGE} and make sure everything looks ok...
***
${NC}
EOF

df -h "${PRIMARY_STORAGE}"
_sleep 5
# checks disk info

create_swap --file "${INSTALL_DIR_SWAP}" --size 2G
# created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

_setup_tor
# tor configuration setup, see functions.sh

_docker_datadir_setup
# docker data directory setup, see functions.sh

cat <<EOF
${RED}
***
Installing SW Toolkit...
***
${NC}
EOF
_sleep 2

cat <<EOF
${RED}
***
Installing Boltzmann Calculator...
***
${NC}
EOF
_sleep 2

_install_boltzmann
# install Boltzmann

cat <<EOF
${RED}
***
Installing Whirlpool Stat Tool...
***
${NC}
EOF
_sleep 2

_install_wst

cat <<EOF
${RED}
***
Dojo is ready to be installed!
***
${NC}
EOF
_sleep 3
# will continue to dojo install if it was selected on the install menu