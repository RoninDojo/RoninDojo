#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh

_update_01() {
    if ! _check_pkgver bridge-utils 1.7-1; then
        cat <<EOF
${RED}
***
Outdated and known broken version of bridge-utils found on your system
RoninDojo will upgade your package to latest version available
***
${NC}
EOF
        sleep 2
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
Existing dojo found! We will perform a reboot after 10secs.
Press Ctrl+C if you wish to skip this update now
***
${NC}
EOF
            _sleep 5 --msg "Rebooting in"
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
        sudo sed -i 's:^ReadWriteDirectories=-/var/lib/tor.*$:ReadWriteDirectories=-/var/lib/tor /mnt/usb/tor/:' /usr/lib/systemd/system/tor.service
        sudo systemctl daemon-reload
        sudo systemctl restart tor
    fi
}

# modify pacman.conf
_update_06() {
    sudo sed -i "s:^#IgnorePkg   =.*$:IgnorePkg   = tor docker docker-compose bridge-utils:" /etc/pacman.conf
}

# add INSTALL_DIR_USER to store user info
_update_07() {
    if sudo test ! -d "${INSTALL_DIR_USER}"; then
        sudo mkdir "${INSTALL_DIR_USER}"
        sudo chown -R $USER:$USER "${INSTALL_DIR_USER}"
    fi
}

# copy user.conf.example to correct location
_update_08() {
    if [ ! -f "$HOME"/.config/RoninDojo/user.conf] ; then
        cp -rv "$HOME"/RoninDojo/user.conf.example "$HOME"/.config/RoninDojo/user.conf
    fi
}