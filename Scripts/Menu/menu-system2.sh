#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Firewall"
         2 "Change User Password"
         3 "Lock Root User"
         4 "Unlock Root User"
         5 "Uninstall RoninDojo"
         6 "Go Back")

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
Prepare to type new password...
***
${NC}
EOF
        _sleep 2
        sudo passwd

        cat <<EOF
${RED}
***
Returning to menu...
***
${NC}
EOF
        _sleep 2
        bash -c "${RONIN_SYSTEM_MENU2}"
        # user change password, returns to menu
        ;;
    3)
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
    4)
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
    5)
        if ! _dojo_check "$DOJO_PATH"; then
            _is_dojo bash -c "${RONIN_SYSTEM_MENU2}"
        fi
            # is dojo installed?

        cat <<EOF
${RED}
***
Uninstalling Dojo in 10s...
***
${NC}

${RED}
***
Users with a fully synced Blockchain should answer yes to salvage!
***
${NC}

${RED}
***
WARNING: Data will be lost if you answer no to salvage, use Ctrl+C to exit if needed!
***
${NC}
EOF
        _sleep 10

        cat <<EOF
${RED}
Do you want to salvage your Blockchain data? [Y/N]
${NC}
EOF
        while true; do
            read -rp "Y/N?: " yn
            case $yn in
                [Yy]* ) cat <<EOF
***
Copying block data to temporary directory...
***
${NC}
EOF
                        _sleep 2
                        cd "$DOJO_PATH" || exit
                        _stop_dojo
                        # stop dojo

                        test ! -d "${INSTALL_DIR_UNINSTALL}" && sudo mkdir "${INSTALL_DIR_UNINSTALL}"
                        # check if salvage directory exist

                        sudo mv -v "${DOCKER_VOLUME_BITCOIND}"/_data/{blocks,chainstate} "${INSTALL_DIR_UNINSTALL}"/
                        # copies blockchain data to uninstall-salvage to be used by the dojo install script
                        break;;
                [Nn]* ) break;;
                * ) printf "\nPlease answer yes or no.\n";;
            esac
        done

        "${DOJO_RESTORE}" && _dojo_backup
        "${TOR_RESTORE}" && _tor_backup

        cat <<EOF
${RED}
***
Uninstalling Dojo...
***
${NC}
EOF
        cd "$DOJO_PATH" || exit
        ./dojo.sh uninstall && sudo rm -rf "${DOJO_PATH%/docker/my-dojo}"
        cd "${HOME}" || exit
        # uninstall dojo

        sudo systemctl restart docker
        # restart docker daemon

        cat <<EOF
${RED}
***
Complete!
***
${NC}
EOF
        _sleep 5 --msg "Returning to menu in"

        bash -c "${RONIN_SYSTEM_MENU2}"
        # return to menu
        ;;
    6)
        bash -c "${RONIN_SYSTEM_MENU}"
        # returns to menu
        ;;
esac