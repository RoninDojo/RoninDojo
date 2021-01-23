#!/bin/bash
# shellcheck disable=SC2034

# RoninDojo Version tag
cd "$HOME"/RoninDojo && VERSION=$(git describe --tags)

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
    [sgdisk]=gptfdisk
    [gcc]=gcc
    [libusb]=libusb
)

#
# Dialog Variables
#
HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="RoninDojo ${VERSION}"
MENU="Choose one of the following menu options:"

# RoninDojo Menu Paths
RONIN_APPLICATIONS_MENU="$HOME/RoninDojo/Scripts/Menu/menu-applications.sh"
RONIN_APPLICATIONS_INSTALL_MENU="$HOME/RoninDojo/Scripts/Menu/menu-applications-install.sh"
RONIN_APPLICATIONS_UNINSTALL_MENU="$HOME/RoninDojo/Scripts/Menu/menu-applications-uninstall.sh"
RONIN_CREDENTIALS_MENU="$HOME/RoninDojo/Scripts/Menu/menu-credentials.sh"
RONIN_BOLTZMANN_MENU="$HOME/RoninDojo/Scripts/Menu/menu-boltzmann.sh"
RONIN_DOJO_MENU="$HOME/RoninDojo/Scripts/Menu/menu-dojo.sh"
RONIN_DOJO_MENU2="$HOME/RoninDojo/Scripts/Menu/menu-dojo2.sh"
RONIN_ELECTRS_MENU="$HOME/RoninDojo/Scripts/Menu/menu-electrs.sh"
RONIN_FIREWALL_MENU="$HOME/RoninDojo/Scripts/Menu/menu-firewall.sh"
RONIN_FIREWALL_MENU2="$HOME/RoninDojo/Scripts/Menu/menu-firewall2.sh"
RONIN_MEMPOOL_MENU="$HOME/RoninDojo/Scripts/Menu/menu-mempool.sh"
RONIN_SPECTER_MENU="$HOME/RoninDojo/Scripts/Menu/menu-specter.sh"
RONIN_SYSTEM_MENU="$HOME/RoninDojo/Scripts/Menu/menu-system.sh"
RONIN_SYSTEM_MENU2="$HOME/RoninDojo/Scripts/Menu/menu-system2.sh"
RONIN_SYSTEM_STORAGE="$HOME/RoninDojo/Scripts/Menu/menu-system-storage.sh"
RONIN_UI_BACKEND_MENU="$HOME/RoninDojo/Scripts/Menu/menu-ronin-ui-backend.sh"
RONIN_UPDATES_MENU="$HOME/RoninDojo/Scripts/Menu/menu-system-updates.sh"
RONIN_WHIRLPOOL_MENU="$HOME/RoninDojo/Scripts/Menu/menu-whirlpool.sh"
RONIN_WHIRLPOOL_STAT_MENU="$HOME/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh"

#
# Terminal Colors
#
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NC=$(tput sgr0) # No Color

#
# Install Defaults
#
DOJO_PATH="$HOME/dojo"
dojo_path_my_dojo="${DOJO_PATH}/docker/my-dojo"
ronin_data_dir="$HOME/.config/RoninDojo/data"
BOLTZMANN_PATH="$HOME/boltzmann"
RONIN_UI_BACKEND_DIR="$HOME/Ronin-UI-Backend"
DOJO_RESTORE=true
TOR_RESTORE=true

# Repositories
RONIN_DOJO_BRANCH="origin/master" # defaults to master
SAMOURAI_REPO='https://code.samourai.io/ronindojo/samourai-dojo.git'
SAMOURAI_COMMITISH="v1.8.1" # empty defaults to master
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
INDEXER_BACKUP_DIR="${INSTALL_DIR}/backup/indexer"
BITCOIN_BACKUP_DIR="${INSTALL_DIR}/backup/bitcoin"

TOR_DATA_DIR="docker/volumes/my-dojo_data-tor"
BITCOIND_DATA_DIR="docker/volumes/my-dojo_data-bitcoind"
INDEXER_DATA_DIR="docker/volumes/my-dojo_data_indexer"

sudoers_file="/etc/sudoers.d/21-ronindojo"

# Workaround when on x86 systems and autologin is enabled for the user account
if [ "$(getent group 1000 | cut -d ':' -f1)" = "autologin" ]; then
    USER=$(getent group 1000 | cut -d ':' -f4)
else
    USER=$(getent group 1000 | cut -d ':' -f1)
fi

# Specter defaults
SPECTER_SIGN_KEY_URL="https://stepansnigirev.com/ss-specter-release.asc"
SPECTER_SIGN_KEY="ss-specter-release.asc"
SPECTER_URL="https://github.com/cryptoadvance/specter-desktop.git"
SPECTER_VERSION="v1.0.0"

# Network info
ip=$(ip route get 1 | awk '{print $7}')
ip_range="$(echo "${ip}" | cut -d. -f1-3).0/24"

declare -a backup_dojo_data=(
    tor
    indexer
    bitcoind
)