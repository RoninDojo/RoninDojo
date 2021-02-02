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
            if ! _is_specter ; then # Fresh install
                _specter_install && upgrade=true
            else # Checks for update
                _sleep 2
                _specter_upgrade && upgrade=true
            fi
            ;;
        3)
            if ! _is_bisq ; then
                _install_bisq && upgrade=true
            fi
            # Checks for bisq file and modifies restart.sh and creates file
            ;;
        4)
            _check_indexer
            ret=$?

            if ((ret==0)); then
                cat <<EOF
${RED}
***
Switching to Samourai indexer...
***
${NC}
EOF
                _sleep 2

                _uninstall_electrs_indexer

                _set_indexer
            elif ((ret==1)); then
                cat <<EOF
${RED}
***
Switching to Electrum Rust Server...
***
${NC}
EOF
                _sleep 2

                bash -c "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
            elif ((ret==2)); then
                _indexer_prompt
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