#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

_check_dojo_perms "${dojo_path_my_dojo}"
# make sure permissions are properly set for ${dojo_path_my_dojo}

if grep BITCOIND_RPC_EXTERNAL=off "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf 1>/dev/null; then
    sed -i 's/BITCOIND_RPC_EXTERNAL=.*$/BITCOIND_RPC_EXTERNAL=on/' "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf
fi
# enable BITCOIND_RPC_EXTERNAL

# Update Samourai Dojo repo
_dojo_update

cd "${HOME}" || exit
# return to previous working path

if ! _is_mempool; then
    _mempool_conf

    # Checks if urls need to be changed for mempool UI
    _mempool_urls_to_local_btc_explorer
fi
# Check if mempool available or not

if [ -f /etc/systemd/system/whirlpool.service ] ; then
   sudo systemctl stop whirlpool

   cat <<EOF
${RED}
***
Whirlpool will be installed via Docker...
***
${NC}

${RED}
***
You will need to re-pair with GUI, see Wiki for more information...
***
${NC}
EOF
   _sleep 5
else
   cat <<EOF
${RED}
***
Whirlpool will be installed via Docker...
***
${NC}

${RED}
***
For pairing information see the wiki...
***
${NC}
EOF
   _sleep 2
fi
# stop whirlpool for existing whirlpool users

if _is_specter ; then
    _specter_upgrade
fi

if _is_bisq ; then
    _install_bisq
fi

cd "${dojo_path_my_dojo}" || exit

./dojo.sh upgrade --nolog
# run upgrade

bash -c "$RONIN_UPDATES_MENU"
# return to menu