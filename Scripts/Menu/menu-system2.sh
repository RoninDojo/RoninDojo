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
Prepare to type new password for ${ronindojo_user}...
***
${nc}
EOF
        _sleep 2
        sudo passwd "${ronindojo_user}"

        _pause return
        bash -c "${ronin_system_menu2}"
        # user change password, returns to menu
        ;;
    3)
        cat <<EOF
${red}
***
Prepare to type new password for ${ronindojo_user}...
***
${nc}
EOF
        _sleep 2
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
        _sleep 2
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
        _sleep 2
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
Uninstalling RoninDojo and all features, press Ctrl+C to exit if needed!
***
${nc}
EOF
        _sleep 10 --msg "Uninstalling in"

        cd "$dojo_path_my_dojo" || exit
        _stop_dojo
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

        cd "$dojo_path_my_dojo" || exit
        ./dojo.sh uninstall
        # uninstall dojo

        "${dojo_conf_backup}" && _dojo_backup

        rm -rf "${dojo_path}"

        # Returns HOME since $dojo_path deleted
        cd "${HOME}" || exit

        sudo systemctl restart docker
        # restart docker daemon

        cd "${ronin_ui_backend_dir}" || exit

        cat <<EOF
${red}
***
Uninstalling Ronin UI Backend...
***
${nc}
EOF
        _sleep 2

        # Delete app from process list
        pm2 delete "Ronin Backend" &>/dev/null

        # dump all processes for resurrecting them later
        pm2 save 1>/dev/null

        # Remove ${ronin_ui_backend_dir}
        cd "${HOME}" || exit
        rm -rf "${ronin_ui_backend_dir}" || exit

        cat <<EOF
${red}
***
Complete!
***
${nc}
EOF
        _sleep 2

        _pause return

        bash -c "${ronin_system_menu2}"
        # return to menu
        ;;
    7)
        bash -c "${ronin_system_menu}"
        # returns to menu
        ;;
esac