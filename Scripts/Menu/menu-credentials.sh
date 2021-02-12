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
         5 "UI Backend"
         6 "Bitcoind"
         7 "Specter Server"
         8 "All Credentials"
         9 "Go Back")

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
${RED}
***
Samourai Dojo Credentials
***
${NC}

${RED}
***
WARNING: Do not share these onion addresses with anyone!
***
${NC}

Maintenance Tool:
Tor V2 URL              = http://$v2_addr_dojo_api/admin
Tor V3 URL              = http://$v3_addr_dojo_api/admin
Admin Key               = $NODE_ADMIN_KEY
API Key                 = $NODE_API_KEY
EOF
                _pause return
                bash -c "${ronin_credentials_menu}"
                # press any key to return to menu
                # shows samouraio dojo credentials and returns to menu
                ;;
        2)
            cat <<EOF
${RED}
***
Samourai Whirlpool Credentials
***
${NC}

${RED}
***
WARNING: Do not share these onion addresses with anyone!
***
${NC}

Tor V2 URL              = http://$v2_addr_whirlpool
Tor V3 URL              = http://$v3_addr_whirlpool
Whirlpool API Key       = ${whirlpool_api_key:-Whirlpool not Initiated yet. Pair wallet with GUI}
EOF
            _pause return
            bash -c "${ronin_credentials_menu}"
            # press any key to return to menu
            # shows whirlpool credentials and returns to menu
            ;;
        3)
            if _is_electrs; then
                cat <<EOF
${RED}
***
Electrs Credentials
***
${NC}

Electrs Tor URL         = $v3_addr_electrs
EOF
                # displaying electrs tor address to connect to electrum

                cat <<EOF
${RED}
***
Check the RoninDojo Wiki for pairing information at https://wiki.ronindojo.io
***
${NC}
EOF
            fi

            bash -c "${ronin_credentials_menu}"
            # return to menu
            ;;
        4)
            if ! _mempool_check ; then
                cat <<EOF
${RED}
***
Mempool Space Visualizer is not installed...
***
${NC}
EOF
                _sleep 2
                cat <<EOF
${RED}
***
Install using the manage applications menu...
***
${NC}
EOF
                _sleep 2

                _pause return
                bash -c "${ronin_credentials_menu}"
            else
                cat <<EOF
${RED}
***
Mempool Space Visualizer Credentials
***

***
${NC}
Mempool Tor URL         =  http://${v3_addr_mempool}
EOF

                _pause return
                bash -c "${ronin_credentials_menu}"
                # press any key to return to menu
                # see defaults.sh
                fi
                ;;
        5)
            _ui_backend_credentials && cd "$HOME" || exit

            cat <<EOF
${RED}
***
Ronin UI Backend Credentials
***
${NC}

Ronin API Key           =   ${API_KEY}
JWT SECRET              =   ${JWT_SECRET}
Port                    =   ${BACKEND_PORT}
Ronin URL               =   http://${BACKEND_TOR}
EOF
            _pause return
            bash -c "${ronin_credentials_menu}"
            # shows Ronin UI Backend credentials, returns to menu
            ;;
        6)
            cat <<EOF
${RED}
***
Bitcoin Credentials
***
${NC}

Bitcoin Daemon:

Tor V2 URL              = http://$v2_addr_bitcoind
Tor V3 URL              = http://$v3_addr_bitcoind
RPC User                = $rpc_user_conf
RPC Password            = $rpc_pass_conf
RPC IP                  = $rpc_ip
RPC Host                = $rpc_port

Bitcoin RPC Explorer (No username required):
Tor V2 URL              = http://$v2_addr_explorer
Tor V3 URL              = http://$v3_addr_explorer
Password                = $EXPLORER_KEY
EOF
            _pause return
            bash -c "${ronin_credentials_menu}"
            # press any key to return to menu
            # shows bitcoind and btc rpc explorer credentials and returns to menu
            ;;
        7)
            if ! _is_specter ; then
                cat <<EOF
${RED}
***
Specter Server is not installed...
***
${NC}
EOF
                _sleep 2
                cat <<EOF
${RED}
***
Install using the manage applications menu...
***
${NC}
EOF
                _sleep 2

                _pause return

                bash -c "${ronin_credentials_menu}"
            else
                cat <<EOF
${RED}
***
Specter Server Credentials
***
${NC}

Tor URL                 = http://$v3_addr_specter
RPC User                = $rpc_user_conf
RPC Password            = $rpc_pass_conf
RPC IP                  = $rpc_ip
RPC Host                = $rpc_port
EOF
            fi

            _pause return
            bash -c "${ronin_credentials_menu}"
            # press any key to return to menu
            # shows specter server credentials and returns to menu
            ;;
        8)
            _ui_backend_credentials && cd "$HOME" || exit
            cat <<EOF
${RED}
***
Displaying list of all available credentials in your RoninDojo...
***
${NC}
EOF
            _sleep 5 --msg "Displaying in "

            cat <<EOF
${RED}
***
Samourai Dojo Credentials
***

***
WARNING: Do not share these onion addresses with anyone!
***
${NC}

Maintenance Tool:
Tor V2 URL              = http://$v2_addr_dojo_api/admin
Tor V3 URL              = http://$v3_addr_dojo_api/admin
Admin Key               = $NODE_ADMIN_KEY
API Key                 = $NODE_API_KEY

${RED}
***
Samourai Whirlpool Credentials
***

***
WARNING: Do not share these onion addresses with anyone!
***
${NC}

Tor V2 URL              = http://$v2_addr_whirlpool
Tor V3 URL              = http://$v3_addr_whirlpool
Whirlpool API Key       = ${whirlpool_api_key:-Whirlpool not Initiated yet. Pair wallet with GUI}

${RED}
***
Ronin UI Backend Credentials
***
${NC}

Ronin API Key           =   ${API_KEY}
JWT SECRET              =   ${JWT_SECRET}
Port                    =   ${BACKEND_PORT}
Ronin URL               =   http://${BACKEND_TOR}

${RED}
***
Bitcoin Credentials
***
${NC}

Bitcoin Daemon:

Tor V2 URL              = http://$v2_addr_bitcoind
Tor V3 URL              = http://$v3_addr_bitcoind
RPC User                = $rpc_user_conf
RPC Password            = $rpc_pass_conf
RPC IP                  = $rpc_ip
RPC Host                = $rpc_port

Bitcoin RPC Explorer (No username required):
Tor V2 URL              = http://$v2_addr_explorer
Tor V3 URL              = http://$v3_addr_explorer
Password                = $EXPLORER_KEY
EOF
            if [ -f "${dojo_path_my_dojo}"/indexer/electrs.toml ]; then
                cat <<EOF
${RED}
***
Electrs Credentials
***
${NC}

Electrs Tor URL         = $v3_addr_electrs
EOF
            fi

            if _mempool_check ; then
                cat <<EOF
${RED}
***
Mempool Space Visualizer Credentials
***
${NC}
Mempool Tor URL         = http://${v3_addr_mempool}
EOF
            fi

            if _is_specter ; then
                cat <<EOF
${RED}
***
Specter Server Credentials
***
${NC}
Tor URL                 = http://$v3_addr_specter
RPC User                = $rpc_user_conf
RPC Password            = $rpc_pass_conf
RPC IP                  = $rpc_ip
RPC Host                = $rpc_port
EOF
            fi

            _pause return
            bash -c "${ronin_credentials_menu}"
            # press any key to return to menu
            # shows all credentials and returns to menu
            ;;
        9)
            ronin
            # returns to main menu
            ;;
esac