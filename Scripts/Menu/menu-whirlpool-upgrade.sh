#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh

CLI_OBJECT="$(curl -s 'https://raw.githubusercontent.com/Samourai-Wallet/whirlpool-runtimes/master/CLI.json' | jq -r '.CLI_API[([.CLI_API | keys[] | select(test("^[0-9]"))] | max)]')"
CLI_VERSION="$(jq -r '.CLI_VERSION' <<< "${CLI_OBJECT}")"
CLI_CHECKSUM="$(jq -r '.CLI_CHECKSUM' <<< "${CLI_OBJECT}")"
CLI_FILENAME="/home/${ronindojo_user}/whirlpool/whirlpool.jar"

sudo systemctl stop --quiet whirlpool
# stop whirlpool service

if [ "$(sha256sum "${CLI_FILENAME}" | awk '{print $1}')" != "${CLI_CHECKSUM}" ]; then
  echo "Corrupted/missing whirlpool binary, attempting to download..."
  if [ -f "${CLI_FILENAME}" ]; then
    rm "${CLI_FILENAME}";
  fi;
  wget --output-document="${CLI_FILENAME}" "https://github.com/Samourai-Wallet/whirlpool-client-cli/releases/download/${CLI_VERSION}/whirlpool-client-cli-${CLI_VERSION}-run.jar"
  if [ "$(sha256sum "${CLI_FILENAME}" | awk '{print $1}')" != "${CLI_CHECKSUM}" ]; then
    echo "Failed to correct corrupted/missing whirlpool binary.";
    _sleep 5 --msg "Returning to main menu in"
    ronin;
  fi;
fi;
# if the sha256 hash does not match then warn corrupted/missing
# download whirlpool cli using wget
# if sha256 hash does not match, warn it failed to correct

sudo systemctl start --quiet whirlpool
# start whirlpool