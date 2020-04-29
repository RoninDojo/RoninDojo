#!/bin/bash

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
sudo rm -rf /etc/motd
# remove ssh banner for the script logo

if [ -f /boot/cmdline.txt ]; then
  echo -e "${RED}"
  echo "***"
  echo "Disabling Ipv6 for Raspberry Pi4..."
  echo "***"
  echo -e "${NC}"
  cat /boot/cmdline.txt > ~/cmdline.txt
  sudo sed -i '/^root=/s/$/ ipv6.disable=1/' ~/cmdline.txt
  sudo chown root:root ~/cmdline.txt
  sudo chmod 755 ~/cmdline.txt
  sudo mv ~/cmdline.txt /boot/cmdline.txt
  sleep 2s
else
  echo -e "${RED}"
  echo "***"
  echo "Disabling Ipv6 for Odroid N2..."
  echo "***"
  echo -e "${NC}"
  cat /boot/boot.ini > ~/boot.ini
  sudo sed -i '/^setenv bootargs/s/$/ ipv6.disable=1/' ~/boot.ini
  sudo chown root:root ~/boot.ini
  sudo chmod 755 ~/boot.ini
  sudo mv ~/boot.ini /boot/boot.ini
  sleep 2s
fi
# disable ipv6
# chmod and chown to avoid errors when moving from ~ to ~/boot
# /boot/cmdline.txt file will only be there if it's a Raspberry Pi
# /boot/boot.ini is for Odroid N2

if [ ! -f /usr/local/bin/ronin ]; then
  sudo cp ~/RoninDojo/ronin /usr/local/bin/ronin
  cat << EOF >> ~/.bashrc
~/RoninDojo/Scripts/.logo

~/RoninDojo/ronin
EOF
fi
# place main ronin menu script under /usr/local/bin folder, because most likely that will be path already added to your $PATH variable
# place logo and ronin main menu script ~/.bashrc to run at each login

sudo chmod +x ~/RoninDojo/Scripts/Install/*
sudo chmod +x ~/RoninDojo/Scripts/Menu/*

if find_pkg jdk11-openjdk; then
  echo -e "${RED}"
  echo "***"
  echo "Java already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Java..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm jdk11-openjdk
fi
# installs java jdk11-openjdk
# in had to use '' and "" for the check to work correctly
# single quotes won't interpolate anything, but double quotes will

if find_pkg tor; then
    echo -e "${RED}"
    echo "***"
    echo "Tor already installed..."
    echo "***"
    echo -e "${NC}"
    sleep 1s
else
    echo -e "${RED}"
    echo "***"
    echo "Installing Tor..."
    echo "***"
    echo -e "${NC}"
    sudo pacman -S --noconfirm tor
    sleep 1s
    sudo sed -i '52d' /etc/tor/torrc
    sudo sed -i '52i DataDirectory /mnt/usb/tor' /etc/tor/torrc
    sudo sed -i '56d' /etc/tor/torrc
    sudo sed -i '56i ControlPort 9051' /etc/tor/torrc
    sudo sed -i '60d' /etc/tor/torrc
    sudo sed -i '60i CookieAuthentication 1' /etc/tor/torrc
    sudo sed -i '61i CookieAuthFileGroupReadable 1' /etc/tor/torrc
fi
# check if tor is installed, if not install and modify torrc

if find_pkg python; then
  echo -e "${RED}"
  echo "***"
  echo "Python3 already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Python3..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm python3
fi
# checks for python, if python not found then it is installed
# in had to use '' and "" for the check to work correctly
# single quotes won't interpolate anything, but double quotes will

if find_pkg fail2ban; then
  echo -e "${RED}"
  echo "***"
  echo "Fail2ban already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Fail2ban..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm fail2ban
fi
# check for / install fail2ban

check6=htop
if find_pkg htop; then
  echo -e "${RED}"
  echo "***"
  echo "Htop already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Htop..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm htop
fi
# check for / install htop

if find_pkg vim; then
  echo -e "${RED}"
  echo "***"
  echo "Vim already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Vim..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm vim
fi
# check for / install vim

if find_pkg unzip; then
  echo -e "${RED}"
  echo "***"
  echo "Unzip already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Unzip..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm unzip
fi
# check for / install unzip

if find_pkg net-tools; then
  echo -e "${RED}"
  echo "***"
  echo "Net-tools already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Net-tools..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm net-tools
fi
# check for / install net tools

if find_pkg which; then
  echo -e "${RED}"
  echo "***"
  echo "Which already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Which..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm which
fi
# check for / install which

if find_pkg wget; then
  echo -e "${RED}"
  echo "***"
  echo "Wget already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Wget..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm wget
fi
# check for / install wget

if find_pkg docker; then
  echo -e "${RED}"
  echo "***"
  echo "Docker already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Docker..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm docker
fi
# check for / install docker

if find_pkg docker-compose; then
  echo -e "${RED}"
  echo "***"
  echo "Docker-compose already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Docker-compose..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm docker-compose
fi
# check for / install docker

sudo systemctl enable docker
# enables docker to run at startup
# system setup ends

if find_pkg ufw; then
  echo -e "${RED}"
  echo "***"
  echo "Ufw already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Ufw..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm ufw
fi
# check for / install ufw

if sudo ufw status | grep 22 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Ssh firewall rule already setup..."
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

  while read ip ; do echo "### tuple ### allow any 22 0.0.0.0/0 any ""$ip" > ~/rule_tmp.txt; done <~/ip_tmp.txt 
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 19 in /etc/ufw/user.rules

  while read ip ; do echo "-A ufw-user-input -p tcp --dport 22 -s "$ip" -j ACCEPT" >> ~/rule_tmp.txt; done <~/ip_tmp.txt
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 20 /etc/ufw/user.rules

  while read ip ; do echo "-A ufw-user-input -p udp --dport 22 -s "$ip" -j ACCEPT" >> ~/rule_tmp.txt; done <~/ip_tmp.txt
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 21 /etc/ufw/user.rules

  sudo awk 'NR==1{a=$0}NR==FNR{next}FNR==19{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 1 in rule_tmp.txt to line 19 in /etc/ufw/user.rules
  # using awk to get /lib/ufw/user.rules output, including newly added values, then makes a tmp file
  # after temp file is made it is mv to /lib/ufw/user.rules
  # awk does not have -i to write changes like sed does, that's why I took this approach

  sudo awk 'NR==2{a=$0}NR==FNR{next}FNR==20{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 2 in rule_tmp.txt to line 20 in /etc/ufw/user.rules

  sudo awk 'NR==3{a=$0}NR==FNR{next}FNR==21{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
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

if [ -d /mnt/salvage/uninstall-salvage ]; then
  echo -e "${RED}"
  echo "***"
  echo "Found Blockchain data for salvage!"
  echo "***"
  echo -e "${NC}"
  sudo rm -rf /mnt/salvage/{swapfile,docker}
  sudo umount -l /dev/sda1
  sleep 5s
  sudo rm -rf /mnt/salvage
  # if uninstall-salvage directory is found, delete older docker directory and swapfile, then unmount sda1

  echo -e "${RED}"
  echo "***"
  echo "Editing /etc/fstab to input UUID for sda1 and adjust settings..."
  echo "***"
  echo -e "${NC}"
  sleep 2s

  uuid=$(lsblk -no UUID /dev/sda1)
  fstype=$(check_fstype /dev/sda1)

  # this will look up uuid of sdb1

  if ! grep '${uuid}' /etc/fstab; then
    sudo bash -c 'cat <<EOF >>/etc/fstab
UUID=${uuid} /mnt/usb ${fstype} rw,nosuid,dev,noexec,noatime,nodiratime,noauto,x-systemd.automount,nouser,async,nofail 0 2
EOF'
  fi
  # adds a necessary line in /etc/fstab
  # noauto and x-systemd.automount options are important so external drive is found properly by docker
  # otherwise docker may cause problems by writing to SD card instead

  echo -e "${RED}"
  echo "***"
  echo "Creating /mnt/usb directory..."
  echo "***"
  echo -e "${NC}"
  sudo mkdir /mnt/usb
  sleep 2s

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

  sudo create_swap --file /mnt/usb/swapfile --size 2G
  # created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

  echo -e "${RED}"
  echo "***"
  echo "Configuring docker to use the external drive..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo mkdir /mnt/usb/docker
  # makes directroy to store docker/dojo data

  echo -e "${RED}"
  echo "***"
  echo "Creating /etc/docker directory..."
  echo "***"
  echo -e "${NC}"
  sudo mkdir /etc/docker
  # makes docker directory

sudo bash -c 'cat << EOF > /etc/docker/daemon.json
{
  "data-root": "/mnt/usb/docker"
}
EOF'

  echo -e "${RED}"
  echo "***"
  echo "Checking docker version..."
  echo "***"
  echo -e "${NC}"
  docker -v
  sleep 2s

  echo -e "${RED}"
  echo "***"
  echo "Restarting docker..."
  echo "***"
  echo -e "${NC}"
  sudo systemctl stop docker
  sleep 15s
  sudo systemctl daemon-reload
  sleep 5s
  sudo systemctl start docker
  sleep 10s
  sudo systemctl enable docker
  # sleep here to avoid error systemd[1]: Failed to start Docker Application Container Engine
  # see systemctl status docker.service and journalctl -xe for details on error

  echo -e "${RED}"
  echo "***"
  echo "Check that docker is using the external drive."
  echo "***"
  echo -e "${NC}"
  sudo docker info | grep "Docker Root Dir:"
  sleep 3s
  # if not showing SSD path check above
  # docker setup ends

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

if [ -d /mnt/salvage/docker/volumes/my-dojo_data-bitcoind/_data/blocks ]; then
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
  sudo mkdir /mnt/salvage/system-setup-salvage/
  sudo mv -v /mnt/salvage/docker/volumes/my-dojo_data-bitcoind/_data/{blocks,chainstate} /mnt/salvage/system-setup-salvage/
  echo -e "${RED}"
  echo "***"
  echo "Blockchain data prepared for salvage!"
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo rm -rf /mnt/salvage/docker
  sudo rm -f /mnt/salvage/swapfile
  sudo umount -l /mnt/salvage
  sleep 3s
  sudo rm -rf /mnt/salvage
  # copies blockchain salvage data to /mnt/salvage if found

  echo -e "${RED}"
  echo "***"
  echo "Editing /etc/fstab to input UUID for sda1 and adjust settings..."
  echo "***"
  echo -e "${NC}"
  sleep 2s

  # /etc/fstab changes
  uuid=$(lsblk -no UUID /dev/sda1)
  fstype=$(check_fstype /dev/sda1)

  # adds a necessary line in /etc/fstab
  # noauto and x-systemd.automount options are important so external drive is found properly by docker
  # otherwise docker may cause problems by writing to SD card instead
  if ! grep "${uuid}" /etc/fstab; then
      cat <<EOF
$(echo -e ${(tput setaf 1)})
***
Editing /etc/fstab to input UUID for /dev/sda1 and adjust settings...
***
$(echo -e $(tput sgr0))
EOF
      sudo bash -c 'cat <<EOF >>/etc/fstab
UUID=${uuid} /mnt/usb ${fstype} rw,nosuid,dev,noexec,noatime,nodiratime,noauto,x-systemd.automount,nouser,async,nofail 0 2
EOF'
  fi

  echo -e "${RED}"
  echo "***"
  echo "Creating /mnt/usb directory..."
  echo "***"
  echo -e "${NC}"
  sudo mkdir /mnt/usb
  sleep 2s

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

  sudo create_swap --file /mnt/usb/swapfile --size 2G
  # created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

  echo -e "${RED}"
  echo "***"
  echo "Now configuring docker to use the external drive..."
  echo "***"
  echo -e "${NC}"
  sleep 3s
  sudo mkdir /mnt/usb/docker
  # makes directroy to store docker/dojo data

  echo -e "${RED}"
  echo "***"
  echo "Creating /etc/docker directory..."
  echo "***"
  echo -e "${NC}"
  sudo mkdir /etc/docker
  # makes docker directory

sudo bash -c 'cat << EOF > /etc/docker/daemon.json
{
  "data-root": "/mnt/usb/docker"
}
EOF'

  echo -e "${RED}"
  echo "***"
  echo "Checking docker version..."
  echo "***"
  echo -e "${NC}"
  docker -v
  sleep 2s

  echo -e "${RED}"
  echo "***"
  echo "Restarting docker..."
  echo "***"
  echo -e "${NC}"
  sudo systemctl stop docker
  sleep 15s
  sudo systemctl daemon-reload
  sleep 5s
  sudo systemctl start docker
  sleep 10s
  sudo systemctl enable docker
  # sleep here to avoid error systemd[1]: Failed to start Docker Application Container Engine
  # see systemctl status docker.service and journalctl -xe for details on error

  echo -e "${RED}"
  echo "***"
  echo "Check that docker is using the external drive."
  echo "***"
  echo -e "${NC}"
  sudo docker info | grep "Docker Root Dir:"
  sleep 3s
  # if not showing SSD path check above
  # docker setup ends

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

  sudo umount -l /dev/sda1
  sleep 5s
  sudo rm -rf /mnt/salvage
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
  echo "Found sda1, using wipefs."
  sudo wipefs --all --force /dev/sda1
fi
# if sda1 exists, use wipefs to erase possible sig

sudo sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk /dev/sda
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk
    # default, extend partition to end of disk
  w # write the partition table
EOF
# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.

sudo create_fs --label "main" --device "/dev/sda1" --mountpoint "/mnt/usb"
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

sudo create_swap --file /mnt/usb/swapfile --size 2G
# created a 2GB swapfile on the external drive instead of sd card to preserve sd card life

echo -e "${RED}"
echo "***"
echo "Creating Tor directory on the external SSD..."
echo "***"
echo -e "${NC}"
sleep 3s
sudo mkdir /mnt/usb/tor/
sudo chown -R tor:tor /mnt/usb/tor/

echo -e "${RED}"
echo "***"
echo "Now configuring docker to use the external SSD..."
echo "***"
echo -e "${NC}"
sleep 3s
sudo mkdir /mnt/usb/docker
# makes directroy to store docker/dojo data

if [ -d /etc/docker ]; then
  echo -e "${RED}"
  echo "***"
  echo "The /etc/docker directory already exists..."
  echo "***"
  echo -e "${NC}"
else
  echo -e "${RED}"
  echo "***"
  echo "Creating /etc/docker directory..."
  echo "***"
  echo -e "${NC}"
  sudo mkdir /etc/docker
  # makes docker directory
fi

sudo echo "{" > ~/daemon.json
sudo echo '                  "data-root": "/mnt/usb/docker"' >> ~/daemon.json
sudo echo "}" >> ~/daemon.json
# using echo > to create file with first line, then using echo >> to append following two lines

cat ~/daemon.json | sudo tee -a /etc/docker/daemon.json > /dev/null
# even with sudo cant get permission to pipe cat output into /etc/fstab, so using sudo tee -a

rm ~/daemon.json
# removes temp file

echo -e "${RED}"
echo "***"
echo "Checking docker version..."
echo "***"
echo -e "${NC}"
docker -v
sleep 3s

echo -e "${RED}"
echo "***"
echo "Restarting docker..."
echo "***"
echo -e "${NC}"
sudo systemctl stop docker
sleep 15s
sudo systemctl daemon-reload
sleep 5s
sudo systemctl start docker
sleep 10s
sudo systemctl enable docker
# sleep here to avoid error systemd[1]: Failed to start Docker Application Container Engine
# see systemctl status docker.service and journalctl -xe for details on error

echo -e "${RED}"
echo "***"
echo "Check that docker is using the external drive."
echo "***"
echo -e "${NC}"
sudo docker info | grep "Docker Root Dir:"
sleep 3s
# if not showing SSD path check above
# docker setup ends

echo -e "${RED}"
echo "***"
echo "Dojo is ready to be installed!"
echo "***"
echo -e "${NC}"
sleep 3s
# will continue to dojo install if it was selected on the install menu