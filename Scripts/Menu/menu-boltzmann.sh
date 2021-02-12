#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if [ ! -d "${boltzmann_path}" ]; then
    cat <<EOF
${red}
***
Installing Boltzmann...
***
${nc}
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

${red}
Single txid
${nc}
8e56317360a548e8ef28ec475878ef70d1371bee3526c017ac22ad61ae5740b8

${red}
Multiple txids
${nc}
8e56317360a548e8ef28ec475878ef70d1371bee3526c017ac22ad61ae5740b8,812bee538bd24d03af7876a77c989b2c236c063a5803c720769fc55222d36b47,...
EOF

cd "${boltzmann_path}"/boltzmann || exit

# Export required environment variables
export BOLTZMANN_RPC_USERNAME=${rpc_user_conf}
export BOLTZMANN_RPC_PASSWORD=${rpc_pass_conf}
export BOLTZMANN_RPC_HOST=${rpc_ip}
export BOLTZMANN_RPC_PORT=${rpc_port}

# Loop command until user quits
until [[ "$txids" =~ (Q|q|quit|Quit) ]]
do
  printf "\nEnter a txid or multiple txids separated by commas. Type [Q|Quit] to exit boltzmann\n"
  read -r txids

  if [[ ! "$txids" =~ (Q|Quit) ]]; then
    if ! pipenv run python ludwig.py --rpc --txids="${txids}" 2>/dev/null; then
      _check_pkg "pipenv" "python-pipenv"

      cat <<EOF
${red}
***
Checking for updates...
***
${nc}
EOF
      _sleep

      cd .. || exit

      # Upgrade dependencies
      pipenv update &>/dev/null
    fi
  else
    bash -c "${ronin_samourai_toolkit_menu}"
  fi
done