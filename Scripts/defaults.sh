#!/bin/bash
# shellcheck disable=SC2034

#
# Package dependencies associative array
#
declare -A package_dependencies=(
    [java]=jdk11-openjdk
    [tor]=tor
    [python3]=python3
    [fail2ban-python]=fail2ban
    [ifconfig]=net-tools
    [htop]=htop
    [vim]=vim
    [unzip]=unzip
    [which]=which
    [wget]=wget
    [docker]=docker
    [docker-compose]=docker-compose
    [ufw]=ufw
    [rsync]=rsync
    [npm]=npm
    [node]=nodejs
)

#
# Dialog Variables
#
HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="RoninDojo"
MENU="Choose one of the following menu options:"

# RoninDojo Menu Paths
RONIN_DOJO_MENU="$HOME/RoninDojo/Scripts/Menu/menu-dojo.sh"
RONIN_DOJO_MENU2="$HOME/RoninDojo/Scripts/Menu/menu-dojo2.sh"
RONIN_WHIRLPOOL_MENU="$HOME/RoninDojo/Scripts/Menu/menu-whirlpool.sh"
RONIN_BACKEND_UI_MENU="$HOME/RoninDojo/Scripts/Menu/menu-backend-ui.sh"

#
# Terminal Colors
#
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0) # No Color

#
# Install Defaults
#
DOJO_PATH="$HOME/dojo/docker/my-dojo"
RONIN_DOJO_BRANCH="" # defaults to master
BACKEND_DIR="$HOME/RoninBackend"
SAMOURAI_REPO='https://code.samourai.io/ronindojo/samourai-dojo.git'
SAMOURAI_COMMITISH="v1.7.0" # empty defaults to master

#
# Filesystem Defaults
#
PRIMARY_STORAGE="/dev/sda1"
SECONDARY_STORAGE="/dev/sdb1"
SECONDARY_STORAGE_MOUNT="/mnt/backup"

INSTALL_DIR="/mnt/usb"
INSTALL_DIR_TOR="${INSTALL_DIR}/tor"
INSTALL_DIR_SWAP="${INSTALL_DIR}/swapfile"
INSTALL_DIR_UNINSTALL="${INSTALL_DIR}/bitcoin"
INSTALL_DIR_DOCKER="${INSTALL_DIR}/docker"

DOCKER_VOLUMES="${INSTALL_DIR_DOCKER}/volumes"
DOCKER_VOLUME_TOR="${DOCKER_VOLUMES}/my-dojo_data-tor"
DOCKER_VOLUME_WP="${DOCKER_VOLUMES}/my-dojo_data-whirlpool"
DOCKER_VOLUME_BITCOIND="${DOCKER_VOLUMES}/my-dojo_data-bitcoind"

SALVAGE_MOUNT="${SECONDARY_STORAGE_MOUNT}"
SALVAGE_BITCOIN_IBD_DATA="${SALVAGE_MOUNT}/bitcoin"
BITCOIND_DATA_DIR="docker/volumes/my-dojo_data-bitcoind"

# Workaround when on x86 systems and autologin is enabled for the user account
if [ "$(getent group 1000 | cut -d ':' -f1)" = "autologin" ]; then
    USER=$(getent group 1000 | cut -d ':' -f4)
else
    USER=$(getent group 1000 | cut -d ':' -f1)
fi