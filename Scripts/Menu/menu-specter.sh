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
${RED}
***
Starting Specter Service...
***
${NC}
EOF
        fi

        _sleep

        bash -c "${RONIN_SPECTER_MENU}"
        # Start specter.service and return to same menu
        ;;
    2)
        if ! _is_active specter; then
            cat <<EOF
${RED}
***
Stopping Specter Service...
***
${NC}
EOF
        sudo systemctl stop specter
        fi

        _sleep

        bash -c "${RONIN_SPECTER_MENU}"
        # Stop specter.service and return to same menu
        ;;
    3)
        cat <<EOF
${RED}
***
Restarting Specter Service...
***
${NC}
EOF
        sudo systemctl restart specter

        _sleep

        bash -c "${RONIN_SPECTER_MENU}"
        # Restart specter.service and return to same menu
        ;;
    4)
        sudo systemctl status specter

        _pause return

        bash -c "${RONIN_SPECTER_MENU}"
        ;;
    5)
        ronin
        # Return to main menu
        ;;
esac