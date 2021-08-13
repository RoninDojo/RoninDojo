#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

_load_user_conf

OPTIONS=(1 "Start"
         2 "Stop"
         3 "Restart"
         4 "Enable Public Key Authentication"
         5 "Disable Public Key Authentication"
         6 "Add Public Key"
         7 "Delete Public Key"
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
        if _is_active sshd; then
            printf "%s\n***\nStarting SSH...\n***%s\n" "${red}" "${nc}"
        else
            printf "%s\n***\nSSH already started...\n***%s\n" "${red}" "${nc}"
        fi

        _pause continue
        bash -c "${ronin_ssh_menu}"
        ;;
    2)
        printf "%s\n***\nStopping SSH...\n***%s\n" "${red}" "${nc}"

        if systemctl is-active --quiet sshd; then
            sudo systemctl stop --quiet sshd
        else
            printf "%s\n***\nSSH already stopped...\n***%s\n" "${red}" "${nc}"
        fi

        _pause continue
        bash -c "${ronin_ssh_menu}"
        ;;
    3)
        printf "%s\n***\nRestarting SSH...\n***%s\n" "${red}" "${nc}"

        sudo systemctl reload-or-restart --quiet sshd

        _pause continue
        bash -c "${ronin_ssh_menu}"
        ;;
    4)
        # If already enabled, just return to menu
        if _ssh_key_authentication enable; then
            if _ssh_key_authentication add-ssh-key; then
                printf "%s\n***\nVerify connection now...\n***%s\n" "${red}" "${nc}"

                _pause continue

                if ! _yes_or_no "Did connection work?"; then
                    _ssh_key_authentication disable
                fi

                printf "%s\n***\nReturning to menu...\n***%s\n" "${red}" "${nc}"
            fi
        fi

        _pause continue
        # Return to menu
        bash -c "${ronin_ssh_menu}"
        ;;
    5)
        if ! sudo grep -q "UsePAM no" /etc/ssh/sshd_config; then
            printf "%s\n***\nSSH Key Authentication not enabled! Returning to menu...\n***%s\n" "${red}" "${nc}"
        else
            printf "%s\n***\nDisabling SSH Key Authentication...\n***%s\n\n" "${red}" "${nc}"

            if _yes_or_no "${red}Do you wish to continue?${nc}"; then
                _ssh_key_authentication disable
            fi
        fi

        _pause continue
        bash -c "${ronin_ssh_menu}"
        ;;
    6)
        if ! sudo grep -q "UsePAM no" /etc/ssh/sshd_config; then
            printf "%s\n***\nSSH Key Authentication not enabled! Returning to menu...\n***%s\n" "${red}" "${nc}"
        else
            if _ssh_key_authentication add-ssh-key; then
                printf "%s\n***\nKey successfully added... Returning to menu...\n***%s\n" "${red}" "${nc}"
            else
                printf "%s\n***\nKey already exists... Returning to menu...\n***%s\n" "${red}" "${nc}"
            fi
        fi

        _pause continue
        bash -c "${ronin_ssh_menu}"
        ;;
    7)
        if ! sudo grep -q "UsePAM no" /etc/ssh/sshd_config; then
            printf "%s\n***\nSSH Key Authentication not enabled! Returning to menu...\n***%s\n" "${red}" "${nc}"
        else
            if _ssh_key_authentication del-ssh-key; then
                printf "%s\n***\nKey has been removed... Returning to menu\n***%s\n" "${red}" "${nc}"
            else
                printf "%s\n***\nKey not available to delete... Returning to menu\n***%s\n" "${red}" "${nc}"
            fi
        fi

        _pause continue
        bash -c "${ronin_ssh_menu}"
        ;;
    8)
        bash -c "${ronin_networking_menu}"
        ;;
esac

exit