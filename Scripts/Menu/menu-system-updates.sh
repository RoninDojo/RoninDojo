#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(#1 "Update Operating System"
         1 "Update Mirrors"
         2 "Check for RoninDojo Update"
         3 "Update RoninDojo"
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
        sudo sed -i "s:^#IgnorePkg   =.*$:IgnorePkg   = tor docker docker-compose bridge-utils:" /etc/pacman.conf
        # Add selected packages to irnore during an upgrade

        sudo pacman -Syy
        # Update Mirrors and continue.
        ;;

    2)
        if [ -f "${INSTALL_DIR_USER}"/ronin-latest.txt ] ; then
            rm -rf "${INSTALL_DIR_USER}"/ronin-latest.txt
        fi
        wget --quiet https://ronindojo.io/downloads/ronindojo-version.txt -O "${INSTALL_DIR_USER}"/ronin-latest.txt
        LATEST_RONIN=$(cat ronindojo-latest.txt)
        
        if [[ "${VERSION}" != "${LATEST_RONIN}" ]] ; then
            cat <<EOF
${RED}
***
RoninDojo update available!
***
${NC}
EOF
            _sleep --msg 5 "Select Update RoninDojo from Menu. Returning in..."
        else
            cat <<EOF
${RED}
***
No Update available!
***
${NC}
EOF
            _sleep --msg "Returning to menu in ..."
        fi
        # check for Ronin update from site

        bash -c "${RONIN_SYSTEM_MENU}"
        ;;

    3)
        # Add selected packages to irnore during an upgrade
        sudo sed -i "s:^#IgnorePkg   =.*$:IgnorePkg   = tor docker docker-compose bridge-utils:" /etc/pacman.conf

        # Update Mirrors
        sudo pacman -Syy

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

        if [ ! -d "$HOME"/RoninDojo ] || [ ! -d "${DOJO_PATH}" ]; then
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

    4)
        bash -c "${RONIN_SYSTEM_MENU}"
        # returns to main system menu
        ;;
esac