#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Update Operating System"
         2 "Update RoninDojo"
         3 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
    1)
        cat <<EOF
${RED}
***
Checking for operating system package updates...
***
${NC}
EOF
        _sleep 2

        sudo pacman -Syyu

        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-updates.sh
        # check for system updates, then return to menu
        ;;
    2)
        cat <<EOF
${RED}
***
Updating in 10s...
***
${NC}

${RED}
***
Use Ctrl+C to exit if needed!
***
${NC}
EOF
_sleep 10

        if [ ! -d "$HOME"/RoninDojo ]; then
            cat <<DOJO
${RED}
***
Missing ${HOME}/RoninDojo} directory, skipping! Returning to menu...
***
${NC}
DOJO
            _sleep 3
            bash -c "${RONIN_UPDATES_MENU}"
            exit 1

        fi
        # is ronindojo directory missing?

        test -f "$HOME"/ronin-update.sh || sudo rm -f "$HOME"/ronin-update.sh
        # using -f here to avoid error output if "$HOME"/ronin-update.sh does not exist

        cat <<EOF
${RED}
***
Updating RoninDojo...
***
${NC}
EOF
        _sleep 2

        _update_ronin
        # see functions.sh

        _install_ronin_ui_backend
        # update ronin ui backend

        if ! _dojo_check "$DOJO_PATH"; then
            if [ ! -d "${DOJO_PATH%/docker/my-dojo}" ]; then
                cat <<DOJO
${RED}
***
Missing ${DOJO_PATH%/docker/my-dojo} directory, skipping! Returning to menu...
***
${NC}
DOJO
                _sleep 3
                bash -c "${RONIN_SYSTEM_MENU}"
                exit 1
            fi
        fi
        # is dojo installed?

        bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-upgrade.sh
        # upgrades dojo and returns to menu
        ;;
    3)
        bash -c "${RONIN_UPDATES_MENU}"
        # returns to main system menu
        ;;
esac