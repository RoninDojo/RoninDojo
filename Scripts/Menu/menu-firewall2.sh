#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Add IP Range for Whirlpool GUI"
         2 "Add Specific IP for Whirlpool GUI"
         3 "Go Back")

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
Obtain the IP address you wish to give access to Whirlpool CLI...
***
${nc}
EOF
            _sleep 2

            cat <<EOF
${red}
***
Your IP address on the network may look like 192.168.4.21 or 12.34.56.78 depending on setup...
***
${nc}
EOF
            _sleep 2

            cat <<EOF
${red}
***
Enter the local IP address you wish to give Whirlpool CLI access now...
***
${nc}
EOF

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address"/24 to any port 8899 comment 'Whirlpool CLI access restricted to local LAN only'

            cat <<EOF
${red}
***
Reloading...
***
${nc}
EOF
            sudo ufw reload
            # reload the firewall

            cat <<EOF
${red}
***
Showing status...
***
${nc}
EOF
            _sleep 2
            sudo ufw status
            # show firewall status

            cat <<EOF
${red}
***
Make sure that you see your new rule!
***
${nc}
EOF
            _sleep 2

            _pause return
            bash -c "${ronin_firewall_menu2}"
            # press any key to return to menu
            ;;
        2)
            cat <<EOF
${red}
***
Obtain the IP address you wish to give access to Whirlpool CLI...
***
${nc}
EOF
            _sleep 2

            cat <<EOF
${red}
***
Your IP address on the network may look like 192.168.4.21 or 12.34.56.78 depending on setup...
***
${nc}
EOF
            _sleep 2

            cat <<EOF
${red}
***
Enter the local IP address you wish to give Whirlpool CLI access now...
***
${nc}
EOF

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address" to any port 8899 comment 'Whirlpool CLI access restricted to local LAN only'

            cat <<EOF
${red}
***
Reloading...
***
${nc}
EOF
            sudo ufw reload
            # reload the firewall

            cat <<EOF
${red}
***
Showing status...
***
${nc}
EOF
            _sleep 2
            sudo ufw status
            # show firewall status

            cat <<EOF
${red}
***
Make sure that you see your new rule!
***
${nc}
EOF
            _sleep 2

            _pause return
            bash -c "${ronin_firewall_menu2}"
            # press any key to return to menu
            ;;
        3)
            bash -c "${ronin_firewall_menu}"
            ;;
esac
