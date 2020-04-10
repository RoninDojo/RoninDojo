#!/bin/bash

USER=$(sudo cat /etc/passwd | grep 1000 | awk -F: '{ print $1}' | cut -c 1-)
CLI_OBJECT="$(curl -s 'https://raw.githubusercontent.com/Samourai-Wallet/whirlpool-runtimes/master/CLI.json' | jq -r '.CLI_API[([.CLI_API | keys[] | select(test("^[0-9]"))] | max)]')"
CLI_VERSION="$(jq -r '.CLI_VERSION' <<< "${CLI_OBJECT}")"
CLI_CHECKSUM="$(jq -r '.CLI_CHECKSUM' <<< "${CLI_OBJECT}")"
CLI_FILENAME="/home/$USER/whirlpool/whirlpool.jar"

sudo systemctl stop whirlpool > /dev/null 2>&1

if [ "$(sha256sum "${CLI_FILENAME}" | awk '{print $1}')" != "${CLI_CHECKSUM}" ]; then
  echo "Corrupted/missing whirlpool binary, attempting to download..."
  if [ -f "${CLI_FILENAME}" ]; then
    rm "${CLI_FILENAME}";
  fi;
  wget --output-document="${CLI_FILENAME}" "https://github.com/Samourai-Wallet/whirlpool-client-cli/releases/download/${CLI_VERSION}/whirlpool-client-cli-${CLI_VERSION}-run.jar"
  if [ "$(sha256sum "${CLI_FILENAME}" | awk '{print $1}')" != "${CLI_CHECKSUM}" ]; then
    echo "Failed to correct corrupted/missing whirlpool binary.";
    exit 1;
  fi;
fi;

sudo systemctl start whirlpool
