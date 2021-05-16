#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Firewall"
         2 "Change User Password"
         3 "Change Root Password"
         4 "Lock Root User"
         5 "Unlock Root User"
         6 "Uninstall RoninDojo"
         7 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
    1)
        bash -c "${ronin_firewall_menu}"
        ;;
    2)
        cat <<EOF
${red}
***
Prepare to type new password for ${ronindojo_user} user...
***
${nc}
EOF
        _sleep
        sudo passwd "${ronindojo_user}"

        _pause return
        bash -c "${ronin_system_menu2}"
        # user change password, returns to menu
        ;;
    3)
        cat <<EOF
${red}
***
Prepare to type new password for root user...
***
${nc}
EOF
        _sleep
        sudo passwd

        _pause return
        bash -c "${ronin_system_menu2}"
        # root change password, returns to menu
        ;;
    4)
        cat <<EOF
${red}
***
Locking Root User...
***
${nc}
EOF
        _sleep
        sudo passwd -l root
        bash -c "${ronin_system_menu2}"
        # uses passwd to lock root user, returns to menu
        ;;
    5)
        cat <<EOF
${red}
***
Unlocking Root User...
***
${nc}
EOF
        _sleep
        sudo passwd -u root
        bash -c "${ronin_system_menu2}"
        # uses passwd to unlock root user, returns to menu
        ;;
    6)
        if ! _dojo_check; then
            _is_dojo bash -c "${ronin_system_menu2}"
        fi
            # is dojo installed?

        cat <<EOF
${red}
***
Uninstalling RoninDojo, press Ctrl+C to exit if needed!
***
${nc}
EOF
        _sleep 10 --msg "Uninstalling in"

        cd "$dojo_path_my_dojo" || exit
        _dojo_check && _stop_dojo
        # stop dojo

        # Backup Bitcoin Blockchain Data
        "${dojo_data_bitcoind_backup}" && _dojo_data_bitcoind backup

        # Backup Indexer Data
        "${dojo_data_indexer_backup}" && _dojo_data_indexer backup

        cat <<EOF
${red}
***
Uninstalling RoninDojo...
***
${nc}
EOF
        "${tor_backup}" && _tor_backup
        # tor backup must happen prior to dojo uninstall

        # Check if applications need to be uninstalled
        _is_specter && _specter_uninstall

        _is_bisq && _bisq_uninstall

        _is_mempool && _mempool_uninstall

        _is_ronin_ui && _ronin_ui_uninstall

        _is_fan_control && _fan_control_uninstall

        if [ -d "${HOME}"/Whirlpool-Stats-Tool ]; then
            cd "${HOME}"/Whirlpool-Stats-Tool || exit

            cat <<EOF
${red}
***
Uninstalling Whirlpool Stats Tool...
***
${nc}
EOF
            pipenv --rm &>/dev/null
            cd - 1>/dev/null || exit
            rm -rf "${HOME}"/Whirlpool-Stats-Tool
        fi

        if [ -d "${HOME}"/boltzmann ]; then
            cd "${HOME}"/boltzmann || exit

            cat <<EOF
${red}
***
Uninstalling Bolzmann...
***
${nc}
EOF
            pipenv --rm &>/dev/null
            cd - 1>/dev/null || exit
            rm -rf "${HOME}"/boltzmann
        fi

        cat <<EOF
${red}
***
Removing Samourai Dojo Server...
***
${nc}
EOF

        cd "$dojo_path_my_dojo" || exit
        if ./dojo.sh uninstall; then
            # uninstall dojo

            "${dojo_conf_backup}" && _dojo_backup

            rm -rf "${dojo_path}"

            # Returns HOME since $dojo_path deleted
            cd "${HOME}" || exit

            sudo systemctl restart --quiet docker
            # restart docker daemon

            cat <<EOF
${red}
***
All RoninDojo features has been Uninstalled...
***
${nc}
EOF
            _sleep
        fi

        _pause return

        bash -c "${ronin_system_menu2}"
        # return to menu
        ;;
    7)
        bash -c "${ronin_system_menu}"
        # returns to menu
        ;;
esac