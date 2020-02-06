#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
YELLOW='\033[1;33m'
# used for color with ${YELLOW}
NC='\033[0m'
# No Color

RPC_USER=$(sudo cat ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl | grep BITCOIND_RPC_USER= | cut -c 19-)
RPC_PASS=$(sudo cat ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl | grep BITCOIND_RPC_PASSWORD= | cut -c 23-)

###### Modify docker-indexer.conf.tpl to turn ON indexer ######
sudo sed -i '9d' ~/dojo/docker/my-dojo/conf/docker-indexer.conf.tpl
sudo sed -i '9i INDEXER_INSTALL=on' ~/dojo/docker/my-dojo/conf/docker-indexer.conf.tpl

###### Modify docker-node.conf to select local_indexer ######
sudo sed -i '25d' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl
sudo sed -i '25i NODE_ACTIVE_INDEXER=local_indexer' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl
sudo sed -i '25d' ~/dojo/docker/my-dojo/conf/docker-node.conf > /dev/null 2>&1
sudo sed -i '25i NODE_ACTIVE_INDEXER=local_indexer' ~/dojo/docker/my-dojo/conf/docker-node.conf > /dev/null 2>&1

##### Create electrs.toml file #####
touch ~/dojo/docker/my-dojo/indexer/electrs.toml
chmod 600 ~/dojo/docker/my-dojo/indexer/electrs.toml || exit 1
cat > ~/dojo/docker/my-dojo/indexer/electrs.toml <<EOF
cookie = "$RPC_USER:$RPC_PASS"
server_banner = "Welcome to your RoninDojo Electrs Server!"
EOF

#delete and replace tor restart.sh
# using the backslash \ along with sed insert command so that the spaces are not ignored
sudo sed -i '27G' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '28i if [ "$INDEXER_INSTALL" == "on" ]; then' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '29i \  tor_options+=(--HiddenServiceDir /var/lib/tor/hsv3electrs)' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '30i \  tor_options+=(--HiddenServiceVersion 3)' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '31i \  tor_options+=(--HiddenServicePort "50001 172.28.1.6:50001")' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '32i \  tor_options+=(--HiddenServiceDirGroupReadable 1)' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '33i fi' ~/dojo/docker/my-dojo/tor/restart.sh


# add indexer to tor section of docker-compose.yaml
# using the backslash \ along with sed insert command so that the spaces are not ignored
sudo sed -i '81i \      - ./conf/docker-indexer.conf' ~/dojo/docker/my-dojo/docker-compose.yaml


# sed commands to insert lines into dojo.sh for electrs
# using the backslash \ along with sed insert command so that the spaces are not ignored
sudo sed -i '224i \  if [ "$INDEXER_INSTALL" == "on" ]; then' ~/dojo/docker/my-dojo/dojo.sh
sudo sed -i '225i \    V3_ADDR_ELECTRS=$( docker exec -it tor cat /var/lib/tor/hsv3electrs/hostname )' ~/dojo/docker/my-dojo/dojo.sh
sudo sed -i '226i \    echo "Electrs hidden service address (v3) = $V3_ADDR_ELECTRS"' ~/dojo/docker/my-dojo/dojo.sh
sudo sed -i '227i \  fi' ~/dojo/docker/my-dojo/dojo.sh
sudo sed -i '227G' ~/dojo/docker/my-dojo/dojo.sh


#Modify indexer/restart.sh for Electrs
# using the backslash \ along with sed insert command so that the spaces are not ignored
sudo sed -i '9d' ~/dojo/docker/my-dojo/indexer/restart.sh
sudo sed -i '9i \  --electrum-rpc-addr="172.28.1.6:50001"' ~/dojo/docker/my-dojo/indexer/restart.sh
sudo sed -i '11d' ~/dojo/docker/my-dojo/indexer/restart.sh
sudo sed -i '21i electrs "${indexer_options[@]}"' ~/dojo/docker/my-dojo/indexer/restart.sh
sudo sed -i '22d' ~/dojo/docker/my-dojo/indexer/restart.sh


#Modify Indexer Dockerfile to Electrs
# change indexer version
sudo sed -i '4d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '4i ENV     INDEXER_VERSION     0.8.2' ~/dojo/docker/my-dojo/indexer/Dockerfile

# change indexer url
sudo sed -i '5d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '5i ENV     INDEXER_URL         https://github.com/romanz/electrs/archive' ~/dojo/docker/my-dojo/indexer/Dockerfile

# delete lines 16 & 17, and replace with new create data directory values (lines 16-19)
# using sed \ to not ignore spaces on 7i, 17i, 18i, and 19i
# using sed \\ to not ignore inserting a backslash on 7i, 17i, 18i, and 19i
# using sed 19G to add empty lines after
sudo sed -i '7d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '7i \        apt-get install -y clang cmake git wget && \\' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '16d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '17d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '16i RUN     mkdir "$INDEXER_HOME/electrs" && \\' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '17i \        mkdir "$INDEXER_HOME/db" && \\' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '18i \        chown -h indexer:indexer "$INDEXER_HOME/electrs" && \\' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '19i \        chown -h indexer:indexer "$INDEXER_HOME/db"' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '20d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '19G' ~/dojo/docker/my-dojo/indexer/Dockerfile

# copy electrs toml file
# using sed \ to not ignore spaces on 29i
# using sed \\ to not ignore inserting a backslash on 28i
# using sed 29G to add an empty lines after
sudo sed -i '26i # Copy electrs.toml' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '27i COPY    ./electrs.toml /electrs.toml' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '28i RUN     chown indexer:indexer /electrs.toml && \\' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '29i \        chmod 777 /electrs.toml' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '29G' ~/dojo/docker/my-dojo/indexer/Dockerfile

# install electrs
# using sed \ to not ignores spaces on 39i, 40i, and 41i
# using sed \\ to not ignore inserting a backslash on 39i, 40i, and 45i
# using sed G to add empty lines after 41G, 43G, 44G
sudo sed -i '37d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '37i # Install electrs' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '38i RUN     set -ex && \' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '39d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '39i \        wget -qO electrs.tar.gz "$INDEXER_URL/v$INDEXER_VERSION.tar.gz" && \\' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '40d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '40i \        tar -xzvf electrs.tar.gz -C "$INDEXER_HOME/electrs" --strip-components 1 && \\' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '41d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '41i \        rm electrs.tar.gz' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '43d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '43i USER    indexer' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '45d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '45i RUN     cd "$INDEXER_HOME/electrs" && \\' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '42d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '41G' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '43G' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '44G' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '45d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '45d' ~/dojo/docker/my-dojo/indexer/Dockerfile
sudo sed -i '46d' ~/dojo/docker/my-dojo/indexer/Dockerfile
