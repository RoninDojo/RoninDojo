#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/dojo-defaults.sh
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
            _is_dojo "${RONIN_WHIRLPOOL_MENU}"
            cat <<EOF
${RED}
***
Starting Whirlpool...
***
${NC}
EOF
            _sleep 2
            docker start whirlpool 1>/dev/null

            cat <<EOF
${RED}
***
Don't forget to login to GUI to unlock mixing!
***
${NC}
EOF
            _sleep 5

            cat <<EOF
${RED}
***
Press any key to return...
***
${NC}
EOF
            _pause
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # see defaults.sh
            # start whirlpool, press to return to menu
            ;;
        2)
            _is_dojo "${RONIN_WHIRLPOOL_MENU}"
            cat <<EOF
${RED}
***
Stopping Whirlpool...
***
${NC}
EOF
            _sleep 2
            docker stop whirlpool 1>/dev/null

            cat <<EOF
${RED}
***
Press any key to return...
***
${NC}
EOF
            _pause
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # stop whirlpool, press to return to menu
            # see defaults.sh
            ;;
        3)
            _is_dojo "${RONIN_WHIRLPOOL_MENU}"
            cat <<EOF
${RED}
***
Restarting Whirlpool...
***
${NC}
EOF
            _sleep 2
            docker stop whirlpool 1>/dev/null
            _sleep 5
            docker start whirlpool 1>/dev/null
            _sleep 2

            cat <<EOF
${RED}
***
Press any key to return...
***
${NC}
EOF
            _pause            
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # enable whirlpool at startup, press to return to menu
            # see defaults.sh
	        ;;
        4)
            _is_dojo "${RONIN_WHIRLPOOL_MENU}"
            cat <<EOF
${RED}
***
Viewing Whirlpool Logs...
***
${NC}
EOF
            _sleep 2

            cat <<EOF
${RED}
***
Press Ctrl+C to exit at anytime...
***
${NC}
EOF
            cd "$DOJO_PATH" || exit
            ./dojo.sh logs whirlpool
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # view logs, return to menu
            # see defaults.sh
            ;;
        5)
            _is_dojo "${RONIN_WHIRLPOOL_MENU}"
            cat <<EOF
${RED}
***
Re-initiating Whirlpool will reset your mix count and generate new API key...
***
${NC}
EOF
_sleep 2
            cat <<EOF
${RED}
***
Are you sure you want to re-initiate Whirlpool? [${GREEN}Yes${NC}/${RED}No${NC}]
***
${NC}
EOF
            while true; do
                read -r answer
                case $answer in
                    [yY][eE][sS]|[yY]|"")
                        cat <<EOF
${RED}
***
Re-initiating Whirlpool...
***
${NC}
EOF
                        cd "$DOJO_PATH" || exit

                        ./dojo.sh whirlpool reset
                        _sleep

                        cat <<EOF
${RED}
***
Re-initation complete, leave APIkey blank when pairing to GUI!
***
${NC}
EOF
                        _sleep 5
                        break
                        ;;
                    [nN][oO]|[Nn])
                        cat <<EOF
${RED}
***
Returning to menu..."
***
${NC}
EOF
                            _sleep 2
                            break
                            ;;
                    *)
                        cat <<EOF
${RED}
***
Invalid answer! Enter Y or N
***
${NC}
EOF
                        ;;
                esac
            done

            _sleep
            bash -c "$RONIN_WHIRLPOOL_MENU"
            # re-initate whirlpool, return to menu
            # see defaults.sh
            ;;
        6)
            ronin
            # return to menu
            ;;
esac
