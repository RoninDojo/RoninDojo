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
${RED}
***
Enabling Firewall...
***
${NC}
EOF
            _sleep 2
            sudo ufw enable
            _pause return
            bash -c "${RONIN_FIREWALL_MENU}"
            # enable firewall, press any key to return to menu
            ;;
        2)
            cat <<EOF
${RED}
***
Disabling Firewall...
***
${NC}
EOF
            _sleep 2
            sudo ufw disable
            _pause return
            bash -c "${RONIN_FIREWALL_MENU}"
            # disable firewall, press any key to return to menu
            ;;
        3)
            cat <<EOF
${RED}
***
Showing Status...
***
${NC}
EOF
            _sleep 2
            sudo ufw status
            _pause return
            bash -c "${RONIN_FIREWALL_MENU}"
            # show ufw status, press any key to return to menu
            ;;
        4)
            cat <<EOF
${RED}
***
Find the rule you want to delete, and type its row number to delete it...
***
${NC}
EOF
            _sleep 2
            sudo ufw status
            # show firewall status

            cat <<EOF
${RED}
***
Be careful when deleting old firewall rules! Don't lock yourself out from SSH access...
***
${NC}
EOF
            _sleep 2

            cat <<EOF
${RED}
***
Example: If you want to delete the 3rd rule listed, press the number 3, and press Enter...
***
${NC}
EOF
            _sleep 2

            read -rp "Please type the rule number to delete now: " ufw_rule_number
            sudo ufw delete "$ufw_rule_number"
            # request user input to delete a ufw rule

            cat <<EOF
${RED}
***
Reloading...
***
${NC}
EOF
            sudo ufw reload
            # reload firewall

            cat <<EOF
${RED}
***
Showing status...
***
${NC}
EOF
            _sleep 2
            sudo ufw status
            # show firewall status

            _pause return
            bash -c "${RONIN_FIREWALL_MENU}"
            # press any key to return to menu
            ;;
        5)
            cat <<EOF
${RED}
***
Reloading...
***
${NC}
EOF
            sudo ufw reload
            _pause return
            bash -c "${RONIN_FIREWALL_MENU}"
            # reload firewall, press any key to return to menu
            ;;
        6)
            cat <<EOF
${RED}
***
Obtain the IP address of any machine on the same local network as your RoninDojo...
***
${NC}
EOF
            _sleep 2

            cat <<EOF
${RED}
***
The IP address entered will be adapted to end with .0/24 range...
***
${NC}
EOF
            _sleep 2

            cat <<EOF
${RED}
***
This will allow any machine on the same network to have SSH access...
***
${NC}
EOF
            _sleep 2

            cat <<EOF
${RED}
***
Your IP address on the network may look like 192.168.4.21 or 12.34.56.78 depending on setup...
***
${NC}
EOF
            _sleep 2

            cat <<EOF
${RED}
***
Enter the local IP address you wish to give SSH access now...
***
${NC}
EOF

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address"/24 to any port 22 comment 'SSH access restricted to local network'

            cat <<EOF
${RED}
***
Reloading...
***
${NC}
EOF
            sudo ufw reload
            # reload firewall

            cat <<EOF
${RED}
***
Showing status...
***
${NC}
EOF
            _sleep 2
            sudo ufw status
            # show firewall status

            cat <<EOF
${RED}
***
Make sure that you see your new rule!
***
${NC}
EOF
            _sleep 2

            _pause return
            bash -c "${RONIN_FIREWALL_MENU}"
            # press any key to return to menu
            ;;
        7)
            cat <<EOF
${RED}
***
Obtain the specific IP address you wish to give access to SSH...
***
${NC}
EOF
            _sleep 2

            cat <<EOF
${RED}
***
SSH access will be restricted to this IP address only...
***
${NC}
EOF
            _sleep 2

            cat <<EOF
${RED}
***
Your IP address on the network may look like 192.168.4.21 or 12.34.56.78 depending on setup...
***
${NC}
EOF
            _sleep 2

            cat <<EOF
${RED}
***
Enter the local IP address you wish to give SSH access now...
***
${NC}
EOF

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address" to any port 22 comment 'SSH access restricted to specific IP'

            cat <<EOF
${RED}
***
Reloading...
***
${NC}
EOF
            sudo ufw reload
            # reload the firewall

            cat <<EOF
${RED}
***
Showing status...
***
${NC}
EOF
            _sleep 2
            sudo ufw status
            # show firewall status

            cat <<EOF
${RED}
***
Make sure that you see your new rule!
***
${NC}
EOF
            _sleep 2

            _pause return
            bash -c "${RONIN_FIREWALL_MENU}"
            # press any key to return to menu
            ;;
        8)
            bash -c "${RONIN_FIREWALL_MENU2}"
            # go to next menu page
            ;;
        9)
            bash -c "${RONIN_SYSTEM_MENU2}"
            # return system menu page 2
            ;;
esac