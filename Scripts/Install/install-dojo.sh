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
  bash -c ronin
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
  # TODO sed template files on the fly instead
  cat << EOF > "${DOJO_PATH}"/conf/docker-bitcoind.conf.tpl
#########################################
# CONFIGURATION OF BITCOIND CONTAINER
#########################################
# User account used for rpc access to bitcoind
# Type: alphanumeric
BITCOIND_RPC_USER=${BITCOIND_RPC_USER:-$RPC_USER}
# Password of user account used for rpc access to bitcoind
# Type: alphanumeric
BITCOIND_RPC_PASSWORD=${BITCOIND_RPC_PASSWORD:-$RPC_PASS}
# Max number of connections to network peers
# Type: integer
BITCOIND_MAX_CONNECTIONS=16
# Mempool maximum size in MB
# Type: integer
BITCOIND_MAX_MEMPOOL=400
# Db cache size in MB
# Type: integer
BITCOIND_DB_CACHE=${BITCOIND_DB_CACHE:-700}
# Number of threads to service RPC calls
# Type: integer
BITCOIND_RPC_THREADS=6
# RPC Work queue size
# Type: integer
BITCOIND_RPC_WORK_QUEUE=16
# Mempool expiry in hours
# Defines how long transactions stay in your local mempool before expiring
# Type: integer
BITCOIND_MEMPOOL_EXPIRY=72
# Min relay tx fee in BTC
# Type: numeric
BITCOIND_MIN_RELAY_TX_FEE=0.00001
# Allow incoming connections
# This parameter is inactive if BITCOIND_INSTALL is set to 'off'
# Values: on | off
BITCOIND_LISTEN_MODE=on

#
# EXPERT SETTINGS
#
#
# EPHEMERAL ONION ADDRESS FOR BITCOIND
# THIS PARAMETER HAS NO EFFECT IF BITCOIND_INSTALL IS SET TO OFF
#
# Generate a new onion address for bitcoind when Dojo is launched
# Activation of this option is recommended for improved privacy.
# Values: on | off
BITCOIND_EPHEMERAL_HS=on
#
# EXPOSE BITCOIND RPC API AND ZMQ NOTIFICATIONS TO EXTERNAL APPS
# THESE PARAMETERS HAVE NO EFFECT IF BITCOIND_INSTALL IS SET TO OFF
#
# Expose the RPC API to external apps
# Warning: Do not expose your RPC API to internet!
# See BITCOIND_RPC_EXTERNAL_IP
# Value: on | off
BITCOIND_RPC_EXTERNAL=${BITCOIND_RPC_EXTERNAL:-on}
# IP address used to expose the RPC API to external apps
# This parameter is inactive if BITCOIND_RPC_EXTERNAL isn't set to 'on'
# Warning: Do not expose your RPC API to internet!
# Recommended value:
#   linux: 127.0.0.1
#   macos or windows: IP address of the VM running the docker host
# Type: string
BITCOIND_RPC_EXTERNAL_IP=${BITCOIND_RPC_EXTERNAL_IP:-127.0.0.1}
#
# INSTALL AND RUN BITCOIND INSIDE DOCKER
#
# Install and run bitcoind inside Docker
# Set this option to 'off' for using a bitcoind hosted outside of Docker (not recommended)
# Value: on | off
BITCOIND_INSTALL=on
# IP address of bitcoind used by Dojo
# Set value to 172.28.1.5 if BITCOIND_INSTALL is set to 'on'
# Type: string
BITCOIND_IP=172.28.1.5
# Port of the RPC API
# Set value to 28256 if BITCOIND_INSTALL is set to 'on'
# Type: integer
BITCOIND_RPC_PORT=28256
# Port exposing ZMQ notifications for raw transactions
# Set value to 9501 if BITCOIND_INSTALL is set to 'on'
# Type: integer
BITCOIND_ZMQ_RAWTXS=9501
# Port exposing ZMQ notifications for block hashes
# Set value to 9502 if BITCOIND_INSTALL is set to 'on'
# Type: integer
BITCOIND_ZMQ_BLK_HASH=9502
#
# SHUTDOWN
#
# Max delay for bitcoind shutdown (expressed in seconds)
# Defines how long Dojo waits for a clean shutdown of bitcoind before shutting down the bitcoind container
# This parameter is inactive if BITCOIND_INSTALL is set to 'off'
# Type: integer
BITCOIND_SHUTDOWN_DELAY=180
EOF
  # create new docker bitcoind conf file
  # websearch "bash heredoc" for info on redirection

  echo -e "${RED}"
  echo "***"
  echo "Setting the Node API Key and JWT Secret..."
  echo "***"
  echo -e "${NC}"
  _sleep

  echo -e "${RED}"
  echo "***"
  echo "Setting the Node Admin Key..."
  echo "***"
  echo -e "${NC}"
  _sleep

  cat << EOF > "${DOJO_PATH}"/conf/docker-node.conf.tpl
#########################################
# CONFIGURATION OF NODE JS CONTAINER
#########################################
# API key required for accessing the services provided by the server
# Keep this API key secret!
# Provide a value with a high entropy!
# Type: alphanumeric
NODE_API_KEY=$NODE_API_KEY

# API key required for accessing the admin/maintenance services provided by the server
# Keep this Admin key secret!
# Provide a value with a high entropy!
# Type: alphanumeric
NODE_ADMIN_KEY=$NODE_ADMIN_KEY

# Secret used by the server for signing Json Web Token
# Keep this value secret!
# Provide a value with a high entropy!
# Type: alphanumeric
NODE_JWT_SECRET=$NODE_JWT_SECRET

# Indexer or third-party service used for imports and rescans of addresses
# Values: local_bitcoind | third_party_explorer
NODE_ACTIVE_INDEXER=${NODE_ACTIVE_INDEXER:-local_bitcoind}

# FEE TYPE USED FOR FEES ESTIMATIONS BY BITCOIND
# Allowed values are ECONOMICAL or CONSERVATIVE
NODE_FEE_TYPE=ECONOMICAL
EOF
  # create new docker node conf file
  # websearch "bash heredoc" for info on redirection

  cat << EOF > "${DOJO_PATH}"/conf/docker-mysql.conf.tpl
#########################################
# CONFIGURATION OF MYSQL CONTAINER
#########################################
# Password of MySql root account
# Type: alphanumeric
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
# User account used for db access
# Type: alphanumeric
MYSQL_USER=$MYSQL_USER
# Password of of user account
# Type: alphanumeric
MYSQL_PASSWORD=$MYSQL_PASSWORD
EOF
  # create new mysql conf file
  # websearch "bash heredoc" for info on redirection

  # BTC-EXPLORER PASSWORD
  echo -e "${RED}"
  echo "***"
  echo "Installing your Dojo-backed Bitcoin Explorer..."
  echo "***"
  echo -e "${NC}"
  _sleep

  cat << EOF > "${DOJO_PATH}"/conf/docker-explorer.conf.tpl
#########################################
# CONFIGURATION OF EXPLORER CONTAINER
#########################################
# Install and run a block explorer inside Dojo (recommended)
# Value: on | off
EXPLORER_INSTALL=${EXPLORER_INSTALL:-on}
# Password required for accessing the block explorer
# (login can be anything)
# Keep this password secret!
# Provide a value with a high entropy!
# Type: alphanumeric
EXPLORER_KEY=$EXPLORER_KEY
EOF
  # create new block explorer conf file
  # websearch "bash heredoc" for info on redirection

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

# indexer names here are used as data source
select indexer in "Samourai Indexer" "Electrum Rust Server" "Do Not Install Indexer"; do
  case $indexer in
    "Samourai Indexer")
      cat <<EOF
${RED}
***
Installing Samourai Indexer...
***
${NC}
EOF
      _sleep
      sudo sed -i 's/INDEXER_INSTALL=off/INDEXER_INSTALL=on/' "${DOJO_PATH}"/conf/docker-indexer.conf.tpl
      sudo sed -i 's/NODE_ACTIVE_INDEXER=local_bitcoind/NODE_ACTIVE_INDEXER=local_indexer/' "${DOJO_PATH}"/conf/docker-node.conf.tpl
      break;;
      # samourai indexer install enabled in .conf.tpl files using sed
    "Electrum Rust Server")
      cat <<EOF
${RED}
***
Installing Electrum Rust Server...
***
${NC}
EOF
      _sleep
      bash "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh;;
      # triggers electrs install script
  "Do Not Install Indexer")
    cat <<EOF
${RED}
***
Indexer will not be installed...
***
${NC}
EOF
    _sleep
    break;;
    # indexer will not be installed
  *)
    cat <<EOF
${RED}
***
Invalid Entry!
***
${NC}
EOF
    _sleep
    ;;
    # invalid data try again
  esac
done

if [ ! -f "${DOJO_PATH}/conf/docker-mempool.conf" ]; then
  cat <<EOF
${RED}
***
Do you want to install the Mempool Visualizer? [y/n]
***
${NC}
EOF

  read -r yn
  case $yn in
      [Y/y]* )
          _mempool_conf conf.tpl
        ;;
      [N/n]* ) echo "Mempool will not be installed!";;
      * ) echo "Please answer Yes or No.";;
  esac
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
echo "Installing Dojo..."
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
Press any letter to continue...
***
${NC}
DOJO

read -n 1 -r -s
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