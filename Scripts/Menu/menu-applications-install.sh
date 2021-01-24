#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

upgrade=false
cmd=(dialog --title "RoninDojo" --separate-output --checklist "Use Mouse Click or Spacebar to select:" 22 76 16)
options=(1 "Install Mempool Space Visualizer" off    # any option can be set to default to "on"
         2 "Install Specter" off
         3 "Enable Bisq Connection" off
         4 "Swap Electrs/Indexer" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            if _is_mempool ; then
                _mempool_conf
                _mempool_urls_to_local_btc_explorer
                upgrade=true
            fi
            # Checks for mempool, then installs
            ;;
        2)
            if ! _is_specter ; then
                _specter_install && upgrade=true
            else
                cat <<EOF
${RED}
***
Specter install detected...
***
${NC}
EOF
                _sleep 2
                cat <<EOF
${RED}
***
Updating to latest version...
***
${NC}
EOF
                _sleep 2
                _specter_upgrade && upgrade=true
            fi
            # Runs dojo install script
            ;;
        3)
            if ! _is_bisq ; then
                _install_bisq && upgrade=true
            fi
            # Checks for bisq file and modifies restart.sh and creates file
            ;;
        4)
            if grep "INDEXER_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
                cat <<EOF
${RED}
***
Switching to Samourai indexer...
***
${NC}
EOF
                _sleep 2
                rm "${dojo_path_my_dojo}"/indexer/electrs.toml
                _set_addrindexer
            elif
                grep "INDEXER_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ ! -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
                cat <<EOF
${RED}
***
Switching to Electrum Rust Server...
***
${NC}
EOF
                _sleep 2
                bash -c "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
            else
                _no_indexer_found
            fi
            # check for which indexer, if no indexer ask if they want to install
            upgrade=true
            ;;
    esac
done

if $upgrade; then
    _dojo_upgrade
else
    cat <<EOF
${RED}
***
Nothing to install...
***
${NC}
EOF
    _pause return
    ronin
fi