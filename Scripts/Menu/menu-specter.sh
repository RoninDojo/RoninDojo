#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Start"
         2 "Stop"
         3 "Restart"
         4 "Status"
         5 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
    1)
        if _is_active specter; then
            cat <<EOF
${red}
***
Starting Specter Service...
***
${nc}
EOF
        fi

        _sleep

        _pause return
        bash -c "${ronin_specter_menu}"
        # Start specter.service and return to same menu
        ;;
    2)
        if ! _is_active specter; then
            cat <<EOF
${red}
***
Stopping Specter Service...
***
${nc}
EOF
        sudo systemctl stop specter
        fi

        _sleep

        _pause return
        bash -c "${ronin_specter_menu}"
        # Stop specter.service and return to same menu
        ;;
    3)
        cat <<EOF
${red}
***
Restarting Specter Service...
***
${nc}
EOF
        sudo systemctl restart specter

        _sleep

        _pause return
        bash -c "${ronin_specter_menu}"
        # Restart specter.service and return to same menu
        ;;
    4)
        cat <<EOF
${red}
***
Press "q" key to exit at any time...
***
${nc}
EOF
        _sleep 3

        sudo systemctl status specter

        bash -c "${ronin_specter_menu}"
        ;;
    5)
        bash -c "${ronin_applications_menu}"
        # Return to applications menu
        ;;
esac