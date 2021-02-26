#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

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
        _pacman_update_mirrors
        # Update Mirrors and continue.

        _pause return
        bash -c "${ronin_system_menu}"
        ;;
    2)
        if [ -f "${ronin_data_dir}"/ronin-latest.txt ] ; then
            rm "${ronin_data_dir}"/ronin-latest.txt
        fi

        wget --quiet https://ronindojo.io/downloads/ronindojo-version.txt -O "${ronin_data_dir}"/ronindojo-latest.txt

        version=$(<"${ronin_data_dir}"/ronindojo-latest.txt)

        if [[ "${ronindojo_version}" != "${version}" ]] ; then
            cat <<EOF
${red}
***
RoninDojo update is available!
***
${nc}
EOF
            _sleep 2
        else
            cat <<EOF
${red}
***
No update is available!
***
${nc}
EOF
            _sleep 2
        fi
        # check for Ronin update from site

        _pause return
        bash -c "${ronin_system_menu}"
        ;;

    3)
        if ! _dojo_check; then
            if [ ! -d "${dojo_path}" ]; then
                cat <<EOF
${red}
***
Missing ${dojo_path} directory, aborting update...
***
${nc}
EOF
                _sleep 2

                _pause return

                bash -c "${ronin_system_menu}"
                exit 1
            fi
        fi
        # is dojo installed?

        # Update Mirrors
        _pacman_update_mirrors

        cat <<EOF
${red}
***
Updating RoninDojo...
***
${nc}
EOF
        _sleep 2

        cat <<EOF
${red}
***
Use Ctrl+C to exit if needed!
***
${nc}
EOF
_sleep 10 --msg "Updating in"

        test -f "$HOME"/ronin-update.sh && sudo rm "$HOME"/ronin-update.sh
        # Remove old update file

        _ronindojo_update
        # see functions.sh

        if ! _ronin_ui_update_check; then
            cat <<EOF
${red}
***
Updating Ronin UI Backend...
***
${nc}
EOF
            _install_ronin_ui_backend
        fi
        # Check if UI Backend needs an update

        bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-upgrade.sh
        # upgrades dojo and returns to menu
        ;;
    4)
        bash -c "${ronin_system_menu}"
        # returns to main system menu
        ;;
esac