#!/bin/bash

#
# Check for installed package
#
find_pkg() {
    pacman -Q $1 >/dev/null && return 0

    return 1
}