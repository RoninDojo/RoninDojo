#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

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
            sudo bash -c "cat <<EOF >>${sudoers_file}
ALL ALL=(root) NOPASSWD: /usr/bin/systemctl reboot, /usr/bin/systemctl poweroff
EOF"
        fi
    fi
}

# Add password less for /usr/bin/{ufw,mount,umount,cat,grep,test,mkswap,swapon,swapoff} privileges to sudo
_update_04() {
    if [ -f "${sudoers_path}" ]; then
        if ! grep "/usr/bin/test" "${sudoers_file}" 1>/dev/null; then
            sudo bash -c "cat <<EOF >>${sudoers_file}
ALL ALL=(root) NOPASSWD: /usr/bin/test, /usr/bin/grep, /usr/bin/cat, /usr/bin/ufw
ALL ALL=(root) NOPASSWD: /usr/bin/umount, /usr/bin/mount, /usr/bin/mkswap, /usr/bin/swapon, /usr/bin/swapoff
EOF"
        fi
    fi
}

# Fix tor unit file
_update_05() {
    if findmnt /mnt/usb 1>/dev/null && ! systemctl is-active --quiet tor; then
        sudo sed -i 's:^ReadWriteDirectories=-/var/lib/tor.*$:ReadWriteDirectories=-/var/lib/tor /mnt/usb/tor:' /usr/lib/systemd/system/tor.service
        sudo systemctl daemon-reload

        _is_active tor

        # Some systems have issue with tor not starting unless User=tor is enabled.
        if ! systemctl is-active --quiet tor && ! grep "User=tor" /usr/lib/systemd/system/tor.service 1>/dev/null; then
            sudo sed -i '/Type=notify/a\User=tor' /usr/lib/systemd/system/tor.service
            _is_active tor
        fi
    fi
}

# Modify pacman.conf and add ignore packages
_update_06() {
    if ! grep "${pkg_ignore[0]}" /etc/pacman.conf 1>/dev/null; then
        sudo sed -i "s:^#IgnorePkg   =.*$:IgnorePkg   = ${pkg_ignore[*]}:" /etc/pacman.conf
    fi
}

# Copy user.conf.example to correct location
_update_07() {
    if [ ! -f "$HOME"/.config/RoninDojo/user.conf ] ; then
        cp "$HOME"/RoninDojo/user.conf.example "$HOME"/.config/RoninDojo/user.conf
    fi
}

# Create mnt-usb.mount if missing and system is already mounted.
_update_08() {
    . "${HOME}"/RoninDojo/Scripts/defaults.sh

    _load_user_conf

    local uuid tmp systemd_mountpoint fstype

    if findmnt /mnt/usb  1>/dev/null && [ ! -f /etc/systemd/system/mnt-usb.mount ]; then
        uuid=$(lsblk -no UUID "${PRIMARY_STORAGE}")
        tmp=${INSTALL_DIR:1}                                    # Remove leading '/'
        systemd_mountpoint=${tmp////-}                          # Replace / with -
        fstype=$(blkid -o value -s TYPE "${PRIMARY_STORAGE}")

        cat <<EOF
${RED}
***
Adding missing systemd mount unit file for device ${PRIMARY_STORAGE}...
***
${NC}
EOF
        sudo bash -c "cat <<EOF >/etc/systemd/system/${systemd_mountpoint}.mount
[Unit]
Description=Mount External SSD Drive ${PRIMARY_STORAGE}

[Mount]
What=/dev/disk/by-uuid/${uuid}
Where=${INSTALL_DIR}
Type=${fstype}
Options=defaults

[Install]
WantedBy=multi-user.target
EOF"
        sudo systemctl enable mnt-usb.mount 2>/dev/null

        _sleep 4 --msg "Restarting RoninDojo in"

        ronin
    fi
}