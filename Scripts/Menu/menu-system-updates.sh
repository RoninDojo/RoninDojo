#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(#1 "Update Operating System"
         1 "Update RoninDojo"
         2 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
#     1)
#         cat <<EOF
# ${RED}
# ***
# Checking for operating system package updates...
# ***
# ${NC}
# EOF
#         _sleep 2

#         sudo pacman -Syyu --noconfirm

#         bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-updates.sh
#         # check for system updates, then return to menu
#         ;;
    1)
        cat <<EOF
${RED}
***
Updating RoninDojo...
***
${NC}
EOF
        _sleep 2

        cat <<EOF
${RED}
***
Use Ctrl+C to exit if needed!
***
${NC}
EOF
_sleep 10 --msg "Updating in"

        if [ ! -d "$HOME"/RoninDojo ] || [ ! -d ${DOJO_PATH} ]; then
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

        test -f "$HOME"/ronin-update.sh && sudo rm "$HOME"/ronin-update.sh
        # Remove old update file

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

        if ! _dojo_check; then
            if [ ! -d "${DOJO_PATH}" ]; then
                cat <<DOJO
${RED}
***
Missing ${DOJO_PATH} directory, skipping! Returning to menu...
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
    2)
        bash -c "${RONIN_SYSTEM_MENU}"
        # returns to main system menu
        ;;
esac