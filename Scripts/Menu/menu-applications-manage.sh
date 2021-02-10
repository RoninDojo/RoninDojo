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

# Set Indexer Install State
_check_indexer
ret=$?

if ((ret==0)); then
    indexer_name="Electrum Rust Server"
elif ((ret==1)); then
    indexer_name="Samourai Indexer"
elif ((ret==2)); then
    indexer_name="Bitcoin Indexer"
fi

cmd=(dialog --title "RoninDojo" --separate-output --checklist "Use Mouse Click or Spacebar to select:" 22 76 16)
options=(1 "${mempool_text} Mempool Space Visualizer" off    # any option can be set to default to "on"
         2 "${specter_text} Specter" off
         3 "${bisq_text} Bisq Connection" off
         4 "${indexer_name}" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            if ! "${is_mempool_installed}" ; then
                cat <<EOF
${RED}
***
Installing Mempool Space Visualizer...
***
${NC}
EOF
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
            case "${indexer_name}" in
                "Samourai Indexer")
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
                    ;;
                "Electrum Rust Server")
                    cat <<EOF
${RED}
***
Installing Electrum Rust Server...
***
${NC}
EOF
                    _sleep 2

                    bash -c "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
                    ;;
                "Bitcoin Indexer")
                    cat <<EOF
${RED}
***
Select an indexer to use with RoninDojo...
***
${NC}
EOF
                    _indexer_prompt
                    # check for addrindexrs or electrs, if no indexer ask if they want to install
                    ;;
            esac

            upgrade=true
    esac
done

if $upgrade; then
    _dojo_upgrade
else
    bash -c "${RONIN_APPLICATIONS_MENU}"
fi