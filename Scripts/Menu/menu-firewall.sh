#!/bin/bash

RED=$(tput setaf 1)
# used for color with ${RED}
NC=$(tput sgr0)
# No Color

HEIGHT=22
WIDTH=76
CHOICE_HEIGHT=16
TITLE="RoninDojo"
MENU="Choose one of the following options:"

OPTIONS=(1 "Enable Firewall"
         2 "Disable Firewall"
         3 "Firewall Status"
         4 "Add New IP Range for SSH"
         5 "Add Specific IP for SSH"
         6 "Delete Rule"
         7 "Reload Firewall"
         8 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
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
            sleep 2s
            sudo ufw enable
            sleep 1s
            bash ~/RoninDojo/Scripts/Menu/menu-firewall.sh
            # enables firewall
            ;;
        2)
            echo -e "${RED}"
            echo "***"
            echo "Disabling Firewall..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo ufw disable
            sleep 1s
            bash ~/RoninDojo/Scripts/Menu/menu-firewall.sh
            # disables firewall
            ;;
        3)
            echo -e "${RED}"
            echo "***"
            echo "Showing Status..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo ufw status
            # shows ufw status

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/menu-firewall.sh
            # press any key to return to menu
            ;;
        4)
            echo -e "${RED}"
            echo "***"
            echo "Obtain the IP address you wish to give access to SSH."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo -e "${RED}"
            echo "***"
            echo "Your IP address on your network may look like 192.168.4.21"
            echo "Or it could look like 12.34.56.78"
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo -e "${RED}"
            echo "***"
            echo "Enter the local IP address you wish to give SSH access now."
            echo "***"
            echo -e "${NC}"

            read -p 'Local IP Address: ' ip_address
            sudo ufw allow from $ip_address/24 to any port 22 comment 'SSH access restricted to local LAN only'

            echo -e "${RED}"
            echo "***"
            echo "Reloading..."
            echo "***"
            sleep 2s
            echo -e "${NC}"
            sudo ufw reload
            # reload the firewall

            echo -e "${RED}"
            echo "***"
            echo "Showing status..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
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
            bash ~/RoninDojo/Scripts/Menu/menu-firewall.sh
            # press any key to return to menu
            ;;
        5)
            echo -e "${RED}"
            echo "***"
            echo "Obtain the IP address you wish to give access to SSH."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo -e "${RED}"
            echo "***"
            echo "Your IP address on your network may look like 192.168.4.21"
            echo "Or it could look like 12.34.56.78"
            echo "***"
            echo -e "${NC}"
            sleep 2s

            echo -e "${RED}"
            echo "***"
            echo "Enter the local IP address you wish to give SSH access now."
            echo "***"
            echo -e "${NC}"

            read -p 'Local IP Address: ' ip_address
            sudo ufw allow from $ip_address to any port 22 comment 'SSH access restricted to local LAN only'

            echo -e "${RED}"
            echo "***"
            echo "Reloading..."
            echo "***"
            sleep 2s
            echo -e "${NC}"
            sudo ufw reload
            # reload the firewall

            echo -e "${RED}"
            echo "***"
            echo "Showing status..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
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
            bash ~/RoninDojo/Scripts/Menu/menu-firewall.sh
            # press any key to return to menu
            ;;

        6)
            echo -e "${RED}"
            echo "***"
            echo "Find the rule you want to delete, and type its row number to delete it."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo ufw status
            # show firewall status

            echo -e "${RED}"
            echo "***"
            echo "Example: If you want to delete the 3rd rule listed, press the number 3, and press Enter."
            echo "***"
            echo -e "${NC}"
            sleep 2s

            read -p "Please type the rule number to delete now: " ufw_rule_number
            sudo ufw delete $ufw_rule_number
            # use user input to delete a certain number ufw rule

            echo -e "${RED}"
            echo "***"
            echo "Reloading..."
            echo "***"
            sleep 2s
            echo -e "${NC}"
            sudo ufw reload
            # reload the firewall

            echo -e "${RED}"
            echo "***"
            echo "Showing status..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo ufw status
            # show firewall status

            echo -e "${RED}"
            echo "***"
            echo "Press any letter to return..."
            echo "***"
            echo -e "${NC}"
            read -n 1 -r -s
            bash ~/RoninDojo/Scripts/Menu/menu-firewall.sh
            # press any letter to return to menu
            ;;
        7)
            echo -e "${RED}"
            echo "***"
            echo "Reloading Firewall..."
            echo "***"
            echo -e "${NC}"
            sleep 2s
            sudo ufw reload
            bash ~/RoninDojo/Scripts/Menu/menu-firewall.sh
            # reload and return to menu
            ;;
        8)
            bash ~/RoninDojo/ronin
            # return to main menu
            ;;
esac
