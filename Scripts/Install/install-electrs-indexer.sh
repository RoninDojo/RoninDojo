#!/bin/bash

RPC_USER=$(sudo cat ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl | grep BITCOIND_RPC_USER= | cut -c 19-)
RPC_PASS=$(sudo cat ~/dojo/docker/my-dojo/conf/docker-bitcoind.conf.tpl | grep BITCOIND_RPC_PASSWORD= | cut -c 23-)

###### Modify docker-indexer.conf.tpl to turn ON indexer ######
sudo sed -i '9d' ~/dojo/docker/my-dojo/conf/docker-indexer.conf.tpl
sudo sed -i '9i INDEXER_INSTALL=on' ~/dojo/docker/my-dojo/conf/docker-indexer.conf.tpl

###### Modify docker-node.conf to select local_indexer ######
sudo sed -i '25d' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl
sudo sed -i '25i NODE_ACTIVE_INDEXER=local_indexer' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl

###### Create electrs.toml for Electrs Dockerfile ######
# use EOF to put lines one after another

touch ~/dojo/docker/my-dojo/indexer/electrs.toml
chmod 600 ~/dojo/docker/my-dojo/indexer/electrs.toml || exit 1 
cat > ~/dojo/docker/my-dojo/indexer/electrs.toml <<EOF
cookie = "$RPC_USER:$RPC_PASS"
server_banner = "Welcome to your RoninDojo Electrs Server!"
EOF

###### Modify tor/restart.sh for Electrs HiddenService ######
# using the backslash \ along with sed insert command so that the spaces are not ignored
sudo sed -i '27G' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '28i if [ "$INDEXER_INSTALL" == "on" ]; then' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '29i \  tor_options+=(--HiddenServiceDir /var/lib/tor/hsv3electrs)' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '30i \  tor_options+=(--HiddenServiceVersion 3)' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '31i \  tor_options+=(--HiddenServicePort "50001 172.28.1.6:50001")' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '32i \  tor_options+=(--HiddenServiceDirGroupReadable 1)' ~/dojo/docker/my-dojo/tor/restart.sh
sudo sed -i '33i fi' ~/dojo/docker/my-dojo/tor/restart.sh


###### Add indexer to tor section of docker-compose.yaml ######
# using the backslash \ along with sed insert command so that the spaces are not ignored
sudo sed -i '80i \      - ./conf/docker-indexer.conf' ~/dojo/docker/my-dojo/docker-compose.yaml


###### Modify dojo.sh for electrs ######
# using the backslash \ along with sed insert command so that the spaces are not ignored
sudo sed -i '224i \  if [ "$INDEXER_INSTALL" == "on" ]; then' ~/dojo/docker/my-dojo/dojo.sh
sudo sed -i '225i \    V3_ADDR_ELECTRS=$( docker exec -it tor cat /var/lib/tor/hsv3electrs/hostname )' ~/dojo/docker/my-dojo/dojo.sh
sudo sed -i '226i \    echo "Electrs hidden service address (v3) = $V3_ADDR_ELECTRS"' ~/dojo/docker/my-dojo/dojo.sh
sudo sed -i '227i \  fi' ~/dojo/docker/my-dojo/dojo.sh
sudo sed -i '227G' ~/dojo/docker/my-dojo/dojo.sh


###### Modify indexer/restart.sh for Electrs ######
# using the backslash \ along with sed insert command so that the spaces are not ignored
sudo sed -i '9d' ~/dojo/docker/my-dojo/indexer/restart.sh
sudo sed -i '9i \  --electrum-rpc-addr="172.28.1.6:50001"' ~/dojo/docker/my-dojo/indexer/restart.sh
sudo sed -i '11d' ~/dojo/docker/my-dojo/indexer/restart.sh
sudo sed -i '21i electrs "${indexer_options[@]}"' ~/dojo/docker/my-dojo/indexer/restart.sh
sudo sed -i '22d' ~/dojo/docker/my-dojo/indexer/restart.sh


###### Modify Indexer Dockerfile to Electrs ######
sudo rm -rf ~/dojo/docker/my-dojo/indexer/Dockerfile
cd ~/dojo/docker/my-dojo/indexer
wget https://code.samourai.io/Ronin/samourai-dojo/raw/feat_mydojo_local_indexer/docker/my-dojo/indexer/Dockerfile
