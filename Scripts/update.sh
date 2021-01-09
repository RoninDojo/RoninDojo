#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh

_update_01() {
    if ! _check_pkgver bridge-utils 1.7-1; then
        cat <<EOF
${RED}
***
Outdated and bridge-utils found...
***
${NC}
EOF
        _sleep 2
        cat <<EOF
${RED}
***
Starting bridge-utils upgrade...
***
${NC}
EOF
        sudo pacman -U --noconfirm http://mirror.archlinuxarm.org/aarch64/extra/bridge-utils-1.7-1-aarch64.pkg.tar.xz &>/dev/null

        # If existing dojo found, then reboot system to apply changes
        if [ -d "${HOME}/dojo" ]; then
            cat <<EOF
${RED}
***
Existing dojo found! Rebooting system to apply changes...
***
${NC}
EOF
            _sleep 2
            cat <<EOF
${RED}
***
Press Ctrl+C now if you wish to skip...
***
${NC}
EOF
            _sleep 10 --msg "Rebooting in"
            sudo systemctl reboot
        fi
    fi
}

# Remove old whirlpool stats tool directory
_update_02() {
    if [ -d "$HOME"/wst ]; then
        rm -rf "$HOME"/wst
    fi
}

# Add password less reboot/shutdown privileges to sudo
_update_03() {
    if [ -f "${sudoers_file}" ]; then
        if ! grep "/usr/bin/systemctl poweroff" "${sudoers_file}" 1>/dev/null; then
            sudo bash -c "cat <<EOF >>"${sudoers_file}"
ALL ALL=(root) NOPASSWD: /usr/bin/systemctl reboot, /usr/bin/systemctl poweroff
EOF"
        fi
    fi
}

# Add password less for /usr/bin/{ufw,mount,umount,cat,grep,test,mkswap,swapon,swapoff} privileges to sudo
_update_04() {
    if [ -f "${sudoers_path}" ]; then
        if ! grep "/usr/bin/test" "${sudoers_file}" 1>/dev/null; then
            sudo bash -c "cat <<EOF >>"${sudoers_file}"
ALL ALL=(root) NOPASSWD: /usr/bin/test, /usr/bin/grep, /usr/bin/cat, /usr/bin/ufw
ALL ALL=(root) NOPASSWD: /usr/bin/umount, /usr/bin/mount, /usr/bin/mkswap, /usr/bin/swapon, /usr/bin/swapoff
EOF"
        fi
    fi
}

# fix tor unit file
_update_05() {
    if ! systemctl is-active --quiet tor; then
        sudo sed -i 's:^ReadWriteDirectories=-/var/lib/tor.*$:ReadWriteDirectories=-/var/lib/tor /mnt/usb/tor:' /usr/lib/systemd/system/tor.service
        #sudo sed -i '/Type=notify/i\User=tor' /usr/lib/systemd/system/tor.service
        sudo systemctl daemon-reload
        sudo systemctl restart tor
    fi
}

# modify pacman.conf
_update_06() {
    sudo sed -i "s:^#IgnorePkg   =.*$:IgnorePkg   = tor docker docker-compose bridge-utils:" /etc/pacman.conf
}

# copy user.conf.example to correct location
_update_07() {
    if [ ! -f "$HOME"/.config/RoninDojo/user.conf ] ; then
        cp -rv "$HOME"/RoninDojo/user.conf.example "$HOME"/.config/RoninDojo/user.conf
    fi
}

# store ip address range and exact ipaddress in ~/.config/RoninDojo
_update_08() {
    ip addr | sed -rn '/state UP/{n;n;s:^ *[^ ]* *([^ ]*).*:\1:;s:[^.]*$:0/24:p}' > "$HOME"/.config/RoninDojo/ip-range.txt
    ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 > "$HOME"/.config/RoninDojo/ip.txt
}
