#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/generated-credentials.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if ! findmnt "${INSTALL_DIR}" 1>/dev/null; then
  cat <<DOJO
${RED}
***
Missing drive mount at ${INSTALL_DIR}! Please contact support for assistance.
***

***
Exiting RoninDojo in 5 seconds...
***
${NC}
DOJO
  _sleep 5
  exit 1
fi

if [ -d "${DOJO_PATH}" ]; then
  cat <<DOJO
${RED}
***
RoninDojo is already installed...
***
${NC}
DOJO
  _sleep 5 --msg "Returning to menu in"
  ronin
fi
# Makes sure Dojo has been uninstalled

echo -e "${RED}"
echo "***"
echo "Running RoninDojo install in 5s..."
echo "***"
echo -e "${NC}"

echo -e "${RED}"
echo "***"
echo "Use Ctrl+C to exit now if needed!"
echo "***"
echo -e "${NC}"
_sleep 5

echo -e "${RED}"
echo "***"
echo "Downloading and extracting latest RoninDojo release..."
echo "***"
echo -e "${NC}"
cd "$HOME" || exit
git clone -b "${SAMOURAI_COMMITISH:-master}" "$SAMOURAI_REPO" dojo 2>/dev/null

echo -e "${RED}"
echo "***"
echo "Credentials necessary for usernames, passwords, etc. will randomly be generated now..."
echo "***"
echo -e "${NC}"

cat <<DOJO
${RED}
***
Credentials are found in RoninDojo menu, ${DOJO_PATH}/conf, or in the ~/RoninDojo/user.conf.example file.
***
${NC}
DOJO
_sleep 2

echo -e "${RED}"
echo "***"
echo "Be aware these credentials are used to login to Dojo Maintenance Tool, Block Explorer, and more!"
echo "***"
echo -e "${NC}"
_sleep 5

echo -e "${RED}"
echo "***"
echo "Setting the RPC User and Password..."
echo "***"
echo -e "${NC}"
_sleep

if [ -d "${DOJO_BACKUP_DIR}" ]; then
  if ! _dojo_restore; then
  cat <<EOF
${RED}
***
Dojo backup restore disabled! Enable in user.conf if you wish
to restore credentials on dojo install when available
***
${NC}
EOF
  else
    cat <<EOF
${RED}
***
Dojo credentials backup detected and restored...
If you wish to disable this feature, set DOJO_RESTORE=false in
$HOME/.conf/RoninDojo/user.conf
EOF
  fi
else
  cat <<EOF
${RED}
***
Configuring the bitcoin daemon server...
***
${NC}
EOF
  _sleep
  sed -i -e "s/BITCOIND_RPC_USER=.*$/BITCOIND_RPC_USER=${BITCOIND_RPC_USER:-$RPC_USER}/" \
    -e "s/BITCOIND_RPC_PASSWORD=.*$/BITCOIND_RPC_PASSWORD=${BITCOIND_RPC_PASSWORD:-$RPC_PASS}/" \
    -e "s/BITCOIND_DB_CACHE=.*$/BITCOIND_DB_CACHE=${BITCOIND_DB_CACHE:-700}/" \
    -e "s/BITCOIND_MAX_MEMPOOL=.*$/BITCOIND_MAX_MEMPOOL=400/" \
    -e "s/BITCOIND_RPC_EXTERNAL=.*$/BITCOIND_RPC_EXTERNAL=${BITCOIND_RPC_EXTERNAL:-on}/" \
    -e "s/BITCOIND_RPC_EXTERNAL_IP=.*$/BITCOIND_RPC_EXTERNAL_IP=${BITCOIND_RPC_EXTERNAL_IP:-127.0.0.1}/" "${DOJO_PATH}"/conf/docker-bitcoind.conf.tpl
  # populate docker-bitcoind.conf.tpl template

  cat <<EOF
${RED}
***
Configuring the Nodejs container...
***
${NC}
EOF
  _sleep

  sed -i -e "s/NODE_API_KEY=.*$/NODE_API_KEY=${NODE_API_KEY}/" \
    -e "s/NODE_ADMIN_KEY=.*$/NODE_ADMIN_KEY=${NODE_ADMIN_KEY}/" \
    -e "s/NODE_JWT_SECRET=.*$/NODE_JWT_SECRET=${NODE_JWT_SECRET}/" \
    -e "s/NODE_ACTIVE_INDEXER=.*$/NODE_ACTIVE_INDEXER=${NODE_ACTIVE_INDEXER:-local_bitcoind}/" "${DOJO_PATH}"/conf/docker-node.conf.tpl
  # populate docker-node.conf.tpl template

  sed -i -e "s/MYSQL_ROOT_PASSWORD=.*$/MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}/" \
    -e "s/MYSQL_USER=.*$/MYSQL_USER=${MYSQL_USER}/" \
    -e "s/MYSQL_PASSWORD=.*$/MYSQL_PASSWORD=${MYSQL_PASSWORD}/" "${DOJO_PATH}"/conf/docker-mysql.conf.tpl
  # populate docker-mysql.conf.tpl template

  cat <<EOF
${RED}
***
Configuring the BTC RPC Explorer...
***
${NC}
EOF
  _sleep

  sed -i -e "s/EXPLORER_INSTALL=.*$/EXPLORER_INSTALL=${EXPLORER_INSTALL:-on}/" \
    -e "s/EXPLORER_KEY=.*$/EXPLORER_KEY=${EXPLORER_KEY}/" "${DOJO_PATH}"/conf/docker-explorer.conf.tpl
  # populate docker-explorer.conf.tpl template

  # Backup credentials
  _dojo_backup
fi

cat <<EOF
${RED}
***
Preparing for Indexer Prompt...
***
${NC}
EOF
_sleep 2

cat <<EOF
${RED}
***
Samourai Indexer is recommended for most users as it helps with querying balances...
***
${NC}
EOF
_sleep 3

cat <<EOF
${RED}
***
Electrum Rust Server is recommended for Hardware Wallets, Multisig, and other Electrum features...
***
${NC}
EOF
_sleep 3

cat <<EOF
${RED}
***
Skipping the installation of either Indexer option is ok! You can always install later...
***
${NC}
EOF
_sleep 3

cat <<EOF
${RED}
***
Choose one of the following options for your Indexer...
***
${NC}
EOF
_sleep 3
_no_indexer_found
# give user menu for install choices, see functions.sh

if [ ! -f "${DOJO_PATH}/conf/docker-mempool.conf" ] || grep "MEMPOOL_INSTALL=off" "${DOJO_PATH}/conf/docker-mempool.conf" 1>/dev/null; then
  cat <<EOF
${RED}
***
Do you want to install the Mempool Visualizer? [${GREEN}Yes${NC}/${RED}No${NC}]
***
${NC}
EOF

  while true; do
    read -r answer
    case $answer in
        [yY][eE][sS]|[yY])
          _mempool_conf conf.tpl
          break
          ;;
        [nN][oO]|[Nn])
          break
          ;;
        *)
          cat <<EOF
${RED}
***
Invalid answer! Enter Y or N
***
${NC}
EOF
          ;;
    esac
  done
  # install mempool prompt
fi

echo -e "${RED}"
echo "***"
echo "Please see Wiki for FAQ, help, and so much more..."
echo "***"
echo -e "${NC}"

echo -e "${RED}"
echo "***"
echo "https://wiki.ronindojo.io"
echo "***"
echo -e "${NC}"
_sleep 5

echo -e "${RED}"
echo "***"
echo "Installing Samourai Dojo..."
echo "***"
echo -e "${NC}"
_sleep 2

cd "$DOJO_PATH" || exit

./dojo.sh install --nolog

# Checks if urls need to be changed for mempool UI
_mempool_urls_to_local_btc_explorer

cat <<DOJO
${RED}
***
Press any key to continue...
***
${NC}
DOJO

_pause
# press to continue is needed because sudo password can be requested for next steps
# if the user is AFK there may be timeout

if sudo test -d "${INSTALL_DIR_UNINSTALL}/blocks" && sudo test -d "${DOCKER_VOLUME_BITCOIND}"; then
  echo -e "${RED}"
  echo "***"
  echo "Blockchain data salvage starting..."
  echo "***"
  echo -e "${NC}"

  cd "$DOJO_PATH" || exit
  _stop_dojo

  _sleep

  sudo rm -rf "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate}
  sudo mv -v "${INSTALL_DIR_UNINSTALL}"/{blocks,chainstate} "${DOCKER_VOLUME_BITCOIND}"/_data/
  # changes to dojo path, otherwise exit
  # websearch "bash Logical OR (||)" for info
  # stops dojo and removes new data directories
  # then moves salvaged block data

  echo -e "${RED}"
  echo "***"
  echo "Blockchain data salvage completed..."
  echo "***"
  echo -e "${NC}"
  _sleep 2
  sudo rm -rf "${INSTALL_DIR_UNINSTALL}"
  # remove old salvage directories

  cd "$DOJO_PATH" || exit

  _source_dojo_conf

  # Start docker containers
  yamlFiles=$(_select_yaml_files)
  docker-compose $yamlFiles up --remove-orphans -d || exit # failed to start dojo
  # start dojo
fi
# check for IBD data, if not found continue

if ${TOR_RESTORE}; then
  _tor_restore

  docker restart tor 1>/dev/null
fi
# Restore tor credentials backup to container