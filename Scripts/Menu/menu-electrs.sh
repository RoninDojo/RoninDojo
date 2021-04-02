#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
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
${red}
***
Showing Electrs Logs...
***
${nc}
EOF
        _sleep

        cat <<EOF
${red}
***
Press Ctrl + C to exit at any time...
***
${nc}
EOF
        _sleep

        cd "$dojo_path_my_dojo" || exit

        ./dojo.sh logs indexer

        bash -c "${ronin_electrs_menu}"
        # start electrs, return to menu
        ;;
	2)
        bash -c "${ronin_applications_menu}"
        # Return to applications menu
        ;;
esac