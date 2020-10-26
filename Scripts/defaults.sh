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
    [jq]=jq
    [pipenv]=python-pipenv
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
RONIN_MEMPOOL_MENU="$HOME/RoninDojo/Scripts/Menu/menu-mempool.sh"
RONIN_WHIRLPOOL_MENU="$HOME/RoninDojo/Scripts/Menu/menu-whirlpool.sh"
RONIN_WHIRLPOOL_STAT_MENU="$HOME/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh"
RONIN_ELECTRS_MENU="$HOME/RoninDojo/Scripts/Menu/menu-electrs.sh"
RONIN_UI_BACKEND_MENU="$HOME/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh"
RONIN_UPDATES_MENU="$HOME/RoninDojo/Scripts/Menu/menu-system-updates.sh"
RONIN_BOLTZMANN_MENU="$HOME/RoninDojo/Scripts/Menu/menu-boltzmann.sh"
RONIN_CREDENTIALS_MENU="$HOME/RoninDojo/Scripts/Menu/menu-credentials.sh"

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
BOLTZMANN_PATH="$HOME/boltzmann"
RONIN_UI_BACKEND_DIR="$HOME/Ronin-UI-Backend"
DOJO_RESTORE=true
TOR_RESTORE=true

# Repositories
RONIN_DOJO_BRANCH="" # defaults to master
SAMOURAI_REPO='https://code.samourai.io/ronindojo/samourai-dojo.git'
SAMOURAI_COMMITISH="v1.8.0" # empty defaults to master
BOLTZMANN_REPO='https://code.samourai.io/oxt/boltzmann.git'
WHIRLPOOL_STATS_REPO='https://code.samourai.io/whirlpool/whirlpool_stats.git'

#
# Filesystem Defaults
#
PRIMARY_STORAGE="/dev/sda1"
SECONDARY_STORAGE="/dev/sdb1"
STORAGE_MOUNT="/mnt/backup"

BITCOIN_IBD_BACKUP_DIR="${STORAGE_MOUNT}/bitcoin"
INSTALL_DIR="/mnt/usb"
INSTALL_DIR_TOR="${INSTALL_DIR}/tor"
INSTALL_DIR_SWAP="${INSTALL_DIR}/swapfile"
INSTALL_DIR_UNINSTALL="${INSTALL_DIR}/bitcoin"
INSTALL_DIR_DOCKER="${INSTALL_DIR}/docker"

DOCKER_VOLUMES="${INSTALL_DIR_DOCKER}/volumes"
DOCKER_VOLUME_TOR="${DOCKER_VOLUMES}/my-dojo_data-tor"
DOCKER_VOLUME_WP="${DOCKER_VOLUMES}/my-dojo_data-whirlpool"
DOCKER_VOLUME_BITCOIND="${DOCKER_VOLUMES}/my-dojo_data-bitcoind"

DOJO_BACKUP_DIR="${INSTALL_DIR}/backup/dojo"
TOR_BACKUP_DIR="${INSTALL_DIR}/backup/tor"

TOR_DATA_DIR="docker/volumes/my-dojo_data-tor"
BITCOIND_DATA_DIR="docker/volumes/my-dojo_data-bitcoind"

# Workaround when on x86 systems and autologin is enabled for the user account
if [ "$(getent group 1000 | cut -d ':' -f1)" = "autologin" ]; then
    USER=$(getent group 1000 | cut -d ':' -f4)
else
    USER=$(getent group 1000 | cut -d ':' -f1)
fi
