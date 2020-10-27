#!/bin/bash
# shellcheck source=/dev/null

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
         7 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
        cat <<MENU
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

Maintenance Tool            = http://$V3_ADDR_API/admin
Admin Key                   = $NODE_ADMIN_KEY
API Key                     = $NODE_API_KEY

${RED}
***
Press any key to return...
***
${NC}
MENU
            read -n 1 -r -s
            bash -c "$RONIN_CREDENTIALS_MENU"
            # press any key to return to menu
            # shows samouraio dojo credentials and returns to menu
            ;;
        2)
        cat <<MENU
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

Whirlpool Tor URL           = http://$V3_ADDR_WHIRLPOOL
Whirlpool API Key           = ${WHIRLPOOL_API_KEY:-Whirlpool not Initiated yet. Pair wallet with GUI}

${RED}
***
Press any key to return...
***
${NC}
MENU
        read -n 1 -r -s
        bash -c "$RONIN_CREDENTIALS_MENU"
        # press any key to return to menu
        # shows whirlpool credentials and returns to menu
        ;;
        3)
        if [ ! -f "${DOJO_PATH}"/indexer/electrs.toml ]; then
            echo -e "${RED}"
            echo "***"
            echo "Electrs is not installed!"
            echo "***"
            echo -e "${NC}"
            _sleep 2

            echo -e "${RED}"
            echo "***"
            echo "Returning to menu..."
            echo "***"
            echo -e "${NC}"
            _sleep
            bash -c "$RONIN_CREDENTIALS_MENU"
            exit
        fi
        # check if electrs is already installed

        cat <<MENU
${RED}
***
Electrs Credentials
***
${NC}

Electrs Tor URL = $V3_ADDR_ELECTRS
MENU
        _sleep
        # displaying electrs tor address to connect to electrum

        cat <<MENU
${RED}
***
Check the RoninDojo Wiki for pairing information at https://wiki.ronindojo.io
***

${RED}
***
Press any key to return...
***
${NC}
MENU
        read -n 1 -r -s
        bash -c "$RONIN_CREDENTIALS_MENU"
        # return to menu
        ;;
        4)
        cat << WHIRLPOOL
${RED}
***
Mempool Credentials
***

***
${NC}
Mempool Tor URL      = http://${V3_ADDR_MEMPOOL}
${RED}
***
Press any key to return...
***
${NC}
WHIRLPOOL
        read -n 1 -r -s
        bash -c "$RONIN_MEMPOOL_MENU"
        # press any key to return to menu
        # see defaults.sh
        ;;
        5)
        cd "${RONIN_UI_BACKEND_DIR}" || exit

        API_KEY=$(grep API_KEY .env|cut -d'=' -f2)
        JWT_SECRET=$(grep JWT_SECRET .env|cut -d'=' -f2)
        BACKEND_PORT=$(grep PORT .env|cut -d'=' -f2)
        BACKEND_TOR=$(sudo cat /var/lib/tor/hidden_service_ronin_backend/hostname)

        cat <<MENU
${RED}
***
Ronin UI Backend Credentials
***
${NC}

API_KEY     =   ${API_KEY}
JWT_SECRET  =   ${JWT_SECRET}
PORT        =   ${BACKEND_PORT}
TOR_ADDRESS =   http://${BACKEND_TOR}

${RED}
***
Press any key to return...
***
${NC}
MENU
        read -n 1 -r -s
        bash -c "$RONIN_CREDENTIALS_MENU"
        # shows Ronin UI Backend credentials, returns to menu
        ;;
        6)
        cat <<MENU
${RED}
***
Bitcoin Credentials
***
${NC}

Bitcoin Daemon:

Tor URL                 = http://$V2_ADDR_BITCOIN
RPC User                = $RPC_USER_CONF
RPC Password            = $RPC_PASS_CONF
RPC IP                  = $RPC_IP
RPC Host                = $RPC_PORT

Bitcoin RPC Explorer:

Tor URL                 = http://$V3_ADDR_EXPLORER (No username required)
Password                = $EXPLORER_KEY

${RED}
***
Press any key to return...
***
${NC}
MENU
        read -n 1 -r -s
        bash -c "$RONIN_CREDENTIALS_MENU"
        # press any key to return to menu
        # shows bitcoind and btc rpc explorer credentials and returns to menu
        ;;
        7)
        ronin
        # returns to main menu
        ;;
esac
