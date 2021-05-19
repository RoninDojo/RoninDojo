#!/bin/bash
# shellcheck disable=SC2154 source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if [ -d "$HOME"/dojo ]; then
    cat <<EOF
${red}
***
Dojo directory found, please uninstall Dojo first!
***
${nc}
EOF
    _sleep

    _pause return
    bash "$HOME"/RoninDojo/Scripts/Menu/menu-install.sh
elif [ -f "${ronin_data_dir}"/system-install ]; then
    cat <<EOF
${red}
***
Previous system install detected. Exiting script...
***
${nc}
EOF
    _pause return
    bash "$HOME"/RoninDojo/Scripts/Menu/menu-install.sh
else
    cat <<EOF
${red}
***
Setting up system and installing dependencies...
***
${nc}
EOF
fi
_sleep
# checks for "$HOME"/dojo directory, if found kicks back to menu

cat <<EOF
${red}
***
Use Ctrl+C to exit now if needed!
***
${nc}
EOF
_sleep 10 --msg "Installing in"

"$HOME"/RoninDojo/Scripts/.logo
# display ronindojo logo

test -f /etc/motd && sudo rm /etc/motd
# remove ssh banner for the script logo

if _disable_bluetooth; then
    cat <<EOF
${red}
***
Disabling Bluetooth...
***
${nc}
EOF
fi
# disable bluetooth, see functions.sh

if _disable_ipv6; then
    cat <<EOF
${red}
***
Disabling Ipv6...
***
${nc}
EOF
fi
# disable ipv6, see functions.sh

# Update mirrors
_pacman_update_mirrors

cat <<EOF
${red}
***
Checking package dependencies. Please wait...
***
${nc}
EOF

# Install system dependencies
for pkg in "${!package_dependencies[@]}"; do
    _check_pkg "${pkg}" "${package_dependencies[$pkg]}"
done
# install system dependencies, see defaults.sh
# websearch "bash associative array" for info

if ! pacman -Q libusb 1>/dev/null; then
    cat <<EOF
${red}
***
Installing libusb...
***
${nc}
EOF
    sudo pacman --quiet -S --noconfirm libusb
fi

if sudo ufw status | grep 22 > /dev/null ; then
    cat <<EOF
${red}
***
SSH firewall rule already setup...
***
${nc}
EOF
    _sleep
else
    cat <<EOF
${red}
***
Setting up UFW...
***
${nc}
EOF
    _sleep

    sudo ufw default deny incoming &>/dev/null
    sudo ufw default allow outgoing &>/dev/null
    # setting up uncomplicated firewall

    cat <<EOF
${red}
***
Enabling UFW...
***
${nc}
EOF
    _sleep

    sudo ufw --force enable &>/dev/null
    sudo systemctl enable --quiet ufw
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
${red}
***
Reloading UFW...
***
${nc}
EOF
    _sleep

    sudo ufw reload &>/dev/null

    cat <<EOF
${red}
***
Checking UFW status...
***
${nc}
EOF
    _sleep

    sudo ufw status

    UFW_IP=$(sudo ufw status | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
    sudo ufw allow from "$UFW_IP"/24 to any port 22 comment 'SSH access restricted to local network'
    # add comment to initial ufw rule

    cat <<EOF
${red}
***
Now that UFW is enabled, any computer connected to the same local network as your RoninDojo will have SSH access.
***
${nc}
EOF

    cat <<EOF
${red}
***
Leaving this setting default is NOT RECOMMENDED for users who are connecting to something like University, Public Internet, Etc.
***
${nc}
EOF

    cat <<EOF
${red}
***
Firewall rules can be adjusted using the RoninDojo Firewall Menu.
***
${nc}
EOF
    _sleep 10
fi

cat <<EOF
${red}
***
All Dojo dependencies installed...
***
${nc}
EOF
_sleep

cat <<EOF
${red}
***
Creating ${install_dir} directory...
***
${nc}
EOF
_sleep

test -d "${install_dir}" || sudo mkdir "${install_dir}"
# test for ${install_dir} directory, otherwise creates using mkdir
# websearch "bash Logical OR (||)" for info

if [ -b "${primary_storage}" ]; then
    cat <<EOF
${red}
***
Creating ${storage_mount} directory...
***
${nc}
EOF
    _sleep

    test ! -d "${storage_mount}" && sudo mkdir "${storage_mount}"

    cat <<EOF
${red}
***
Attempting to mount drive for Blockchain data salvage...
***
${nc}
EOF
    _sleep
    sudo mount "${primary_storage}" "${storage_mount}"
else
    cat <<EOF
${red}
***
Did not find ${primary_storage} for Blockchain data salvage.
***
${nc}
EOF
    _sleep
fi
# mount main storage drive to "${storage_mount}" directory if found in prep for data salvage

if sudo test -d "${bitcoin_ibd_backup_dir}/blocks"; then
    cat <<EOF
${red}
***
Found Blockchain data for salvage!
***
${nc}
EOF
_sleep

    # Check if swap in use
    if check_swap "${storage_mount}/swapfile"; then
        test -f "${storage_mount}/swapfile" && sudo swapoff "${storage_mount}/swapfile" &>/dev/null
    fi

    if [ -f "${storage_mount}"/swapfile ]; then
        sudo rm -rf "${storage_mount}"/{swapfile,docker,tor} &>/dev/null
    fi

    if findmnt "${storage_mount}" 1>/dev/null; then
        sudo umount "${storage_mount}"
        sudo rmdir "${storage_mount}" &>/dev/null
    fi
    # if uninstall-salvage directory is found, delete older {docker,tor} directory and swapfile

    cat <<EOF
${red}
***
Mounting drive...
***
${nc}
EOF
_sleep

    # Mount primary drive if not already mounted
    findmnt "${primary_storage}" 1>/dev/null || sudo mount "${primary_storage}" "${install_dir}"

    cat <<EOF
${red}
***
Displaying the name on the external disk...
***
${nc}
EOF
_sleep

    lsblk -o NAME,SIZE,LABEL "${primary_storage}"
    # double-check that /dev/sda exists, and that its storage capacity is what you expected

    cat <<EOF
${red}
***
Check output for ${primary_storage} and make sure everything looks ok...
***
${nc}
EOF

    df -h "${primary_storage}"
    _sleep 5
    # checks disk info

    # Calculate swapfile size
    _swap_size

    create_swap --file "${install_dir_swap}" --count "${_size}"
    # created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

    _setup_tor
    # tor configuration setup, see functions.sh

    _docker_datadir_setup
    # docker data directory setup, see functions.sh

    _create_ronin_data_dir
    # create directory to store user info, see functions.sh

    cat <<EOF
${red}
***
Dojo is ready to be installed!
***
${nc}
EOF

    # Make sure to wait for user interaction before continuing
    _pause continue

    # Make sure we don't run system install twice
    touch "${ronin_data_dir}"/system-install

    exit
else
    cat <<EOF
${red}
***
No Blockchain data found for salvage check 1...
***
${nc}
EOF
    _sleep
fi
# checks for blockchain data to salvage, if found exits this script to dojo install, and if not found continue to salvage check 2 below

if sudo test -d "${storage_mount}/${bitcoind_data_dir}/_data/blocks"; then
    if sudo test -d "${storage_mount}/${indexer_data_dir}/_data/db"; then
        _indexer_salvage=true
    else
        _indexer_salvage=false
    fi

    cat <<EOF
${red}
***
Found Blockchain data for salvage!
***
${nc}
EOF
    _sleep

    cat <<EOF
${red}
***
Moving to temporary directory...
***
${nc}
EOF
    _sleep

    test -d "${bitcoin_ibd_backup_dir}" || sudo mkdir -p "${bitcoin_ibd_backup_dir}"

    sudo mv -v "${storage_mount}/${bitcoind_data_dir}/_data/"{blocks,chainstate,indexes} "${bitcoin_ibd_backup_dir}"/ 1>/dev/null
    # moves blockchain salvage data to ${storage_mount} if found

    if "${_indexer_salvage}"; then
        test -d "${indexer_backup_dir}" || sudo mkdir -p "${indexer_backup_dir}"
        sudo mv -v "${storage_mount}/${indexer_data_dir}/_data/db" "${indexer_backup_dir}"/ 1>/dev/null
    fi

    cat <<EOF
${red}
***
Blockchain data prepared for salvage!
***
${nc}
EOF
    _sleep

    # Check if swap in use
    if check_swap "${storage_mount}/swapfile"; then
        test -f "${storage_mount}/swapfile" && sudo swapoff "${storage_mount}/swapfile" &>/dev/null
    fi

    sudo rm -rf "${storage_mount}"/{docker,tor,swapfile} &>/dev/null

    if findmnt "${storage_mount}" 1>/dev/null; then
        sudo umount "${storage_mount}"
        sudo rmdir "${storage_mount}" &>/dev/null
    fi
    # remove docker, tor, swap file directories from ${storage_mount}
    # then unmount and remove ${storage_mount}

    cat <<EOF
${red}
***
Mounting drive...
***
${nc}
EOF
    _sleep

    # Mount primary drive if not already mounted
    findmnt "${primary_storage}" 1>/dev/null || sudo mount "${primary_storage}" "${install_dir}"

    _sleep

    cat <<EOF
${red}
***
Displaying the name on the external disk...
***
${nc}
EOF
    _sleep

    lsblk -o NAME,SIZE,LABEL "${primary_storage}"
    # lsblk lists disk by device
    # double-check that ${primary_storage} exists, and its storage capacity is what you expected

    cat <<EOF
${red}
***
Check output for ${primary_storage} and make sure everything looks ok...
***
${nc}
EOF

    df -h "${primary_storage}"
    _sleep 5
    # checks disk info

    # Calculate swapfile size
    _swap_size

    create_swap --file "${install_dir_swap}" --count "${_size}"
    # created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

    _setup_tor
    # tor configuration setup, see functions.sh

    _docker_datadir_setup
    # docker data directory setup, see functions.sh

    cat <<EOF
${red}
***
Dojo is ready to be installed!
***
${nc}
EOF

    # Make sure to wait for user interaction before continuing
    _pause continue

    # Make sure we don't run system install twice
    touch "${ronin_data_dir}"/system-install

    exit
else
    cat <<EOF
${red}
***
No Blockchain data found for salvage check 2...
***
${nc}
EOF
    _sleep

    # Check if swap in use
    if check_swap "${storage_mount}/swapfile" ; then
        test -f "${storage_mount}/swapfile" && sudo swapoff "${storage_mount}/swapfile" &>/dev/null
    fi

    if findmnt "${storage_mount}" 1>/dev/null; then
        sudo umount "${storage_mount}"
        sudo rmdir "${storage_mount}"
    fi
fi
# checks for blockchain data to salvage, if found exit to dojo install, and if not found continue to format drive

cat <<EOF
${red}
***
Formatting the SSD...
***
${nc}
EOF
_sleep 5

if ! create_fs --label "main" --device "${primary_storage}" --mountpoint "${install_dir}"; then
    printf "\n %sFilesystem creation failed! Exiting now...%s" "${red}" "${nc}"
    _sleep 3
    exit 1
fi
# create a partition table with a single partition that takes the whole disk
# format partition

cat <<EOF
${red}
***
Displaying the name on the external disk...
***
${nc}
EOF
_sleep

lsblk -o NAME,SIZE,LABEL "${primary_storage}"
# double-check that ${primary_storage} exists, and its storage capacity is what you expected

cat <<EOF
${red}
***
Check output for ${primary_storage} and make sure everything looks ok...
***
${nc}
EOF

df -h "${primary_storage}"
_sleep 5
# checks disk info

# Calculate swapfile size
_swap_size

create_swap --file "${install_dir_swap}" --count "${_size}"
# created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

_setup_tor
# tor configuration setup, see functions.sh

_docker_datadir_setup
# docker data directory setup, see functions.sh

cat <<EOF
${red}
***
Installing SW Toolkit...
***
${nc}
EOF
_sleep

cat <<EOF
${red}
***
Installing Boltzmann Calculator...
***
${nc}
EOF
_sleep

_install_boltzmann
# install Boltzmann

cat <<EOF
${red}
***
Installing Whirlpool Stat Tool...
***
${nc}
EOF
_sleep

_install_wst

cat <<EOF
${red}
***
Dojo is ready to be installed!
***
${nc}
EOF

# Make sure to wait for user interaction before continuing
_pause continue

# Make sure we don't run system install twice
touch "${ronin_data_dir}"/system-install

# will continue to dojo install if it was selected on the install menu