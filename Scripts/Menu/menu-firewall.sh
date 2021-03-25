#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Enable"
         2 "Disable"
         3 "Status"
         4 "Delete Rule"
         5 "Reload"
         6 "Add IP Range for SSH"
         7 "Add Specific IP for SSH"
         8 "Next Page"
         9 "Go Back")

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
Enabling Firewall...
***
${nc}
EOF
            _sleep 1
            sudo ufw enable
            _pause return
            bash -c "${ronin_firewall_menu}"
            # enable firewall, press any key to return to menu
            ;;
        2)
            cat <<EOF
${red}
***
Disabling Firewall...
***
${nc}
EOF
            _sleep 1
            sudo ufw disable
            _pause return
            bash -c "${ronin_firewall_menu}"
            # disable firewall, press any key to return to menu
            ;;
        3)
            cat <<EOF
${red}
***
Showing Status...
***
${nc}
EOF
            _sleep 1
            sudo ufw status
            _pause return
            bash -c "${ronin_firewall_menu}"
            # show ufw status, press any key to return to menu
            ;;
        4)
            cat <<EOF
${red}
***
Find the rule you want to delete, and type its row number to delete it...
***
${nc}
EOF
            _sleep 1
            sudo ufw status
            # show firewall status

            cat <<EOF
${red}
***
Be careful when deleting old firewall rules! Don't lock yourself out from SSH access...
***
${nc}
EOF
            _sleep 1

            cat <<EOF
${red}
***
Example: If you want to delete the 3rd rule listed, press the number 3, and press Enter...
***
${nc}
EOF
            _sleep 1

            read -rp "Please type the rule number to delete now: " ufw_rule_number
            sudo ufw delete "$ufw_rule_number"
            # request user input to delete a ufw rule

            cat <<EOF
${red}
***
Reloading...
***
${nc}
EOF
            sudo ufw reload
            # reload firewall

            cat <<EOF
${red}
***
Showing status...
***
${nc}
EOF
            _sleep 1
            sudo ufw status
            # show firewall status

            _pause return
            bash -c "${ronin_firewall_menu}"
            # press any key to return to menu
            ;;
        5)
            cat <<EOF
${red}
***
Reloading...
***
${nc}
EOF
            sudo ufw reload
            _pause return
            bash -c "${ronin_firewall_menu}"
            # reload firewall, press any key to return to menu
            ;;
        6)
            cat <<EOF
${red}
***
Obtain the IP address of any machine on the same local network as your RoninDojo...
***
${nc}
EOF
            _sleep 1

            cat <<EOF
${red}
***
The IP address entered will be adapted to end with .0/24 range...
***
${nc}
EOF
            _sleep 1

            cat <<EOF
${red}
***
This will allow any machine on the same network to have SSH access...
***
${nc}
EOF
            _sleep 1

            cat <<EOF
${red}
***
Your IP address on the network may look like 192.168.4.21 or 12.34.56.78 depending on setup...
***
${nc}
EOF
            _sleep 1

            cat <<EOF
${red}
***
Enter the local IP address you wish to give SSH access now...
***
${nc}
EOF

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address"/24 to any port 22 comment 'SSH access restricted to local network'

            cat <<EOF
${red}
***
Reloading...
***
${nc}
EOF
            sudo ufw reload
            # reload firewall

            cat <<EOF
${red}
***
Showing status...
***
${nc}
EOF
            _sleep 1
            sudo ufw status
            # show firewall status

            cat <<EOF
${red}
***
Make sure that you see your new rule!
***
${nc}
EOF
            _sleep 1

            _pause return
            bash -c "${ronin_firewall_menu}"
            # press any key to return to menu
            ;;
        7)
            cat <<EOF
${red}
***
Obtain the specific IP address you wish to give access to SSH...
***
${nc}
EOF
            _sleep 1

            cat <<EOF
${red}
***
SSH access will be restricted to this IP address only...
***
${nc}
EOF
            _sleep 1

            cat <<EOF
${red}
***
Your IP address on the network may look like 192.168.4.21 or 12.34.56.78 depending on setup...
***
${nc}
EOF
            _sleep 1

            cat <<EOF
${red}
***
Enter the local IP address you wish to give SSH access now...
***
${nc}
EOF

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address" to any port 22 comment 'SSH access restricted to specific IP'

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
            _sleep 1
            sudo ufw status
            # show firewall status

            cat <<EOF
${red}
***
Make sure that you see your new rule!
***
${nc}
EOF
            _sleep 1

            _pause return
            bash -c "${ronin_firewall_menu}"
            # press any key to return to menu
            ;;
        8)
            bash -c "${ronin_firewall_menu2}"
            # go to next menu page
            ;;
        9)
            bash -c "${ronin_system_menu2}"
            # return system menu page 2
            ;;
esac