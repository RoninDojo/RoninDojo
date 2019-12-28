#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

echo -e "${RED}"
echo "***"
echo "Setting up system and installing Dependencies in 30s..."
echo "***"
echo -e "${NC}"
sleep 5s

echo -e "${RED}"
echo "***"
echo "If you have already setup your system, use Ctrl+C to exit now!"
echo "***"
echo -e "${NC}"
sleep 10s

echo -e "${RED}"
echo "***"
echo "WARNING: You might bork your system if you have already run this setup!!!"
echo "***"
echo -e "${NC}"
sleep 10s

echo -e "${RED}"
echo "***"
echo "If you are a new user sit back, relax, and enjoy."
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

sudo cp ~/RoninDojo/ronin /usr/local/bin
# place it main ronin scriptunder /usr/local/bin folder, because most likely that will be path already added to your $PATH variable

echo "" >> ~/.bashrc
echo "~/RoninDojo/Scripts/.logo" >> ~/.bashrc
echo "" >> ~/.bashrc
echo "~/RoninDojo/ronin" >> ~/.bashrc
# place logo and ronin main menu script ~/.bashrc to run at each login

sudo chmod +x ~/RoninDojo/Scripts/Install/*
sudo chmod +x ~/RoninDojo/Scripts/Menu/*

echo -e "${RED}"
echo "***"
echo "Formatting the SSD..."
echo "***"
echo -e "${NC}"
sleep 2s

ls /dev | grep sda > ~/sda_tmp.txt
# temp file looking for sda

sda1=$( grep -ic "sda1" ~/sda_tmp.txt )
if [ $sda1 -eq 1 ]
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
sudo mkfs.ext4 /dev/sda1
# format partion1 to ext4

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

sed -i 1's|$| /mnt/usb ext4 rw,nosuid,dev,noexec,noatime,nodiratime,auto,nouser,async,nofail 0 2 &|' ~/uuid.txt
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
echo "Mounting all drives..."
echo "***"
echo -e "${NC}"
sleep 2s
sudo mount -a
# mount all drives

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
echo "Checking for Python... "
echo "***"
echo -e "${NC}"
sleep 2s
python3 --version

package=python3
if pacman -Qs $package > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "The package $package is installed."
  echo "***"
  echo -e "${NC}"
else
  echo -e "${RED}"
  echo "***"
  echo "The package $package will be installed now."
  echo "***"
  echo -e "${NC}"
  sudo pacman -Syu --noconfirm python3
fi
# checks for python, if python not found then it is installed

echo -e "${RED}"
echo "***"
echo "Installing ufw, fail2ban, htop, docker, docker-compose, vim, unzip, net-tools, which, wget and others recommended."
echo "***"
echo -e "${NC}"
sleep 2s
sudo pacman -Syu --noconfirm ufw fail2ban htop docker docker-compose vim unzip net-tools which wget

sudo systemctl enable docker
# enables docker to run at startup
# system setup ends

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

# docker setup starts

echo -e "${RED}"
echo "***"
echo "Now configuring docker to use the external SSD..."
echo "***"
echo -e "${NC}"
sleep 3s
sudo mkdir /mnt/usb/docker
# makes directroy to store docker/dojo data

sudo mkdir /etc/docker
# makes docker directory, or gives error if already exists to verify

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
echo "Check that docker is using the SSD."
echo "***"
echo -e "${NC}"
sleep 3s
sudo docker info | grep "Docker Root Dir:"
sleep 3s
# if not showing SSD path check above
# docker setup ends
echo -e "${RED}"
echo "***"
echo ""Dependencies installed!""
echo ""Install Dojo next!""
echo "***"
echo -e "${NC}"
#end
