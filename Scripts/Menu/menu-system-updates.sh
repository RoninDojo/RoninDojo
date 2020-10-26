#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Upgrade Dojo"
         2 "Upgrade RoninDojo"
         3 "Update System Packages"
         4 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
    1)
        if ! _dojo_check "$DOJO_PATH"; then
            if [ ! -d "${DOJO_PATH%/docker/my-dojo}" ]; then
                cat <<DOJO
${RED}
***
Missing ${DOJO_PATH%/docker/my-dojo} directory! Returning to menu...
***
${NC}
DOJO
                _sleep 2
                bash -c "$RONIN_DOJO_MENU"
                exit 1
            fi
        fi
        # is dojo installed?

        bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-upgrade.sh
        # upgrades dojo and returns to menu
        ;;
	2)
        test -f "$HOME"/ronin-update.sh || sudo rm -f "$HOME"/ronin-update.sh
        # using -f here to avoid error output if "$HOME"/ronin-update.sh does not exist

        cat <<EOF
${RED}
***
Upgrading RoninDojo...
***
${NC}
EOF
        _sleep 2

        _update_ronin
        # see functions.sh
        ;;
	3)
        cat <<EOF
***
Checking for system updates...
***
${NC}
EOF
        _sleep 5

        sudo pacman -Syyu

        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-updates.sh
        # check for system updates, then return to menu
        ;;
    4)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system.sh
        # returns to main system menu
        ;;
esac