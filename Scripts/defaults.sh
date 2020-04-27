#
# Terminal Colors
#
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)
# No Color

SAMOURAI_REPO='https://code.samourai.io/Ronin/samourai-dojo.git'
USER=$(getent group 1000 | cut -d ':' -f1)

#
# Dialog variables
#
HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="RoninDojo"
MENU="Choose one of the following options:"

#
# Dojo Docker settings
#

# bitcoind
RPC_PASS=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)
RPC_USER=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

# node
NODE_API_KEY=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)
NODE_JWT_SECRET=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)
NODE_ADMIN_KEY=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)

# mysql
MYSQL_ROOT_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)
MYSQL_USER=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 12 | head -n 1)
MYSQL_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

# explorer
EXPLORER_KEY=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 16 | head -n 1)