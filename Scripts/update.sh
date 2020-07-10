#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/functions.sh

_update_01() {
    if ! _check_pkgver bridge-utils 1.7-1; then
        cat <<EOF
${RED}
***
Outdated and known broken version of bridge-utils found on your system
RoninDojo will upgade your package to latest version available
***
${NC}
EOF
        _sleep 5 --msg "Starting bridge-utils upgrade in"
        sudo pacman -U --noconfirm http://mirror.archlinuxarm.org/aarch64/extra/bridge-utils-1.7-1-aarch64.pkg.tar.xz &>/dev/null

        # If existing dojo found, then reboot system to apply changes
        if [ -d "${HOME}/dojo" ]; then
            cat <<EOF
${RED}
***
Existing dojo found! We will perform a reboot after 10secs.
Press Ctrl+C if you wish to skip this update now
***
${NC}
EOF
            _sleep 10 --msg "Rebooting in"
            sudo systemctl reboot
        fi
    fi
}