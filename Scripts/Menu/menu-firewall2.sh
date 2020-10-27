#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Add New IP Range for Whirlpool GUI"
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
            echo -e "${RED}"
            echo "***"
            echo "Obtain the IP address you wish to give access to your Whirlpool CLI."
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
            sudo ufw allow from "$ip_address"/24 to any port 8899 comment 'Whirlpool CLI access restricted to local LAN only'

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
            echo "Press any key to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall2.sh
            # press any key to return to menu
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Obtain the IP address you wish to give access to SSH."
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
            sudo ufw allow from "$ip_address" to any port 8899 comment 'Whirlpool CLI access restricted to local LAN only'

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
            echo "Press any key to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall2.sh
            # press any key to return to menu
            ;;
        3)
            bash "$HOME"/RoninDojo/Scripts/Menu/menu-firewall.sh
            ;;
esac
