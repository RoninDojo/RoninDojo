#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

if ls ~ | grep dojo > /dev/null ; then
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

echo -e "${NC}"
echo " _____________________________________________________|_._._._._._._._._, "
echo " \____________________________________________________|_|_|_|_|_|_|_|_|_| "
echo "                                                      !                   "
echo -e "${RED}"
echo " I dreamt of        ______            _          _   _ _                  "
echo "   worldly success  | ___ \          (_)        | | | (_)                 "
echo "               once.| |_/ /___  _ __  _ _ __    | | | |_|                 "
echo "                    |    // _ \| '_ \| | '_ \   | | | | |                 "
echo "                    | |\ \ (_) | | | | | | | |  | |_| | |                 "
echo "                    \_| \_\___/|_| |_|_|_| |_|by\____/|_|                 "
echo "                                              @GuerraMoneta               "
echo -e "                                            & @BTCxZelko          ${NC}"
echo " ,_._._._._._._._._|_____________________________________________________ "
echo " |_|_|_|_|_|_|_|_|_|____________________________________________________/ "
echo "                   !                                                      "
echo -e "${NC}"
sleep 5s

# system setup starts
sudo rm -rf /etc/motd
# remove ssh banner for the script logo

check1=ronin
if ls /usr/local/bin | grep $check1 > /dev/null ; then
  echo ""
else
  sudo cp ~/RoninDojo/ronin /usr/local/bin
  echo "" >> ~/.bashrc
  echo "~/RoninDojo/Scripts/.logo" >> ~/.bashrc
  echo "" >> ~/.bashrc
  echo "~/RoninDojo/ronin" >> ~/.bashrc
fi
# place main ronin menu  script under /usr/local/bin folder, because most likely that will be path already added to your $PATH variable
# place logo and ronin main menu script ~/.bashrc to run at each login

sudo chmod +x ~/RoninDojo/Scripts/Install/*
sudo chmod +x ~/RoninDojo/Scripts/Menu/*

check2=jdk11-openjdk
if pacman -Ql | grep $check2 > /dev/null ; then
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

check3=/usr/bin/tor
if pacman -Ql | grep $check3  > /dev/null ; then
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
    sudo mkdir /mnt/usb/tor/
    sudo chown -R tor:tor /mnt/usb/tor/
fi
# check if tor is installed, if not install and modify torrc

check4=python3
if pacman -Qs $check4 > /dev/null ; then
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

echo -e "${RED}"
echo "***"
echo "Showing version... "
echo "***"
echo -e "${NC}"
python3 --version
sleep 3s

check5=fail2ban
if pacman -Qs $check5 > /dev/null ; then
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
if pacman -Qs $check6 > /dev/null ; then
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

check7=vim
if pacman -Qs $check7 > /dev/null ; then
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

check8=unzip
if pacman -Qs $check8 > /dev/null ; then
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

check9=net-tools
if pacman -Qs $check9 > /dev/null ; then
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

check10=/usr/bin/which
if sudo pacman -Ql | grep $check10 > /dev/null ; then
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

check11=wget
if pacman -Qs $check11 > /dev/null ; then
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

check12=docker
if pacman -Qs $check12 > /dev/null ; then
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

check13=docker-compose
if pacman -Qs $check13 > /dev/null ; then
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

check14=ufw
if pacman -Qs $check14 > /dev/null ; then
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

  cat ~/ip_tmp.txt | while read ip ; do echo "### tuple ### allow any 22 0.0.0.0/0 any ""$ip" > ~/rule_tmp.txt; done
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 19 in /etc/ufw/user.rules

  cat ~/ip_tmp.txt | while read ip ; do echo "-A ufw-user-input -p tcp --dport 22 -s "$ip" -j ACCEPT" >> ~/rule_tmp.txt; done
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 20 /etc/ufw/user.rules

  cat ~/ip_tmp.txt | while read ip ; do echo "-A ufw-user-input -p udp --dport 22 -s "$ip" -j ACCEPT" >> ~/rule_tmp.txt; done
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

  echo -e "${RED}"
  echo "***"
  echo "Take a moment to check the UFW rule that was just created."
  echo "***"
  echo -e "${NC}"
  sleep 5s

  echo -e "${RED}"
  echo "***"
  echo "Any computer connected to the same local network as your Dojo will have SSH access."
  echo "***"
  echo -e "${NC}"
  sleep 2s

  echo -e "${RED}"
  echo "***"
  echo "Additional local network SSH access will have to done manually using the Firewall Menu."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  # ufw setup ends
fi

echo -e "${RED}"
echo "***"
echo "All Dojo dependencies installed..."
echo "***"
echo -e "${NC}"
sleep 3s

ls /dev | grep sda > ~/sda_tmp.txt
# temp file, looking for sda1

if grep "sda1" ~/sda_tmp.txt > /dev/null ; then
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
fi
# mount main storage drive to /mnt/salvage directory if found in prep for data salvage

rm -f ~/sda_tmp.txt

if sudo ls /mnt/salvage | grep uninstall-salvage > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Found Blockchain data for salvage!"
  echo "***"
  echo -e "${NC}"
  sudo rm -rf /mnt/salvage/docker
  sudo rm -f /mnt/salvage/swapfile
  sudo umount -l /dev/sda1
  sleep 5s
  sudo rm -rf /mnt/salvage
  # if uninstall-salvage is found, delete older docker directory and swapfile, then unmount sda1

  echo -e "${RED}"
  echo "***"
  echo "Editing /etc/fstab to input UUID for sda1 and adjust settings..."
  echo "***"
  echo -e "${NC}"
  sleep 2s

  lsblk -o UUID,NAME | grep sda1 >> ~/uuid.txt
  # this will look up uuid of sda1 and makes txt file with that value

  sed -i 's/ └─sda1//g' ~/uuid.txt
  # removes the text sda1 after the uuid in txt file

  sed -i 1's|$| /mnt/usb ext4 rw,nosuid,dev,noexec,noatime,nodiratime,noauto,x-systemd.automount,nouser,async,nofail 0 2 &|' ~/uuid.txt
  # adds a necessary line with the path and other options after the uuid in txt file

  sed -i 's/^/UUID=/' ~/uuid.txt
  # adds UUID= prefix to the front of the line

  cat ~/uuid.txt | sudo tee -a /etc/fstab > /dev/null
  # even with sudo cant get permission to pipe cat output into /etc/fstab, so using sudo tee -a

  rm ~/uuid.txt
  # delete txt file

  echo -e "${RED}"
  echo "***"
  echo "Creating /mnt/usb directory..."
  echo "***"
  echo -e "${NC}"
  sudo mkdir /mnt/usb

  echo -e "${RED}"
  echo "***"
  echo "Mounting drive..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo mount /dev/sda1 /mnt/usb
  # mount main storage drive to /mnt/usb directory

  echo -e "${RED}"
  echo "***"
  echo "Displaying the name on the external disk..."
  echo "***"
  echo -e "${NC}"
  lsblk -o UUID,NAME,FSTYPE,SIZE,LABEL,MODEL
  sleep 2s
  # double-check that /dev/sda exists, and that its storage capacity is what you expected

  echo -e "${RED}"
  echo "***"
  echo "Check output for /dev/sda1 and make sure everything looks ok."
  echo "***"
  echo -e "${NC}"
  df -h
  sleep 2s
  # checks disk info

  echo -e "${RED}"
  echo "***"
  echo "Creating swapfile..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo fallocate -l 1G /mnt/usb/swapfile
  sudo chmod 600 /mnt/usb/swapfile
  sudo mkswap /mnt/usb/swapfile
  sudo swapon /mnt/usb/swapfile
  sudo sed -i '20i /swapfile none swap defaults 0 0' /etc/fstab
  # created a 1GB swapfile on the external drive instead of sd card to preserve sd card life

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

  sudo echo "{" > ~/daemon.json
  sudo echo '                  "data-root": "/mnt/usb/docker"' >> ~/daemon.json
  sudo echo "}" >> ~/daemon.json
  # using echo > to create file with first line, then using echo >> to append following two lines

  cat ~/daemon.json | sudo tee -a /etc/docker/daemon.json > /dev/null
  # even with sudo cant get permission to pipe cat output into /etc/docker, so using sudo tee -a

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
  exit
else
  echo -e "${RED}"
  echo "***"
  echo "No Blockchain data found for salvage check 1..."
  echo "***"
  echo -e "${NC}"
  sleep 3s
fi
# checks for blockchain data to salvage, if found continue to dojo install, and if not found continue to salvage check 2

if sudo ls /mnt/salvage/docker/volumes/my-dojo_data-bitcoind/_data/ | grep blocks > /dev/null ; then
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
  sleep 2s
  sudo mkdir /mnt/salvage/system-setup-salvage/
  sudo mv -v /mnt/salvage/docker/volumes/my-dojo_data-bitcoind/_data/chainstate/ /mnt/salvage/system-setup-salvage/
  sudo mv -v /mnt/salvage/docker/volumes/my-dojo_data-bitcoind/_data/blocks/ /mnt/salvage/system-setup-salvage/
  echo -e "${RED}"
  echo "***"
  echo "Blockchain data prepared for salvage!"
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo rm -rf /mnt/salvage/docker
  sudo rm -f /mnt/salvage/swapfile
  sudo umount -l /dev/sda1
  sleep 3s
  sudo rm -rf /mnt/salvage
  # copies blockchain salvage data to /mnt/salvage if found

  echo -e "${RED}"
  echo "***"
  echo "Editing /etc/fstab to input UUID for sda1 and adjust settings..."
  echo "***"
  echo -e "${NC}"
  sleep 2s

  lsblk -o UUID,NAME | grep sda1 >> ~/uuid.txt
  # this will look up uuid of sda1 and makes txt file with that value

  sed -i 's/ └─sda1//g' ~/uuid.txt
  # removes the text sda1 after the uuid in txt file

  sed -i 1's|$| /mnt/usb ext4 rw,nosuid,dev,noexec,noatime,nodiratime,noauto,x-systemd.automount,nouser,async,nofail 0 2 &|' ~/uuid.txt
  # adds a necessary line with the path and other options after the uuid in txt file

  sed -i 's/^/UUID=/' ~/uuid.txt
  # adds UUID= prefix to the front of the line

  cat ~/uuid.txt | sudo tee -a /etc/fstab > /dev/null
  # even with sudo cant get permission to pipe cat output into /etc/fstab, so using sudo tee -a

  rm ~/uuid.txt
  # delete txt file

  echo -e "${RED}"
  echo "***"
  echo "Creating /mnt/usb directory..."
  echo "***"
  echo -e "${NC}"
  sudo mkdir /mnt/usb

  echo -e "${RED}"
  echo "***"
  echo "Mounting drive..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo mount /dev/sda1 /mnt/usb
  # mount main storage drive to /mnt/usb directory

  echo -e "${RED}"
  echo "***"
  echo "Displaying the name on the external disk..."
  echo "***"
  echo -e "${NC}"
  lsblk -o UUID,NAME,FSTYPE,SIZE,LABEL,MODEL
  sleep 2s
  # double-check that /dev/sda exists, and that its storage capacity is what you expected

  echo -e "${RED}"
  echo "***"
  echo "Check output for /dev/sda1 and make sure everything looks ok."
  echo "***"
  echo -e "${NC}"
  df -h
  sleep 2s
  # checks disk info

  echo -e "${RED}"
  echo "***"
  echo "Creating swapfile..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo fallocate -l 1G /mnt/usb/swapfile
  sudo chmod 600 /mnt/usb/swapfile
  sudo mkswap /mnt/usb/swapfile
  sudo swapon /mnt/usb/swapfile
  sudo sed -i '20i /swapfile none swap defaults 0 0' /etc/fstab
  # created a 1GB swapfile on the external drive instead of sd card to preserve sd card life

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

  sudo echo "{" > ~/daemon.json
  sudo echo '                  "data-root": "/mnt/usb/docker"' >> ~/daemon.json
  sudo echo "}" >> ~/daemon.json
  # using echo > to create file with first line, then using echo >> to append following two lines

  cat ~/daemon.json | sudo tee -a /etc/docker/daemon.json > /dev/null
  # even with sudo cant get permission to pipe cat output into /etc/docker, so using sudo tee -a

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

ls /dev | grep sda > ~/sda_tmp.txt
# temp file looking for sda

check15=$( grep -ic "sda1" ~/sda_tmp.txt )
if [ $check15 -eq 1 ]
then
  echo "Found sda1, using wipefs."
  sudo wipefs --all --force /dev/sda1
fi
# if sda1 exists, use wipefs to erase possible sig

rm ~/sda_tmp.txt
# remove temp file

sudo dd if=/dev/zero of=/dev/sda bs=512 count=1 conv=notrunc
# wipes partition table

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

echo -e "${RED}"
echo "***"
echo "Using ext4 format for /dev/sda1 partition..."
echo "***"
echo -e "${NC}"
sleep 2s
# format partition1 to ext4
# https://linux.die.net/man/8/mkfs.ext4:
# -F: Force mke2fs to create a filesystem, even if the specified
# device is not a partition on a block special device.
sudo mkfs.ext4 -F /dev/sda1

echo -e "${RED}"
echo "***"
echo "Editing /etc/fstab to input UUID for sda1 and adjust settings..."
echo "***"
echo -e "${NC}"
sleep 2s

lsblk -o UUID,NAME | grep sda1 >> ~/uuid.txt
# this will look up uuid of sda1 and makes txt file with that value

sed -i 's/ └─sda1//g' ~/uuid.txt
# removes the text sda1 after the uuid in txt file

sed -i 1's|$| /mnt/usb ext4 rw,nosuid,dev,noexec,noatime,nodiratime,noauto,x-systemd.automount,nouser,async,nofail 0 2 &|' ~/uuid.txt
# adds a necessary line with the path and other options after the uuid in txt file

sed -i 's/^/UUID=/' ~/uuid.txt
# adds UUID= prefix to the front of the line

cat ~/uuid.txt | sudo tee -a /etc/fstab > /dev/null
# even with sudo cant get permission to pipe cat output into /etc/fstab, so using sudo tee -a

rm ~/uuid.txt
# delete txt file

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
# mount main storage drive to /mnt/usb directory

echo -e "${RED}"
echo "***"
echo "Displaying the name on the external disk..."
echo "***"
echo -e "${NC}"
lsblk -o UUID,NAME,FSTYPE,SIZE,LABEL,MODEL
sleep 2s
# double-check that /dev/sda exists, and that its storage capacity is what you expected

echo -e "${RED}"
echo "***"
echo "Check output for /dev/sda1 and make sure everything looks ok."
echo "***"
echo -e "${NC}"
df -h
sleep 2s
# checks disk info

check16=swapfile
if ls /mnt/usb | grep $check16 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Swapfile already created..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Creating swapfile..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo fallocate -l 1G /mnt/usb/swapfile
  sudo chmod 600 /mnt/usb/swapfile
  sudo mkswap /mnt/usb/swapfile
  sudo swapon /mnt/usb/swapfile
  sudo sed -i '20i /swapfile none swap defaults 0 0' /etc/fstab
fi
# created a 1GB swapfile on the external drive instead of sd card to preserve sd card life

echo -e "${RED}"
echo "***"
echo "Now configuring docker to use the external SSD..."
echo "***"
echo -e "${NC}"
sleep 3s
sudo mkdir /mnt/usb/docker
# makes directroy to store docker/dojo data

if ls /etc | grep docker  > /dev/null ; then
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
