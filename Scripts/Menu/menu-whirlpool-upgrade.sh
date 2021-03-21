#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
.  "$HOME"/RoninDojo/Scripts/functions.sh

CLI_OBJECT="$(curl -s 'https://raw.githubusercontent.com/Samourai-Wallet/whirlpool-runtimes/master/CLI.json' | jq -r '.CLI_API[([.CLI_API | keys[] | select(test("^[0-9]"))] | max)]')"
CLI_VERSION="$(jq -r '.CLI_VERSION' <<< "${CLI_OBJECT}")"
CLI_CHECKSUM="$(jq -r '.CLI_CHECKSUM' <<< "${CLI_OBJECT}")"
CLI_FILENAME="/home/${ronindojo_user}/whirlpool/whirlpool.jar"

sudo systemctl stop --quiet whirlpool
# stop whirlpool service

# if the sha256 hash does not match then warn corrupted/missing
# download whirlpool cli using wget
# if sha256 hash does not match, warn it failed to correct
if [ "$(sha256sum "${CLI_FILENAME}" | awk '{print $1}')" != "${CLI_CHECKSUM}" ]; then
    cat <<EOF
${red}
***
Binarios de Whirlpool corruptos o perdidos, intentando descargar...
***
${nc}
EOF

  if [ -f "${CLI_FILENAME}" ]; then
    rm "${CLI_FILENAME}"
  fi

  wget -q --output-document="${CLI_FILENAME}" "https://github.com/Samourai-Wallet/whirlpool-client-cli/releases/download/${CLI_VERSION}/whirlpool-client-cli-${CLI_VERSION}-run.jar"

  if [ "$(sha256sum "${CLI_FILENAME}" | awk '{print $1}')" != "${CLI_CHECKSUM}" ]; then
        cat <<EOF
${red}
***
Fallo al corregir binarios de Whirlpool corruptos o perdidos...
***
${nc}
EOF
    _sleep 5 --msg "Volviendo al menú principal en"
    ronin
  fi
fi

sudo systemctl start --quiet whirlpool
# start whirlpool