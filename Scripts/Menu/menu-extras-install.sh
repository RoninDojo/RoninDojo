#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

cmd=(dialog --title "RoninDojo" --separate-output --checklist "Use Mouse Click or Spacebar to select:" 22 76 16)
options=(1 "Install Mempool Space Visualizer" off    # any option can be set to default to "on"
         2 "Install Specter" off
         3 "Install Bisq Compatibility" off
         4 "Swap Electrs/Indexer" off
         5 "Finalize Changes" on
         5 "Go Back" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            if _is_mempool ; then
                _mempool_conf
                _mempool_urls_to_local_btc_explorer
            fi
            # checks for mempool... then installs
            ;;
        2)
            if ! _is_specter ; then
                _install_specter
            fi
            # runs dojo install script
            ;;
        3)
            if ! _is_bisq ; then
                _install_bisq
            fi
            # checks for bisq file and modifies restart.sh and creates file
            ;;
        4)
            if grep "INDEXER_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
                cat <<EOF
${RED}
***
Switching to SW Addrindexer
***
${NC}
EOF
                _sleep 5 --msg "Press Ctrl+C to exit...otherwise, switching in..."
                rm "${dojo_path_my_dojo}"/indexer/electrs.toml
                _set_addrindexer
            elif
                grep "INDEXER_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ ! -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
                cat <<EOF
${RED}
***
Switching to Electrs
***
${NC}
EOF
                _sleep 5 --msg "Press Ctrl+C to exit...otherwise, switching in..."
                bash -c "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
            else
                _no_indexer_found
            fi
            # check for which indexer, if no indexer ask if they want to install
            ;;
        5) 
            cat <<EOF
${RED}
***
Performing Local "upgrade" of Dojo to complete install process...
***
${NC}
EOF
            _sleep 5 --msg "Press Ctrl+C to exit...otherwise, upgrading Dojo in..."
            cd "${dojo_path_my_dojo}" || exit
            ./dojo.sh upgrade --nologs
            # upgrade dojo. default to on.
            ;;
        6)
            bash -c "$RONIN_EXTRAS_MENU"
            # return to extras menu
            ;;
    esac
done