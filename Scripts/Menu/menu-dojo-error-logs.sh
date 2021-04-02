#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Bitcoind"
         2 "MariaDB"
         3 "Indexer"
         4 "Node.js"
         5 "Tor"
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
            # checks if dojo is running (check the db container), if not running tells user to start dojo first
            if ! _dojo_check; then
              cat <<DOJO
${red}
***
Please start Dojo first!
***
${nc}
DOJO
              _sleep 5
              bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            else
              cd "$dojo_path_my_dojo" || exit
              ./dojo.sh logs bitcoind -n 200 | grep -i 'error'
              # shows bitcoind error logs

              _pause return
              bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
              # press any key to return to menu
            fi
            ;;
        2)
            if ! _dojo_check; then
              cat <<DOJO
${red}
***
Please start Dojo first!
***
${nc}
DOJO
              _sleep 5
              bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            else
                if grep "INDEXER_INSTALL=on" "${dojo_path_my_dojo}"/conf/docker-indexer.conf 1>/dev/null && [ -f "${dojo_path_my_dojo}"/indexer/electrs.toml ] ; then
                    cat <<EOF
${red}
***
Electrum Rust Server is your current Indexer...
***
${nc}
EOF
                    _sleep
                    cat <<EOF
${red}
***
Please check Electrum Rust Server logs instead...
***
${nc}
EOF
                    _sleep
                    _pause return
                    bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
              fi
              cd "$dojo_path_my_dojo" || exit
              ./dojo.sh logs db -n 500 | grep -i 'error'
              # shows db error logs
            fi

            _pause return
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # press any key to return to menu
	          ;;
        3)
            if ! _dojo_check; then
              cat <<DOJO
${red}
***
Please start Dojo first!
***
${nc}
DOJO
              _sleep 5
              bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            else
              cd "$dojo_path_my_dojo" || exit
              ./dojo.sh logs indexer -n 500 | grep -i 'error'
              # shows indexer error logs
            fi

            _pause return
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # press any key to return to menu
            ;;
        4)
            if ! _dojo_check; then
              cat <<DOJO
${red}
***
Please start Dojo first!
***
${nc}
DOJO
              _sleep 5
              bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            else
              cd "$dojo_path_my_dojo" || exit
              ./dojo.sh logs node -n 500 | grep -i 'error'
              # shows nodejs error logs
            fi

            _pause return
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # press any key to return to menu
            ;;
        5)
            if ! _dojo_check; then
                cat <<DOJO
${red}
***
Please start Dojo first!
***
${nc}
DOJO
                _sleep 5
                bash -c "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            else
              cd "$dojo_path_my_dojo" || exit
              ./dojo.sh logs tor -n 500 | grep -i 'error'
              # shows tor error logs
            fi

            _pause return
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-error-logs.sh
            # press any key to return to menu
            ;;
        6)
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-dojo-logs.sh
            # goes back to logs menu
            ;;
esac