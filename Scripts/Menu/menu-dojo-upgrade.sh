#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

# Source update script
. "$HOME"/RoninDojo/Scripts/update.sh

# Create Updates history directory
test ! -d "$HOME"/.config/RoninDojo/data/updates && mkdir -p "$HOME"/.config/RoninDojo/data/updates

# Remove update file from a previous upgrade
test -f "$HOME"/.config/RoninDojo/data/updates/10-* && rm "$HOME"/.config/RoninDojo/data/updates/10-* &>/dev/null

# Migrate user.conf variables to lowercase
_update_10

# Fix any existing specter installs that are missing gcc dependency
_update_16

# Uninstall legacy Ronin UI
test -f "$HOME"/.config/RoninDojo/data/updates/17-* || _update_17

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

if _is_mempool; then
    _mempool_uninstall || exit
fi
# Check if mempool available or not, then uninstall it.

if [ -f /etc/systemd/system/whirlpool.service ] ; then
   sudo systemctl stop --quiet whirlpool

   cat <<EOF
${red}
***
Whirlpool will be installed via Docker...
***
${nc}

${red}
***
You will need to re-pair with GUI, see Wiki for more information...
***
${nc}
EOF
   _sleep 5
else
   cat <<EOF
${red}
***
Whirlpool will be installed via Docker...
***
${nc}

${red}
***
For pairing information see the wiki...
***
${nc}
EOF
   _sleep
fi
# stop whirlpool for existing whirlpool users

if _is_specter ; then
    _specter_upgrade || sed -i 's/  -disablewallet=.*$/  -disablewallet=0/' "${dojo_path_my_dojo}"/bitcoin/restart.sh
fi

if _is_bisq ; then
    _bisq_install
fi

cd "${dojo_path_my_dojo}" || exit

# Re-enable the indexer
_check_indexer
ret=$?

if ((ret==0)); then
    bash -c "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
elif ((ret==1)); then
    test -f "${dojo_path_my_dojo}"/indexer/electrs.toml && rm "${dojo_path_my_dojo}"/indexer/electrs.toml

    _set_indexer
fi

./dojo.sh upgrade --nolog
# run upgrade

# Source update script
. "$HOME"/RoninDojo/Scripts/update.sh

# Run _update_08
test -f "$HOME"/.config/RoninDojo/data/updates/08-* || _update_08 # Make sure mnt-usb.mount is available

_pause return

ronin
# return to menu