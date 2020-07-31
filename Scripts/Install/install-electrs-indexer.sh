#!/bin/bash
# shellcheck source=/dev/null disable=1004

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/generated-credentials.sh

RPC_USER=$(sudo grep BITCOIND_RPC_USER= "${DOJO_PATH}"/conf/docker-bitcoind.conf.tpl | cut -d '=' -f2)
RPC_PASS=$(sudo grep BITCOIND_RPC_PASSWORD= "${DOJO_PATH}"/conf/docker-bitcoind.conf.tpl | cut -d '=' -f2)

sudo sed -i 's/INDEXER_INSTALL=off/INDEXER_INSTALL=on/' "${DOJO_PATH}"/conf/docker-indexer.conf.tpl
sudo sed -i 's/NODE_ACTIVE_INDEXER=bitcoind/NODE_ACTIVE_INDEXER=local_indexer/'  "${DOJO_PATH}"/conf/docker-node.conf.tpl
# modify docker-indexer.conf.tpl to turn ON indexer then select local_indexer

cat > "${DOJO_PATH}"/indexer/electrs.toml <<EOF
cookie = "$RPC_USER:$RPC_PASS"
server_banner = "Welcome to your RoninDojo Electrs Server!"
EOF
chmod 600 "${DOJO_PATH}"/indexer/electrs.toml || exit 1
# create electrs.toml for electrs dockerfile

sudo sed -i '/\if \[ "\$EXPLORER_INSTALL\" \=\= \"on\" \]\; then/i\
if [ "$INDEXER_INSTALL" == "on" ]; then\
\  tor_options+=(--HiddenServiceDir /var/lib/tor/hsv3electrs)\
\  tor_options+=(--HiddenServiceVersion 3)\
\  tor_options+=(--HiddenServicePort "50001 172.28.1.6:50001")\
\  tor_options+=(--HiddenServiceDirGroupReadable 1)\
fi\
' "${DOJO_PATH}"/tor/restart.sh
# modify tor/restart.sh for electrs hidden service
# using the backslash \ along with sed insert command so that the spaces are not ignored
# we append everything above the EXPLORER if statement

sudo sed -i '/docker-tor.conf/i\      - ./conf/docker-indexer.conf' "${DOJO_PATH}"/docker-compose.yaml
# add indexer to tor section of docker-compose.yaml
# using the backslash \ along with sed insert command so that the spaces are not ignored

sudo sed -i '/onion() {/a\
\  if [ "$INDEXER_INSTALL" == "on" ]; then\
\    V3_ADDR_ELECTRS=$( docker exec -it tor cat /var/lib/tor/hsv3electrs/hostname )\
\    echo "Electrs hidden service address (v3) = $V3_ADDR_ELECTRS"\
\  fi\
' "${DOJO_PATH}"/dojo.sh
# modify dojo.sh for electrs
# using the backslash \ along with sed insert command so that the spaces are not ignored

sudo sed -i \
-e 's/--indexer-rpc-addr=.*$/--electrum-rpc-addr="172.28.1.6:50001"/' \
-e '/--cookie=.*$/d' \
-e 's/^addrindexrs .*$/electrs "${indexer_options[@]}"/' "${DOJO_PATH}"/indexer/restart.sh
# modify indexer/restart.sh for electrs

wget -O "${DOJO_PATH}"/indexer/Dockerfile https://code.samourai.io/Ronin/samourai-dojo/raw/feat_mydojo_local_indexer/docker/my-dojo/indexer/Dockerfile
# replace indexer dockerfile for electrs usage