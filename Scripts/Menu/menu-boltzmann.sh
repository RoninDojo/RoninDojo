#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if [ ! -d "${BOLTZMANN_PATH}" ]; then
    cat <<EOF
${RED}
***
Installing Boltzmann...
***
${NC}
EOF
    _sleep

    bash -c "$HOME"/RoninDojo/Scripts/Install/install-boltzmann.sh
fi

# checks if ${HOME}/boltzmann dir exists, if so kick back to menu
cat << 'EOF'
    __          ____                                  
   / /_  ____  / / /_____  ____ ___  ____ _____  ____ 
  / __ \/ __ \/ / __/_  / / __ `__ \/ __ `/ __ \/ __ \
 / /_/ / /_/ / / /_  / /_/ / / / / / /_/ / / / / / / /
/_.___/\____/_/\__/ /___/_/ /_/ /_/\__,_/_/ /_/_/ /_/ 
A python script computing the entropy of Bitcoin transactions
    and the linkability of their inputs and outputs.

EOF

cat <<EOF
Example Usage:

${RED}
Single txid
${NC}
8e56317360a548e8ef28ec475878ef70d1371bee3526c017ac22ad61ae5740b8

${RED}
Multiple txids
${NC}
8e56317360a548e8ef28ec475878ef70d1371bee3526c017ac22ad61ae5740b8,812bee538bd24d03af7876a77c989b2c236c063a5803c720769fc55222d36b47,...
EOF

cd "${BOLTZMANN_PATH}"/boltzmann || exit

# Export required environment variables
export BOLTZMANN_RPC_USERNAME=${RPC_USER_CONF}
export BOLTZMANN_RPC_PASSWORD=${RPC_PASS_CONF}
export BOLTZMANN_RPC_HOST=${RPC_IP}
export BOLTZMANN_RPC_PORT=${RPC_PORT}

# Loop command until user quits
until [[ "$txids" =~ (Q|q|quit|Quit) ]]
do
  printf "\nEnter a txid or multiple txids separated by commas. Type [Q|Quit] to exit boltzmann\n"
  read -r txids

  if [[ ! "$txids" =~ (Q|Quit) ]]; then
    pipenv run python ludwig.py --rpc --txids="${txids}"
  else
    bash "$HOME"/RoninDojo/Scripts/Menu/menu-sw-toolkit.sh
  fi
done