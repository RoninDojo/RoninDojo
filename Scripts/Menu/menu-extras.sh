#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Boltzmann"
         2 "Whirlpool Stats Tool"
         3 "Mempool Visualizer"
         4 "Fan Control"
         5 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
    1)
        bash -c "$RONIN_BOLTZMANN_MENU"
        # Boltzmann menu
        ;;
    2)
        bash -c "$RONIN_WHIRLPOOL_STAT_MENU"
        # check for wst install and/or launch wst, return to menu
        # see defaults.sh
        ;;
    3)
        bash -c "$RONIN_MEMPOOL_MENU"
        # Mempool menu
        ;;
    4)
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
            sudo pacman -S go --noconfirm
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

        ronin
        ;;
    5)
        ronin
        # returns to main menu
        ;;
esac