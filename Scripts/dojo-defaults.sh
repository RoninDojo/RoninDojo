#!/bin/bash
# shellcheck disable=SC2034

#
# Dojo Configuration Values
#
test -f "${dojo_path_my_dojo}"/conf/docker-node.conf && . "${dojo_path_my_dojo}"/conf/docker-node.conf

test -f "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf && . "${dojo_path_my_dojo}"/conf/docker-bitcoind.conf

test -f "${dojo_path_my_dojo}"/conf/docker-explorer.conf && . "${dojo_path_my_dojo}"/conf/docker-explorer.conf

# Whirlpool
if sudo test -f "${docker_volume_wp}"/_data/.whirlpool-cli/whirlpool-cli-config.properties; then
    whirlpool_api_key=$(sudo grep cli.apiKey "${docker_volume_wp}"/_data/.whirlpool-cli/whirlpool-cli-config.properties | cut -d '=' -f2)
fi

#
# Tor Hidden Service Addresses
#

# Bitcoind
if sudo test -d "${docker_volume_tor}"/_data/hsv3bitcoind; then
    v3_addr_bitcoind=$(sudo cat "${docker_volume_tor}"/_data/hsv3bitcoind/hostname)
fi

if sudo test -d "${docker_volume_tor}"/_data/hsv2bitcoind; then
    v2_addr_bitcoind=$(sudo cat "${docker_volume_tor}"/_data/hsv2bitcoind/hostname)
fi

# Bitcoin Explorer
if sudo test -d "${docker_volume_tor}"/_data/hsv3explorer; then
    v3_addr_explorer=$(sudo cat "${docker_volume_tor}"/_data/hsv3explorer/hostname)
fi

if sudo test -d "${docker_volume_tor}"/_data/hsv2explorer; then
    v2_addr_explorer=$(sudo cat "${docker_volume_tor}"/_data/hsv2explorer/hostname)
fi

# Dojo Maintanance Tool
if sudo test -d "${docker_volume_tor}"/_data/hsv3dojo; then
    v3_addr_dojo_api=$(sudo cat "${docker_volume_tor}"/_data/hsv3dojo/hostname)
fi

if sudo test -d "${docker_volume_tor}"/_data/hsv2dojo; then
    v2_addr_dojo_api=$(sudo cat "${docker_volume_tor}"/_data/hsv2dojo/hostname)
fi

# Electrum Server
if sudo test -d "${docker_volume_tor}"/_data/hsv3electrs; then
    v3_addr_electrs=$(sudo cat "${docker_volume_tor}"/_data/hsv3electrs/hostname)
fi

# Whirlpool
if sudo test -d "${docker_volume_tor}"/_data/hsv3whirlpool; then
    v3_addr_whirlpool=$(sudo cat "${docker_volume_tor}"/_data/hsv3whirlpool/hostname)
fi

if sudo test -d "${docker_volume_tor}"/_data/hsv2whirlpool; then
    v2_addr_whirlpool=$(sudo cat "${docker_volume_tor}"/_data/hsv2whirlpool/hostname)
fi

# Mempool Space Visualizer
if sudo test -d "${docker_volume_tor}"/_data/hsv3mempool; then
    v3_addr_mempool=$(sudo cat "${docker_volume_tor}"/_data/hsv3mempool/hostname)
fi

# Specter
shopt -s nullglob

for dir in "${HOME}"/specter*; do
    if [[ -d "${dir}" ]]; then
        v3_addr_specter=$(sudo cat "${install_dir_tor}"/specter_server/hostname)
    fi
done