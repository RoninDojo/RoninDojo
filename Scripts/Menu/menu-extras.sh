#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Install Extras Menu"
         2 "Mempool Visualizer"
         3 "Specter Server"
         4 "Bisq Connect Status"
         5 "Fan Control"
         6 "Uninstall Extras Menu"
         7 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
    1)
        bash -c "${RONIN_EXTRAS_INSTALL_MENU}"
        # Extras Install menu
        ;;
    2)
        if ! _mempool_check ; then
            cat <<EOF
${RED}
***
Mempool not installed! Install from Extras Install Menu.
***
${NC}
EOF
            sleep 3 msg--"returning to Extras menu in..."
            bash -c "${RONIN_EXTRAS_MENU}"

        else
            bash -c "${RONIN_MEMPOOL_MENU}"
        # Mempool menu
        fi
        ;;
    3)
        if ! _is_specter ; then
            cat <<EOF
${RED}
***
Specter not installed! Install from Extras Install Menu.
***
${NC}
EOF
            sleep 3 msg--"returning to Extras menu in..."
            bash -c "${RONIN_EXTRAS_MENU}"
        else
            bash -c "${RONIN_SPECTER_MENU}"
        fi
        # Specter menu
        ;;
    4)
        cat <<EOF
${RED}
***
Checking your Dojo's Compatibility with Bisq
***
${NC}
EOF
        if ! _is_bisq ; then
            cat <<EOF
${RED}
***
Your Dojo NOT currently compatibility with Bisq!
***
${NC}
EOF
            sleep 2
            cat <<EOF
${RED}
***
Install option from Extras Install Menu. See wiki for more details.
***
${NC}
EOF
            sleep 3 --"returning to Extras menu in..."
            bash -c "$RONIN_EXTRAS_MENU"
        else
            cat <<EOF
${RED}
***
Your Dojo IS currently Compatibility with Bisq!
***
${NC}
EOF
            sleep 5 --msg "Enjoy those no-KYC sats! Returning to Extras Menu in..."
            bash -c "$RONIN_EXTRAS_MENU"
        fi
        # Bisq check
        ;;
    5)
        cd "$HOME" || exit 1

        if ! which_sbc rockpro64; then
            cat <<EOF
${RED}
***
No supported SBC detected for fan control management.
Supported devices are Rockpro64 and Rockpi4 boards ONLY
***

***
Press any key to return...
***
${NC}
EOF
            _pause

            ronin

        fi

        if ! hash go 2>/dev/null; then
            cat <<EOF
${RED}
***
Installing go language dependency
***
${NC}
EOF
            sudo pacman -S go glibc --noconfirm
        fi

        if [ ! -f /etc/systemd/system/bbbfancontrol.service ]; then
            git clone https://github.com/digitalbitbox/bitbox-base.git
            cd bitbox-base/tools/bbbfancontrol || exit
            go build
            sudo cp bbbfancontrol /usr/local/sbin/

            sudo bash -c "cat <<EOF >/etc/systemd/system/bbbfancontrol.service
[Unit]
Description=BitBoxBase fancontrol
After=local-fs.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/bbbfancontrol --tmin 60 --tmax 75 --cooldown 55 -fan /sys/class/hwmon/hwmon3/pwm1
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"
            sudo systemctl enable bbbfancontrol 2>/dev/null
            sudo systemctl start bbbfancontrol
        else
            cat <<EOF
${RED}
***
Fan control already installed!
***

***
Press any key to return...
***
${NC}
EOF
        fi

        _pause

        bash -c "${RONIN_EXTRAS_MENU}"
        ;;
    6)
        bash -c "${RONIN_EXTRAS_UNINSTALL_MENU}"
        # Extras Uninstall menu
        ;;
    7)
        ronin
        # returns to main menu
        ;;
esac
