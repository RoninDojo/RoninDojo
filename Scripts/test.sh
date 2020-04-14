#!/bin/bash

check_fstype() {
    local device="${1}"

    local type="$(lsblk -f ${device} | tail -1 | awk '{print$2}')"

    echo ${type}
}

fstype=$(check_fstype /dev/sda1)
echo $fstype