#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh


upgrade=false

# Set mempool install/uninstall status
if ! _is_mempool; then
    is_mempool_installed=false
    mempool_text="Install"
else
    is_mempool_installed=true
    mempool_text="Uninstall"
fi

# Set Specter install/uninstall status
if ! _is_specter; then
    is_specter_installed=false
    specter_text="Install"
else
    is_specter_installed=true
    specter_text="Uninstall"
fi
_is_bisq

# Set Bisq install/uninstall status
if ! _is_bisq; then
    is_bisq_installed=false
    bisq_text="Enable"
else
    is_bisq_installed=true
    bisq_text="Disable"
fi

cmd=(dialog --title "RoninDojo" --separate-output --checklist "Use Mouse Click or Spacebar to select:" 22 76 16)
options=(1 "${mempool_text} Mempool Space Visualizer" off    # any option can be set to default to "on"
         2 "${specter_text} Specter" off
         3 "${bisq_text} Bisq Connection" off
         4 "Swap Electrs/Indexer" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            if ! "${is_mempool_installed}" ; then
                _mempool_conf
                _mempool_urls_to_local_btc_explorer
                upgrade=true
            else
                cat <<EOF
${RED}
***
Uninstalling Mempool Space Visualizer...
***
${NC}
EOF
                sed -i 's/MEMPOOL_INSTALL=.*$/MEMPOOL_INSTALL=off/' "$dojo_path_my_dojo"/conf/docker-mempool.conf
                # Turns mempool install set to off
                upgrade=true

                cat <<EOF
${RED}
***
Mempool Space Visualizer Uninstalled...
***
${NC}
EOF
            fi
            # Checks for mempool, then installs
            ;;
        2)
            if ! "${is_specter_installed}" ; then # Fresh install
                _specter_install && upgrade=true
            else
                _specter_uninstall
                upgrade=true

                cat <<EOF
${RED}
***
Specter Server Uninstalled...
***
${NC}
EOF
            fi
            ;;
        3)
            if ! "${is_bisq_installed}" ; then
                _install_bisq && upgrade=true
            else
                cat <<EOF
${RED}
***
Disabling Bisq Support...
***
${NC}
EOF
                rm "${ronin_data_dir}"/bisq.txt
                # Deletes bisq.txt file

                upgrade=true
            fi
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
                cat <<EOF
${RED}
***
Select an indexer to use with RoninDojo...
***
${NC}
EOF
                _indexer_prompt
            fi
            # check for addrindexrs or electrs, if no indexer ask if they want to install

            upgrade=true
            ;;
    esac
done

if $upgrade; then
    _dojo_upgrade
else
    bash -c "${RONIN_APPLICATIONS_MENU}"
fi