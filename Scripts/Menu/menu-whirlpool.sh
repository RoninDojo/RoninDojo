#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Start"
         2 "Stop"
         3 "Restart"
         4 "Logs"
         5 "Reset"
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
            _is_dojo "${ronin_whirlpool_menu}"
            cat <<EOF
${red}
***
Starting Whirlpool...
***
${nc}
EOF
            _sleep
            docker start whirlpool 1>/dev/null

            cat <<EOF
${red}
***
Don't forget to login to GUI to unlock mixing!
***
${nc}
EOF
            _sleep

            _pause return

            bash -c "$ronin_whirlpool_menu"
            # see defaults.sh
            # start whirlpool, press to return to menu
            ;;
        2)
            _is_dojo "${ronin_whirlpool_menu}"
            cat <<EOF
${red}
***
Stopping Whirlpool...
***
${nc}
EOF
            _sleep
            docker stop whirlpool 1>/dev/null

            _pause return

            bash -c "$ronin_whirlpool_menu"
            # stop whirlpool, press to return to menu
            # see defaults.sh
            ;;
        3)
            _is_dojo "${ronin_whirlpool_menu}"
            cat <<EOF
${red}
***
Restarting Whirlpool...
***
${nc}
EOF
            _sleep
            docker stop whirlpool 1>/dev/null

            docker start whirlpool 1>/dev/null
            _sleep

            _pause return

            bash -c "$ronin_whirlpool_menu"
            # enable whirlpool at startup, press to return to menu
            # see defaults.sh
	        ;;
        4)
            _is_dojo "${ronin_whirlpool_menu}"
            cat <<EOF
${red}
***
Viewing Whirlpool Logs...
***
${nc}
EOF
            _sleep

            cat <<EOF
${red}
***
Press Ctrl+C to exit at anytime...
***
${nc}
EOF
            cd "$dojo_path_my_dojo" || exit
            ./dojo.sh logs whirlpool

            bash -c "$ronin_whirlpool_menu"
            # view logs, return to menu
            # see defaults.sh
            ;;
        5)
            _is_dojo "${ronin_whirlpool_menu}"
            cat <<EOF
${red}
***
Re-initiating Whirlpool will reset your mix count and generate new API key...
***
${nc}
EOF
            _sleep
            cat <<EOF
${red}
***
Are you sure you want to re-initiate Whirlpool?
***
${nc}
EOF
            while true; do
                read -rp "[${green}Yes${nc}/${red}No${nc}]: " answer
                case $answer in
                    [yY][eE][sS]|[yY])
                        cat <<EOF
${red}
***
Re-initiating Whirlpool...
***
${nc}
EOF
                        cd "$dojo_path_my_dojo" || exit

                        ./dojo.sh whirlpool reset
                        _sleep

                        cat <<EOF
${red}
***
Re-initation complete, leave APIkey blank when pairing to GUI!
***
${nc}
EOF
                        _sleep 5
                        break
                        ;;
                    [nN][oO]|[Nn])
                        _pause return
                        break
                        ;;
                    *)
                        cat <<EOF
${red}
***
Invalid answer! Enter Y or N
***
${nc}
EOF
                        ;;
                esac
            done

            _sleep

            bash -c "$ronin_whirlpool_menu"
            # re-initate whirlpool, return to menu
            # see defaults.sh
            ;;
        6)
            bash -c "${ronin_samourai_toolkit_menu}"
            # return to menu
            ;;
esac