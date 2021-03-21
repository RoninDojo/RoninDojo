#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/generated-credentials.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

if ! findmnt "${install_dir}" 1>/dev/null; then
    cat <<EOF
${red}
***
El disco montado no se encuentra disponible en ${INSTALL_DIR}! Para más información, por favor contacte con asistencia técnica.
***
${nc}
EOF
    _sleep
    cat <<EOF
${red}
***
Saliendo de RoninDojo en 5 segundos...
***
${nc}
EOF
    _sleep
    _pause volver
    exit 1
fi

if [ -d "${dojo_path_my_dojo}" ]; then
    cat <<EOF
${red}
***
RoninDojo ya está instalado...
***
${nc}
EOF
    _sleep
    _pause volver
    ronin
    exit
fi
# Makes sure RoninDojo has been uninstalled

cat <<EOF
${red}
***
Aplicando la instalación de RoninDojo...
***
${nc}
EOF
_sleep

cat <<EOF
${red}
***
Puedes pulsar Ctrl+C si necesitas salir ahora!
***
${nc}
EOF
_sleep 10 --msg "Instalando en"

cat <<EOF
${red}
***
Descargando y extrayendo la última version de RoninDojo...
***
${nc}
EOF

cd "$HOME" || exit
git clone -q -b "${samourai_commitish#*/}" "$samourai_repo" dojo 2>/dev/null

# Switch over to a branch if in detached state. Usually this happens
# when you clone a tag instead of a branch
cd "${dojo_path}" || exit

_git_ref_type
_ret=$?

if ((_ret==3)); then
    # valid branch
    git switch -q -c "${samourai_commitish}" -t "${samourai_commitish}"
else
    # valid tag
    git checkout -q -b "${samourai_commitish}" "${samourai_commitish}"
fi

cat <<EOF
${red}
***
Las credenciales necesarias para los nombres de usuario, contraseñas, etc. serán creadas al azar ahora...
***
${nc}
EOF
_sleep 4

cat <<EOF
${red}
***
Las credenciales se encuentran en el menu de RoninDojo, ${dojo_path_my_dojo}/conf, o en ~/RoninDojo/user.conf.example file...
***
${nc}
EOF
_sleep 4

cat <<EOF
${red}
***
Recuerda que estas credenciales son para acceder a la herramienta de mantenimiento de Dojo, Explorador de Blocks, y más!
***
${nc}
EOF
_sleep 4

cat <<EOF
${red}
***
Ajustando el RCP Usuario y Contraseña...
***
${nc}
EOF
_sleep

if [ -d "${dojo_backup_dir}" ]; then
    if ! _dojo_restore; then
        cat <<EOF
${red}
***
Deshabilitada la restauración de la copia de seguridad!
***
${nc}
EOF
        _sleep

        cat <<EOF
${red}
***
Habilita user.conf si deseas restaurar las credenciales en la instalación de dojo cuando esten disponibles...
***
${nc}
EOF
        _sleep 3
    else
        cat <<EOF
${red}
***
La copia de seguridad de las credenciales ha sido detectada y restaurada...
***
${nc}
EOF
        _sleep

        cat <<EOF
${red}
***
Si deseas deshabilitar esta opción, configura DOJO_RESTORE=false en el archivo $HOME/.config/RoninDojo/user.conf ...
***
${nc}
EOF
        _sleep 3
    fi
else
    cat <<EOF
${red}
***
Configurando el servidor daemon de bitcoin...
***
${nc}
EOF
    _sleep
    sed -i -e "s/BITCOIND_RPC_USER=.*$/BITCOIND_RPC_USER=${BITCOIND_RPC_USER:-$rpc_user}/" \
      -e "s/BITCOIND_RPC_PASSWORD=.*$/BITCOIND_RPC_PASSWORD=${BITCOIND_RPC_PASSWORD:-$rpc_pass}/" \
      -e "s/BITCOIND_RPC_THREADS.*$/BITCOIND_RPC_THREADS=${BITCOIND_RPC_THREADS:-16}/" \
      -e "s/BITCOIND_DB_CACHE=.*$/BITCOIND_DB_CACHE=${BITCOIND_DB_CACHE:-$(_mem_total "${bitcoind_db_cache_total}")}/" \
      -e "s/BITCOIND_MAX_MEMPOOL=.*$/BITCOIND_MAX_MEMPOOL=${BITCOIND_MAX_MEMPOOL:-2048}/" \
      -e "s/BITCOIND_RPC_EXTERNAL_IP=.*$/BITCOIND_RPC_EXTERNAL_IP=${BITCOIND_RPC_EXTERNAL_IP:-127.0.0.1}/" "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf.tpl
      # populate docker-bitcoind.conf.tpl template

    cat <<EOF
${red}
***
Configurando el contenedor Nodejs...
***
${nc}
EOF
    _sleep

    sed -i -e "s/NODE_API_KEY=.*$/NODE_API_KEY=${NODE_API_KEY}/" \
      -e "s/NODE_ADMIN_KEY=.*$/NODE_ADMIN_KEY=${NODE_ADMIN_KEY}/" \
      -e "s/NODE_JWT_SECRET=.*$/NODE_JWT_SECRET=${NODE_JWT_SECRET}/" \
      -e "s/NODE_ACTIVE_INDEXER=.*$/NODE_ACTIVE_INDEXER=${NODE_ACTIVE_INDEXER:-local_bitcoind}/" "${dojo_path_my_dojo}"/conf/docker-node.conf.tpl
    # populate docker-node.conf.tpl template

    sed -i -e "s/MYSQL_ROOT_PASSWORD=.*$/MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}/" \
      -e "s/MYSQL_USER=.*$/MYSQL_USER=${MYSQL_USER}/" \
      -e "s/MYSQL_PASSWORD=.*$/MYSQL_PASSWORD=${MYSQL_PASSWORD}/" "${dojo_path_my_dojo}"/conf/docker-mysql.conf.tpl
    # populate docker-mysql.conf.tpl template

    cat <<EOF
${red}
***
Configurando el explorador BTC RCP...
***
${nc}
EOF
    _sleep

    sed -i -e "s/EXPLORER_INSTALL=.*$/EXPLORER_INSTALL=${EXPLORER_INSTALL:-on}/" \
      -e "s/EXPLORER_KEY=.*$/EXPLORER_KEY=${EXPLORER_KEY}/" "${dojo_path_my_dojo}"/conf/docker-explorer.conf.tpl
    # populate docker-explorer.conf.tpl template
fi

_check_indexer

if (($?==2)); then
    # No indexer found, fresh install
    # Enable default samourai indexer unless dojo_indexer="electrs-indexer" set in user.conf
    _set_indexer

    # Enable Electrs indexer
    if [ "${dojo_indexer}" = "electrs-indexer" ]; then
        bash "$HOME"/RoninDojo/Scripts/Install/install-electrs-indexer.sh
    fi
fi

cat <<EOF
${red}
***
Por favor hecha un vistazo a la Wiki en FAQ, ayuda, y mucho más...
***
${nc}
EOF
_sleep 3

cat <<EOF
${red}
***
https://wiki.ronindojo.io
***
${nc}
EOF
_sleep 3

cat <<EOF
${red}
***
Instalando Dojo para la cartera "Samourai Wallet"...
***
${nc}
EOF
_sleep

# Restart docker here for good measure
sudo systemctl restart --quiet docker

cd "$dojo_path_my_dojo" || exit

if ./dojo.sh install --nolog --auto; then
    cat <<EOF
${red}
***
Todas las opciones de RoninDojo han sido instaladas...
***
${nc}
EOF
    # Make sure to wait for user interaction before continuing
    _pause continue

    # Backup dojo credentials
    "${dojo_conf_backup}" && _dojo_backup

    # Restore any saved IBD from a previous uninstall
    "${dojo_data_bitcoind_backup}" && _dojo_data_bitcoind restore

    # Restore any saved indexer data from a previous uninstall
    "${dojo_data_indexer_backup}" && _dojo_data_indexer restore

    if ${tor_backup}; then
        _tor_restore
        docker restart tor 1>/dev/null
    fi
    # restore tor credentials backup to container

    # Installing SW Toolkit

    if [ ! -d "${HOME}"/boltzmann ]; then
        cat <<EOF
${red}
***
Instalando Boltzmann Calculator...
***
${nc}
EOF
        _sleep

        # install Boltzmann
        _install_boltzmann
    fi

    if [ ! -d "${HOME}"/Whirlpool-Stats-Tool ]; then
        cat <<EOF
${red}
***
Instalando Whirlpool Stat Tool...
***
${nc}
EOF
        _sleep

        _install_wst
    fi

    # Source update script
    . "$HOME"/RoninDojo/Scripts/update.sh

    # Run _update_08
    test -f "$HOME"/.config/RoninDojo/data/updates/08-* || _update_08 # Make sure mnt-usb.mount is available

    # Press to continue to prevent from snapping back to menu too quickly
    _pause volver
else
        cat <<EOF
${red}
***
La instalación ha fallado! Por favor contacte con asistencia técnica...
***
${nc}
EOF

        _pause volver
        ronin
fi