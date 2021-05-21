#!/bin/bash
# shellcheck disable=SC2034

# RoninDojo Version tag
if [ -d "$HOME"/RoninDojo/.git ]; then
    cd "$HOME"/RoninDojo || exit
    ronindojo_version=$(git describe --tags)
fi

#
# Package dependencies associative array
#
declare -A package_dependencies=(
    [avahi-daemon]=avahi
    [pm2]=pm2
    [nginx]=nginx
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
    [node]=nodejs-lts-fermium
    [npm]=npm
    [jq]=jq
    [pipenv]=python-pipenv
    [sgdisk]=gptfdisk
    [gcc]=gcc
)

#
# OS package ignore list
#
declare -a pkg_ignore=(
    tor
    docker
    docker-compose
    bridge-utils
)

#
# Dialog Variables
#
HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="RoninDojo ${ronindojo_version}"
MENU="Elija una de las siguientes opciones de menú:"

# RoninDojo Menu Paths
ronin_applications_menu="$HOME/RoninDojo/Scripts/Menu/menu-applications.sh"
ronin_applications_manage_menu="$HOME/RoninDojo/Scripts/Menu/menu-applications-manage.sh"
ronin_credentials_menu="$HOME/RoninDojo/Scripts/Menu/menu-credentials.sh"
ronin_boltzmann_menu="$HOME/RoninDojo/Scripts/Menu/menu-boltzmann.sh"
ronin_dojo_menu="$HOME/RoninDojo/Scripts/Menu/menu-dojo.sh"
ronin_dojo_menu2="$HOME/RoninDojo/Scripts/Menu/menu-dojo2.sh"
ronin_electrs_menu="$HOME/RoninDojo/Scripts/Menu/menu-electrs.sh"
ronin_firewall_menu="$HOME/RoninDojo/Scripts/Menu/menu-firewall.sh"
ronin_firewall_menu2="$HOME/RoninDojo/Scripts/Menu/menu-firewall2.sh"
ronin_mempool_menu="$HOME/RoninDojo/Scripts/Menu/menu-mempool.sh"
ronin_specter_menu="$HOME/RoninDojo/Scripts/Menu/menu-specter.sh"
ronin_system_menu="$HOME/RoninDojo/Scripts/Menu/menu-system.sh"
ronin_system_menu2="$HOME/RoninDojo/Scripts/Menu/menu-system2.sh"
ronin_system_storage="$HOME/RoninDojo/Scripts/Menu/menu-system-storage.sh"
ronin_ui_menu="$HOME/RoninDojo/Scripts/Menu/menu-ronin-ui.sh"
ronin_updates_menu="$HOME/RoninDojo/Scripts/Menu/menu-system-updates.sh"
ronin_whirlpool_menu="$HOME/RoninDojo/Scripts/Menu/menu-whirlpool.sh"
ronin_whirlpool_stat_menu="$HOME/RoninDojo/Scripts/Menu/menu-whirlpool-wst.sh"
ronin_samourai_toolkit_menu="$HOME/RoninDojo/Scripts/Menu/menu-samourai-toolkit.sh"

#
# Terminal Colors
#
red=$(tput setaf 1)
green=$(tput setaf 2)
nc=$(tput sgr0) # No Color

#
# Install Defaults
#
dojo_path="$HOME/dojo"
dojo_path_my_dojo="${dojo_path}/docker/my-dojo"
ronin_data_dir="$HOME/.config/RoninDojo/data"
boltzmann_path="$HOME/boltzmann"
ronin_ui_path="$HOME/Ronin-UI"

#
# Data backup variables
#
dojo_data_bitcoind_backup=true
dojo_data_indexer_backup=true
dojo_conf_backup=true
tor_backup=true
backup_format=false

#
# Repositories
#
ronin_dojo_branch="origin/master" # defaults to origin/master
ronin_dojo_repo="https://code.samourai.io/ronindojo/RoninDojo"
samourai_repo='https://code.samourai.io/ronindojo/samourai-dojo.git'
samourai_commitish="v1.10.0" # Tag release
boltzmann_repo='https://code.samourai.io/oxt/boltzmann.git'
whirlpool_stats_repo='https://code.samourai.io/whirlpool/whirlpool_stats.git'
ronin_ui_repo="https://code.samourai.io/ronindojo/ronin-ui.git"

#
# Filesystem Defaults
#
primary_storage="/dev/sda1"
secondary_storage="/dev/sdb1"
storage_mount="/mnt/backup"

bitcoin_ibd_backup_dir="${storage_mount}/backup/bitcoin"
indexer_backup_dir="${storage_mount}/backup/indexer"
install_dir="/mnt/usb"
install_dir_tor="${install_dir}/tor"
install_dir_swap="${install_dir}/swapfile"
install_dir_docker="${install_dir}/docker"

docker_volumes="${install_dir_docker}/volumes"
docker_volume_tor="${docker_volumes}/my-dojo_data-tor"
docker_volume_wp="${docker_volumes}/my-dojo_data-whirlpool"
docker_volume_bitcoind="${docker_volumes}/my-dojo_data-bitcoind"
docker_volume_indexer="${docker_volumes}/my-dojo_data-indexer"

# Dojo Related Backup Paths
dojo_backup_bitcoind="${install_dir}/backup/bitcoin"
dojo_backup_indexer="${install_dir}/backup/indexer"
dojo_backup_dir="${install_dir}/backup/dojo"
tor_backup_dir="${install_dir}/backup/tor"

tor_data_dir="docker/volumes/my-dojo_data-tor"
bitcoind_data_dir="docker/volumes/my-dojo_data-bitcoind"
indexer_data_dir="docker/volumes/my-dojo_data_indexer"

sudoers_file="/etc/sudoers.d/21-ronindojo"

# Workaround when on desktop systems and autologin is enabled for the user account
if [ "$(getent group 1000 | cut -d ':' -f1)" = "autologin" ]; then
    ronindojo_user=$(getent group 1000 | cut -d ':' -f4)
else
    ronindojo_user=$(getent group 1000 | cut -d ':' -f1)
fi

# Specter defaults
specter_sign_key_url="https://stepansnigirev.com/ss-specter-release.asc"
specter_sign_key="ss-specter-release.asc"
specter_url="https://github.com/cryptoadvance/specter-desktop.git"
specter_version="v1.5.0"

# Network info
ip=$(ip route get 1 | awk '{print $7}')
ip_range="$(echo "${ip}" | cut -d. -f1-3).0/24"

# bitcoind defaults
bitcoind_db_cache_total=0.3 # Uses 30% of total RAM

declare -a backup_dojo_data=(
    tor
    indexer
    bitcoind
)
