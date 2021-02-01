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

Maintenance Tool        = http://$V3_ADDR_API/admin
Admin Key               = $NODE_ADMIN_KEY
API Key                 = $NODE_API_KEY
EOF
                _pause return
                bash -c "${RONIN_CREDENTIALS_MENU}"
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

Whirlpool Tor URL       = http://$V3_ADDR_WHIRLPOOL
Whirlpool API Key       = ${WHIRLPOOL_API_KEY:-Whirlpool not Initiated yet. Pair wallet with GUI}
EOF
            _pause return
            bash -c "${RONIN_CREDENTIALS_MENU}"
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

Electrs Tor URL         = $V3_ADDR_ELECTRS
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

            _pause return

            bash -c "${RONIN_CREDENTIALS_MENU}"
            # return to menu
            ;;
        4)
            if ! _mempool_check ; then
                cat <<EOF
${RED}
***
Mempool.space is not installed...
***
${NC}
EOF
                _sleep 2
                _pause return
                bash -c "${RONIN_CREDENTIALS_MENU}"
            else
                cat <<EOF
${RED}
***
Mempool Credentials
***

***
${NC}
Mempool Tor URL         =  http://${V3_ADDR_MEMPOOL}
EOF

                _pause return
                bash -c "${RONIN_CREDENTIALS_MENU}"
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
            bash -c "${RONIN_CREDENTIALS_MENU}"
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

Tor URL                 = http://$V3_ADDR_BITCOIN
RPC User                = $RPC_USER_CONF
RPC Password            = $RPC_PASS_CONF
RPC IP                  = $RPC_IP
RPC Host                = $RPC_PORT

Bitcoin RPC Explorer:

Tor URL                 = http://$V3_ADDR_EXPLORER (No username required)
Password                = $EXPLORER_KEY
EOF
            _pause return
            bash -c "${RONIN_CREDENTIALS_MENU}"
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
                _pause return

                bash -c "${RONIN_CREDENTIALS_MENU}"
            else
                cat <<EOF
${RED}
***
Specter Server Credentials
***
${NC}

Tor URL                 = http://$V3_ADDR_SPECTER
RPC IP                  = $RPC_IP
RPC Host                = $RPC_PORT
EOF
            fi

            _pause return
            bash -c "${RONIN_CREDENTIALS_MENU}"
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

Maintenance Tool        = http://$V3_ADDR_API/admin
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

Whirlpool Tor URL       = http://$V3_ADDR_WHIRLPOOL
Whirlpool API Key       = ${WHIRLPOOL_API_KEY:-Whirlpool not Initiated yet. Pair wallet with GUI}

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

Tor URL                 = http://$V3_ADDR_BITCOIN
RPC User                = $RPC_USER_CONF
RPC Password            = $RPC_PASS_CONF
RPC IP                  = $RPC_IP
RPC Host                = $RPC_PORT

Bitcoin RPC Explorer:

Tor URL                 = http://$V3_ADDR_EXPLORER (No username required)
Password                = $EXPLORER_KEY
EOF
            if [ -f "${dojo_path_my_dojo}"/indexer/electrs.toml ]; then
                cat <<EOF
${RED}
***
Electrs Credentials
***
${NC}

Electrs Tor URL         = $V3_ADDR_ELECTRS
EOF
            fi

            if _mempool_check ; then
                cat <<EOF
${RED}
***
Mempool Credentials
***
${NC}
Mempool Tor URL         = http://${V3_ADDR_MEMPOOL}
EOF
            fi

            if _is_specter ; then
                cat <<EOF
${RED}
***
Specter Server Credentials
***
${NC}
Tor URL                 = http://$V3_ADDR_SPECTER
RPC IP                  = $RPC_IP
RPC Host                = $RPC_PORT
EOF
            fi

            _pause return
            bash -c "${RONIN_CREDENTIALS_MENU}"
            # press any key to return to menu
            # shows all credentials and returns to menu
            ;;
        9)
            ronin
            # returns to main menu
            ;;
esac