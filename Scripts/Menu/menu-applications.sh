#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Mempool Visualizer"
         2 "Specter Server"
         3 "Electrum Server"
         4 "Bisq Connection Status"
         5 "Fan Control"
         6 "Install Applications Menu"
         7 "Uninstall Applications Menu"
         8 "Go Back")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
    1)
        if ! _mempool_check ; then
            cat <<EOF
${RED}
***
Mempool not installed!
***
${NC}
EOF
            _sleep 2
            cat <<EOF
${RED}
***
Install Mempool using the applications install menu...
***
${NC}
EOF
            _sleep 2
            _pause return
            bash -c "${RONIN_APPLICATIONS_MENU}"
        else
            bash -c "${RONIN_MEMPOOL_MENU}"
        # Mempool menu
        fi
        ;;
    2)
        if ! _is_specter ; then
            cat <<EOF
${RED}
***
Specter server not installed!
***
${NC}
EOF
            _sleep 2
            cat <<EOF
${RED}
***
Install Specter Server using the applications install menu...
***
${NC}
EOF
            _sleep 2
            _pause return
            bash -c "${RONIN_APPLICATIONS_MENU}"
        else
            bash -c "${RONIN_SPECTER_MENU}"
        fi
        # Specter menu
        ;;
    3)
        if ! _is_electrs; then
            bash -c "${RONIN_APPLICATIONS_MENU}"
            exit 1
        fi
        # check if electrs is already installed

        bash -c "${RONIN_ELECTRS_MENU}"
        # runs electrs menu script
        ;;
    4)
        cat <<EOF
${RED}
***
Checking your RoninDojo's compatibility with Bisq...
***
${NC}
EOF
        _sleep 2
        if ! _is_bisq ; then
            cat <<EOF
${RED}
***
Bisq connections are not enabled...
***
${NC}
EOF
            _sleep 2
            cat <<EOF
${RED}
***
Enable Bisq connections using the applications install menu...
***
${NC}
EOF
            _sleep 2
            _pause return
            bash -c "$RONIN_APPLICATIONS_MENU"
        else
            cat <<EOF
${RED}
***
Bisq connections are enabled...
***
${NC}
EOF
            _sleep 2
            cat <<EOF
${RED}
***
Enjoy those no-KYC sats...
***
${NC}
EOF
            _sleep 2
            _pause return
            bash -c "$RONIN_APPLICATIONS_MENU"
        fi
        # Bisq check
        ;;
    5)
        cd "$HOME" || exit 1

        if ! which_sbc rockpro64; then
            cat <<EOF
${RED}
***
No supported single-board computer detected for fan control...
***
EOF
            _sleep 2
            cat <<EOF
${RED}
***
Supported devices are Rockpro64 and Rockpi4...
***
${NC}
EOF
            _sleep 2
            _pause return
            bash -c "$RONIN_APPLICATIONS_MENU"
        fi

        if ! hash go 2>/dev/null; then
            cat <<EOF
${RED}
***
Installing go language dependency...
***
${NC}
EOF
            sudo pacman --quiet -S go glibc --noconfirm
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
${NC}
EOF
        _pause return
        bash -c "${RONIN_APPLICATIONS_MENU}"
        fi
        ;;
    6)
        bash -c "${RONIN_APPLICATIONS_INSTALL_MENU}"
        # applications install menu
        ;;
    7)
        bash -c "${RONIN_APPLICATIONS_UNINSTALL_MENU}"
        # applications uninstall menu
        ;;
    8)
        ronin
        # returns to main menu
        ;;
esac