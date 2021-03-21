#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Dojo"
         2 "Whirlpool"
         3 "Electrs"
         4 "Mempool"
         5 "Ronin UI"
         6 "Bitcoind"
         7 "Servidor de Specter"
         8 "Todas las credenciales"
         9 "Atrás")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            cat <<EOF
${red}
***
Credenciales de Samourai Dojo
***
${nc}

${red}
***
ADVERTENCIA: No comparta estas direcciones onion con nadie!
***
${nc}

Herramienta de mantenimiento:
Tor V3 URL              = http://${v3_addr_dojo_api}/admin
Admin Key               = $NODE_ADMIN_KEY
API Key                 = $NODE_API_KEY
EOF
                _pause volver
                bash -c "${ronin_credentials_menu}"
                # press any key to return to menu
                # shows samouraio dojo credentials and returns to menu
                ;;
        2)
            cat <<EOF
${red}
***
Credenciales de Samourai Whirlpool
***
${nc}

${red}
***
ADVERTENCIA: No comparta estas direcciones onion con nadie!
***
${nc}

Tor V3 URL              = http://${v3_addr_whirlpool}
Whirlpool API Key       = ${whirlpool_api_key:-Whirlpool not Initiated yet. Pair wallet with GUI}
EOF
            _pause volver
            bash -c "${ronin_credentials_menu}"
            # press any key to return to menu
            # shows whirlpool credentials and returns to menu
            ;;
        3)
            if _is_electrs; then
                cat <<EOF
${red}
***
Credenciales de Electrs
***
${nc}

Electrs Tor URL         = http://${v3_addr_electrs}
EOF
                # displaying electrs tor address to connect to electrum

                cat <<EOF
${red}
***
Revisa la wiki de RoninDojo para información del emparejamiento en https://wiki.ronindojo.io
***
${nc}
EOF
            fi

            _sleep

            _pause volver
            bash -c "${ronin_credentials_menu}"
            # return to menu
            ;;
        4)
            if ! _is_mempool ; then
                cat <<EOF
${red}
***
Mempool.space no instalada....
***
${nc}
EOF
                _sleep
                cat <<EOF
${red}
***
Install using the manage applications menu...
***
${nc}
EOF
                _sleep

                _pause volver
                bash -c "${ronin_credentials_menu}"
            else
                cat <<EOF
${red}
***
Credenciales del visualizador de espacio de la Mempool
***

***
${nc}
Mempool Tor URL         =  http://${v3_addr_mempool}
EOF

                _pause volver
                bash -c "${ronin_credentials_menu}"
                # press any key to return to menu
                # see defaults.sh
                fi
                ;;
        5)
            _ronin_ui_credentials && cd "$HOME" || exit

            cat <<EOF
${red}
***
Credenciales del UI Backend de Ronin
***
${nc}

Local Access Domain     =   http://ronindojo.local
Local Access IP         =   http://${ip} # fallback for when ronindojo.local doesn't work for you.
Ronin Tor URL           =   http://${BACKEND_TOR}
EOF
            _pause volver
            bash -c "${ronin_credentials_menu}"
            # shows Ronin UI credentials, returns to menu
            ;;
        6)
            cat <<EOF
${red}
***
Credenciales de Bitcoin
***
${nc}

Bitcoin Daemon:

Tor V3 URL              = http://${v3_addr_bitcoind}
RPC User                = $BITCOIND_RPC_USER
RPC Password            = $BITCOIND_RPC_PASSWORD
RPC IP                  = $BITCOIND_IP
RPC Port                = $BITCOIND_RPC_PORT

Bitcoin RPC Explorer (No username required):
Tor V3 URL              = http://${v3_addr_explorer}
Password                = $EXPLORER_KEY
EOF
            _pause volver
            bash -c "${ronin_credentials_menu}"
            # press any key to return to menu
            # shows bitcoind and btc rpc explorer credentials and returns to menu
            ;;
        7)
            if ! _is_specter ; then
                cat <<EOF
${red}
***
Servidor de Specter no instalado...
***
${nc}
EOF
                _sleep
                cat <<EOF
${red}
***
Install using the manage applications menu...
***
${nc}
EOF
                _sleep

                _pause volver

                bash -c "${ronin_credentials_menu}"
            else
                cat <<EOF
${red}
***
Credenciales del servidor de Specter
***
${nc}

Tor URL                 = http://${v3_addr_specter}
RPC User                = $BITCOIND_RPC_USER
RPC Password            = $BITCOIND_RPC_PASSWORD
RPC IP                  = $BITCOIND_IP
RPC Port                = $BITCOIND_RPC_PORT
EOF
            fi

            _pause volver
            bash -c "${ronin_credentials_menu}"
            # press any key to return to menu
            # shows specter server credentials and returns to menu
            ;;
        8)
            _ronin_ui_credentials && cd "$HOME" || exit
            cat <<EOF
${red}
***
Mostrando la lista de todas las credenciales disponibles en tu RoninDojo...
***
${nc}
EOF
            _sleep 5 --msg "Displaying in "

            cat <<EOF
${red}
***
Credenciales de Samourai Dojo
***

***
ADVERTENCIA: No comparta estas direcciones onion con nadie!
***
${nc}

Maintenance Tool:
Tor V3 URL              = http://${v3_addr_dojo_api}/admin
Admin Key               = $NODE_ADMIN_KEY
API Key                 = $NODE_API_KEY

${red}
***
Credenciales de Samourai Whirlpool
***

***
ADVERTENCIA: No comparta estas direcciones onion con nadie!
***
${nc}

Tor V3 URL              = http://${v3_addr_whirlpool}
Whirlpool API Key       = ${whirlpool_api_key:-Whirlpool not Initiated yet. Pair wallet with GUI}

${red}
***
Credenciales del UI Backend de Ronin
***
${nc}

Local Access Domain     =   http://ronindojo.local
Local Access IP         =   http://${ip} # fallback for when ronindojo.local doesn't work for you.
Ronin Tor URL           =   http://${BACKEND_TOR}

${red}
***
Credenciales de Bitcoin
***
${nc}

Bitcoin Daemon:

Tor V3 URL              = http://${v3_addr_bitcoind}
RPC User                = $BITCOIND_RPC_USER
RPC Password            = $BITCOIND_RPC_PASSWORD
RPC IP                  = $BITCOIND_IP
RPC Port                = $BITCOIND_RPC_PORT

Bitcoin RPC Explorer (No username required):
Tor V3 URL              = http://${v3_addr_explorer}
Password                = $EXPLORER_KEY
EOF
            if [ -f "${dojo_path_my_dojo}"/indexer/electrs.toml ]; then
                cat <<EOF
${red}
***
Credenciales de Electrs
***
${nc}

Electrs Tor URL         = http://${v3_addr_electrs}
EOF
            fi

            if _is_mempool; then
                cat <<EOF
${red}
***
Credenciales del visualizador de espacio de la Mempool
***
${nc}
Mempool Tor URL         = http://${v3_addr_mempool}
EOF
            fi

            if _is_specter ; then
                cat <<EOF
${red}
***
Credenciales del servidor de Specter
***
${nc}
Tor URL                 = http://${v3_addr_specter}
RPC User                = $BITCOIND_RPC_USER
RPC Password            = $BITCOIND_RPC_PASSWORD
RPC IP                  = $BITCOIND_IP
RPC Port                = $BITCOIND_RPC_PORT
EOF
            fi

            _pause volver
            bash -c "${ronin_credentials_menu}"
            # press any key to return to menu
            # shows all credentials and returns to menu
            ;;
        9)
            ronin
            # returns to main menu
            ;;
esac