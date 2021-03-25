#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Disk Storage"
         2 "Power Off"
         3 "Reboot"
         4 "Software Updates"
         5 "System Monitoring"
         6 "System Setup & Install"
         7 "Next Page"
         8 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
    1)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-storage.sh
        # System storage menu
        ;;
    2)
        if [ -d "$HOME"/dojo ]; then
            cat <<EOF
${red}
***
Shutting down Dojo if running...
***
${nc}
EOF
            cd "${dojo_path_my_dojo}" || exit
            _dojo_check && _stop_dojo
            # stop dojo

            cat <<EOF
${red}
***
Powering off machine, or press Ctrl + C to cancel...
***
${nc}
EOF
            _sleep 1

            _pause continue
            sudo systemctl poweroff
            # power off machine
        else
            cat <<EOF
${red}
***
Powering off machine, or press Ctrl + C to cancel...
***
${nc}
EOF
            _sleep 1

            _pause continue
            sudo systemctl poweroff
            # power off machine
        fi
        ;;
    3)
        if [ -d "$HOME"/dojo ]; then
            cat <<EOF
${red}
***
Shutting down Dojo if running...
***
${nc}
EOF
            cd "${dojo_path_my_dojo}" || exit
            _dojo_check && _stop_dojo
            # stop dojo

            cat <<EOF
${red}
***
Restarting machine, or press Ctrl + C to cancel...
***
${nc}
EOF
            _sleep 1

            _pause continue
            sudo systemctl reboot
            # restart machine
        else
            cat <<EOF
${red}
***
Restarting machine, or press Ctrl + C to cancel...
***
${nc}
EOF
            _sleep 1

            _pause continue
            sudo systemctl reboot
            # restart machine
        fi
        ;;

    4)
        bash -c "${ronin_updates_menu}"
        # System updates menu
        ;;
    5)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-system-monitoring.sh
        # System monitoring menu
        ;;
    6)
        bash "$HOME"/RoninDojo/Scripts/Menu/menu-install.sh
        # System Setup & Install menu
        ;;
    7)
        bash -c "${ronin_system_menu2}"
        ;;
    8)
        ronin
        # returns to main menu
        ;;
esac