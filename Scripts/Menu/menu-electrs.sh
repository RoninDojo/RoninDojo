#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Logs"
         2 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
    1)
        cat <<EOF
${RED}
***
Showing Electrs Logs...
***
${NC}
EOF
        _sleep

        cat <<EOF
${RED}
***
Press Ctrl + C to exit at any time...
***
${NC}
EOF
        _sleep 2

        cd "$dojo_path_my_dojo" || exit

        ./dojo.sh logs indexer

        bash -c "${RONIN_ELECTRS_MENU}"
        # start electrs, return to menu
        ;;
	2)
        ronin
        # returns to main menu
        ;;
esac
