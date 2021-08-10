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
    indexer_name="Install Samourai Indexer"
elif ((ret==1)); then
    indexer_name="Install Electrum Indexer"
elif ((ret==2)); then
    indexer_name="Install Indexer"
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
${red}
***
Installing Mempool Space Visualizer...
***
${nc}
EOF
                _mempool_conf
            else
                _mempool_uninstall || exit
            fi
            # Checks for mempool, then installs

            upgrade=true
            ;;
        2)
            if ! "${is_specter_installed}" ; then # Fresh install
                _specter_install
            else
                _specter_uninstall

                cat <<EOF
${red}
***
Specter Server Uninstalled...
***
${nc}
EOF
            fi

            upgrade=true
            ;;
        3)
            if ! "${is_bisq_installed}" ; then
                _bisq_install
            else
                _bisq_uninstall
            fi

            upgrade=true
            ;;
        4)
            case "${indexer_name}" in
                "Install Samourai Indexer")
                    cat <<EOF
${red}
***
Switching to Samourai indexer...
***
${nc}
EOF
                    _sleep

                    _uninstall_electrs_indexer

                    _set_indexer
                    ;;
                "Install Electrum Indexer")
                    cat <<EOF
${red}
***
Installing Electrum Rust Server...
***
${nc}
EOF
                    _sleep

                    bash -c "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
                    ;;
                "Install Indexer")
                    cat <<EOF
${red}
***
Select an indexer to use with RoninDojo...
***
${nc}
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
    bash -c "${ronin_applications_menu}"
fi

exit