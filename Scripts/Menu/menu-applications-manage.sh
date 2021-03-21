#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

upgrade=false

# Set mempool install/uninstall status
if ! _is_mempool; then
    is_mempool_installed=false
    mempool_text="Instalar"
else
    is_mempool_installed=true
    mempool_text="Desinstalar"
fi

# Set Specter install/uninstall status
if ! _is_specter; then
    is_specter_installed=false
    specter_text="Instalar"
else
    is_specter_installed=true
    specter_text="Desinstalar"
fi

# Set Bisq install/uninstall status
if ! _is_bisq; then
    is_bisq_installed=false
    bisq_text="Activar"
else
    is_bisq_installed=true
    bisq_text="Desactivar"
fi

# Set Indexer Install State
_check_indexer
ret=$?

if ((ret==0)); then
    indexer_name="Instalar Samourai indexador"
elif ((ret==1)); then
    indexer_name="Instalar Electrum indexador"
elif ((ret==2)); then
    indexer_name="Instalar el indexador"
fi

cmd=(dialog --title "RoninDojo" --separate-output --checklist "Use Mouse Click or Spacebar to select:" 22 76 16)
options=(1 "${mempool_text} visualizador de espacio en la Mempool" off    # any option can be set to default to "on"
         2 "${specter_text} Specter" off
         3 "${bisq_text} conexión con Bisq" off
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
Instalando visualizador de espacio en la Mempool...
***
${nc}
EOF
                _mempool_conf
                _mempool_urls_to_local_btc_explorer
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
Desinstalando el servidor de Specter...
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
                "Instalar Samourai indexador")
                    cat <<EOF
${red}
***
Cambiando al indexador de Samourai...
***
${nc}
EOF
                    _sleep

                    _uninstall_electrs_indexer

                    _set_indexer
                    ;;
                "Instalar Electrum indexador")
                    cat <<EOF
${red}
***
Cambiando al servidor de Electrum Rust...
***
${nc}
EOF
                    _sleep

                    bash -c "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
                    ;;
                "Instalar el Indexer")
                    cat <<EOF
${red}
***
Seleccione un indexador para usar con RoninDojo...
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