#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

OPTIONS=(1 "Mempool Space Visualizer"
         2 "Specter Server"
         3 "Electrum Server"
         4 "Bisq Connection Status"
         5 "Fan Control"
         6 "Manage Applications"
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
        if ! _mempool_check ; then
            cat <<EOF
${red}
***
Mempool Space Visualizer not installed!
***
${nc}
EOF
            _sleep 2
            cat <<EOF
${red}
***
Install Mempool Space Visualizer using the manage applications menu...
***
${nc}
EOF
            _sleep 2
            _pause return
            bash -c "${ronin_applications_menu}"
        else
            bash -c "${ronin_mempool_menu}"
        # Mempool Space Visualizer menu
        fi
        ;;
    2)
        if ! _is_specter ; then
            cat <<EOF
${red}
***
Specter server not installed!
***
${nc}
EOF
            _sleep 2
            cat <<EOF
${red}
***
Install Specter Server using the manage applications menu...
***
${nc}
EOF
            _sleep 2
            _pause return
            bash -c "${ronin_applications_menu}"
        else
            bash -c "${ronin_specter_menu}"
        fi
        # Specter menu
        ;;
    3)
        if ! _is_electrs; then
            bash -c "${ronin_applications_menu}"
            exit 1
        fi
        # check if electrs is already installed

        bash -c "${ronin_electrs_menu}"
        # runs electrs menu script
        ;;
    4)
        cat <<EOF
${red}
***
Checking your RoninDojo's compatibility with Bisq...
***
${nc}
EOF
        _sleep 2
        if ! _is_bisq ; then
            cat <<EOF
${red}
***
Bisq connections are not enabled...
***
${nc}
EOF
            _sleep 2
            cat <<EOF
${red}
***
Enable Bisq connections using the applications install menu...
***
${nc}
EOF
            _sleep 2
            _pause return
            bash -c "$ronin_applications_menu"
        else
            cat <<EOF
${red}
***
Bisq connections are enabled...
***
${nc}
EOF
            _sleep 2
            cat <<EOF
${red}
***
Enjoy those no-KYC sats...
***
${nc}
EOF
            _sleep 2
            _pause return
            bash -c "$ronin_applications_menu"
        fi
        # Bisq check
        ;;
    5)
        cd "$HOME" || exit 1

        if ! which_sbc rockpro64; then
            cat <<EOF
${red}
***
No supported single-board computer detected for fan control...
***
EOF
            _sleep 2
            cat <<EOF
${red}
***
Supported devices are Rockpro64 and Rockpi4...
***
${nc}
EOF
            _sleep 2

            _pause return
            bash -c "$ronin_applications_menu"
        fi

        # Check for package dependencies
        for pkg in go gcc; do
            _check_pkg "${pkg}"
        done

        _check_pkg "ldd" "glibc"

        if [ ! -f /etc/systemd/system/bbbfancontrol.service ]; then
            cat <<EOF
${red}
***
Installing fan control...
***
${nc}
EOF
            git clone -q https://github.com/digitalbitbox/bitbox-base.git &>/dev/null || exit

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
${red}
***
Fan control already installed...
***
${nc}
EOF
        _pause return

        bash -c "${ronin_applications_menu}"
        fi
        ;;
    6)
        bash -c "${ronin_applications_manage_menu}"
        # Manage applications menu
        ;;
    7)
        ronin
        # returns to main menu
        ;;
esac