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
        bash -c "${RONIN_FIREWALL_MENU}"
        ;;
    2)
        cat <<EOF
${RED}
***
Prepare to type new password for ${USER}...
***
${NC}
EOF
        _sleep 2
        sudo passwd "${USER}"

        _pause return
        bash -c "${RONIN_SYSTEM_MENU2}"
        # user change password, returns to menu
        ;;
    3)
        cat <<EOF
${RED}
***
Prepare to type new password for ${USER}...
***
${NC}
EOF
        _sleep 2
        sudo passwd

        _pause return
        bash -c "${RONIN_SYSTEM_MENU2}"
        # root change password, returns to menu
        ;;
    4)
        cat <<EOF
${RED}
***
Locking Root User...
***
${NC}
EOF
        _sleep 2
        sudo passwd -l root
        bash -c "${RONIN_SYSTEM_MENU2}"
        # uses passwd to lock root user, returns to menu
        ;;
    5)
        cat <<EOF
${RED}
***
Unlocking Root User...
***
${NC}
EOF
        _sleep 2
        sudo passwd -u root
        bash -c "${RONIN_SYSTEM_MENU2}"
        # uses passwd to unlock root user, returns to menu
        ;;
    6)
        if ! _dojo_check; then
            _is_dojo bash -c "${RONIN_SYSTEM_MENU2}"
        fi
            # is dojo installed?

        cat <<EOF
${RED}
***
Uninstalling RoninDojo and all features, press Ctrl+C to exit if needed!
***
${NC}
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
${RED}
***
Uninstalling RoninDojo...
***
${NC}
EOF
        "${tor_backup}" && _tor_backup
        # tor backup must happen prior to dojo uninstall

        cd "$dojo_path_my_dojo" || exit
        ./dojo.sh uninstall
        # uninstall dojo

        "${dojo_conf_backup}" && _dojo_backup

        rm -rf "${DOJO_PATH}"

        # Returns HOME since $DOJO_PATH deleted
        cd "${HOME}" || exit

        sudo systemctl restart docker
        # restart docker daemon

        cd "${RONIN_UI_BACKEND_DIR}" || exit

        cat <<EOF
${RED}
***
Uninstalling Ronin UI Backend...
***
${NC}
EOF
        _sleep 2

        # Delete app from process list
        pm2 delete "Ronin Backend" &>/dev/null

        # dump all processes for resurrecting them later
        pm2 save 1>/dev/null

        # Remove ${RONIN_UI_BACKEND_DIR}
        cd "${HOME}" || exit
        rm -rf "${RONIN_UI_BACKEND_DIR}" || exit

        cat <<EOF
${RED}
***
Complete!
***
${NC}
EOF
        _sleep 2

        _pause return

        bash -c "${RONIN_SYSTEM_MENU2}"
        # return to menu
        ;;
    7)
        bash -c "${RONIN_SYSTEM_MENU}"
        # returns to menu
        ;;
esac