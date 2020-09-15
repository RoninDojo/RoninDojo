#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Enable"
         2 "Disable"
         3 "Status"
         4 "Delete Rule"
         5 "Reload"
         6 "Add New IP Range for SSH"
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
            echo -e "${RED}"
            echo "***"
            echo "Enabling Firewall..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            sudo ufw enable
            _sleep
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall.sh
            # enables firewall
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Disabling Firewall..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            sudo ufw disable
            _sleep
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall.sh
            # disables firewall
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Showing Status..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            sudo ufw status
            # shows ufw status

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall.sh
            # press any key to return to menu
            ;;
        4)
	    echo -e "${RED}"
            echo "***"
            echo "Find the rule you want to delete, and type its row number to delete it."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            sudo ufw status
            # show firewall status

            echo -e "${RED}"
            echo "***"
            echo "Example: If you want to delete the 3rd rule listed, press the number 3, and press Enter."
            echo "***"
            echo -e "${NC}"
            _sleep 2

            read -rp "Please type the rule number to delete now: " ufw_rule_number
            sudo ufw delete "$ufw_rule_number"
            # use user input to delete a certain number ufw rule

            echo -e "${RED}"
            echo "***"
            echo "Reloading..."
            echo "***"
            _sleep 2
            echo -e "${NC}"
            sudo ufw reload
            # reload the firewall

            echo -e "${RED}"
            echo "***"
            echo "Showing status..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            sudo ufw status
            # show firewall status

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall.sh
            # press any letter to return to menu
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Reloading Firewall..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            sudo ufw reload
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall.sh
            # reload and return to menu
            ;;
        6)
            echo -e "${RED}"
            echo "***"
            echo "Obtain the IP address of any machine on the same local network as your RoninDojo."
            echo "***"
            echo -e "${NC}"
            _sleep 2

            echo -e "${RED}"
            echo "***"
            echo "The IP address entered will be adapted to end with .0/24"
            echo "This will allow any machine on the same network to have SSH access."
            echo "***"
            echo -e "${NC}"
            _sleep 2

            echo -e "${RED}"
            echo "***"
            echo "Your IP address on the network may look like 192.168.4.21"
            echo "Or it could look like 12.34.56.78"
            echo "***"
            echo -e "${NC}"
            _sleep 2

            echo -e "${RED}"
            echo "***"
            echo "Enter the local IP address you wish to give SSH access now."
            echo "***"
            echo -e "${NC}"

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address"/24 to any port 22 comment 'SSH access restricted to local network'

            echo -e "${RED}"
            echo "***"
            echo "Reloading..."
            echo "***"
            _sleep 2
            echo -e "${NC}"
            sudo ufw reload
            # reload the firewall

            echo -e "${RED}"
            echo "***"
            echo "Showing status..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            sudo ufw status
            # show firewall status

            echo -e "${RED}"
            echo "***"
            echo "Make sure that you see your new rule!"
            echo "***"
            echo -e "${NC}"

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall.sh
            # press any key to return to menu
            ;;
        7)
            echo -e "${RED}"
            echo "***"
            echo "Obtain the specific IP address you wish to give access to SSH."
            echo "***"
            echo -e "${NC}"
            _sleep 2

            echo -e "${RED}"
            echo "***"
            echo "SSH access will be restricted to this IP address only."
            echo "***"
            echo -e "${NC}"
            _sleep 2

            echo -e "${RED}"
            echo "***"
            echo "Be careful when deleting old firewall rules!"
            echo "Don't lock yourself out from SSH access."
            echo "***"
            echo -e "${NC}"
            _sleep 2

            echo -e "${RED}"
            echo "***"
            echo "Your IP address on your network may look like 192.168.4.21"
            echo "Or it could look like 12.34.56.78"
            echo "***"
            echo -e "${NC}"
            _sleep 2

            echo -e "${RED}"
            echo "***"
            echo "Enter the local IP address you wish to give SSH access now."
            echo "***"
            echo -e "${NC}"

            read -rp 'Local IP Address: ' ip_address
            sudo ufw allow from "$ip_address" to any port 22 comment 'SSH access restricted to specific IP'

            echo -e "${RED}"
            echo "***"
            echo "Reloading..."
            echo "***"
            _sleep 2
            echo -e "${NC}"
            sudo ufw reload
            # reload the firewall

            echo -e "${RED}"
            echo "***"
            echo "Showing status..."
            echo "***"
            echo -e "${NC}"
            _sleep 2
            sudo ufw status
            # show firewall status

            echo -e "${RED}"
            echo "***"
            echo "Make sure that you see your new rule!"
            echo "***"
            echo -e "${NC}"

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall.sh
            # press any key to return to menu
            ;;
        8)
	    bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall2.sh
            # go to next menu page
            ;;
        9)
            bash "$HOME"/RoninDojo/ronin
            # return to main menu
            ;;
esac