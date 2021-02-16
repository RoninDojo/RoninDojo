#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh

_update_01() {
    if ! _check_pkgver bridge-utils 1.7-1; then
        cat <<EOF
${red}
***
Outdated and bridge-utils found...
***
${nc}
EOF
        _sleep 2
        cat <<EOF
${red}
***
Starting bridge-utils upgrade...
***
${nc}
EOF
        sudo pacman --quiet -U --noconfirm https://ronindojo.io/downloads/distfiles/bridge-utils-1.7-1-aarch64.pkg.tar.xz &>/dev/null

        # If existing dojo found, then reboot system to apply changes
        if [ -d "${HOME}/dojo" ]; then
            cat <<EOF
${red}
***
Existing dojo found! Rebooting system to apply changes...
***
${nc}
EOF
            _sleep 2
            cat <<EOF
${red}
***
Press Ctrl+C now if you wish to skip...
***
${nc}
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
    fi

    # Some systems have issue with tor not starting unless User=tor is enabled.
    if ! systemctl is-active --quiet tor && ! grep "User=tor" /usr/lib/systemd/system/tor.service 1>/dev/null; then
        sudo sed -i '/Type=notify/a\User=tor' /usr/lib/systemd/system/tor.service
        sudo systemctl daemon-reload
        _is_active tor
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
    _load_user_conf

    local uuid tmp systemd_mountpoint fstype

    if findmnt /mnt/usb 1>/dev/null && [ ! -f /etc/systemd/system/mnt-usb.mount ]; then
        uuid=$(lsblk -no UUID "${primary_storage}")
        tmp=${install_dir:1}                                    # Remove leading '/'
        systemd_mountpoint=${tmp////-}                          # Replace / with -
        fstype=$(blkid -o value -s TYPE "${primary_storage}")

        cat <<EOF
${red}
***
Adding missing systemd mount unit file for device ${primary_storage}...
***
${nc}
EOF
        sudo bash -c "cat <<EOF >/etc/systemd/system/${systemd_mountpoint}.mount
[Unit]
Description=Mount External SSD Drive ${primary_storage}

[Mount]
What=/dev/disk/by-uuid/${uuid}
Where=${install_dir}
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

# Migrate bitcoin ibd data to new backup directory
_update_09() {
    if sudo test -d "${install_dir}"/bitcoin && sudo test -d "${install_dir}"/bitcoin/blocks; then
        sudo test -d "${dojo_backup_bitcoind}" || sudo mkdir "${dojo_backup_bitcoind}"

        for dir in blocks chainstate indexes; do
            if sudo test -d "${install_dir}"/bitcoin/"${dir}"; then
                sudo mv "${install_dir}"/bitcoin/"${dir}" "${dojo_backup_bitcoind}"/
            fi
        done

        # Remove legacy directory
        rm -rf "${install_dir}"/bitcoin
    fi
}

# Migrate user.conf variables to lowercase
_update_10() {
    if [ -f "${HOME}"/.config/RoninDojo/user.conf ]; then
        for var in "PRIMARY_STORAGE" "SECONDARY_STORAGE" "INSTALL_DIR" "RONIN_UI_BACKEND_DIR" "GUI_API" "RONIN_DOJO_BRANCH" "SAMOURAI_COMMITISH"; do
            if grep "${var}" "${HOME}"/.config/RoninDojo/user.conf 1>/dev/null; then
                sed -i "s/${var}/${var,,}/" "${HOME}"/.config/RoninDojo/user.conf
            fi
        done
    fi
}