#!/bin/bash
set -e
echo "Starting optional Arch Linux setup."

read -rp "Elevate privileges for setup? (y/n): " confirm_sudo
[ "${confirm_sudo,,}" = "y" ] || { echo "Sudo privileges not confirmed. Exiting."; exit 1; }
sudo -v || { echo "Sudo authentication failed or cancelled. Exiting."; exit 1; }

install_packages() {
    local type=$1
    shift
    read -rp "Install $type packages? (y/N): " response
    [ "${response,,}" = "y" ] && { echo "Installing $type packages."; sudo pacman -S --noconfirm "$@"; } || echo "$type package installation skipped."
    echo
}

install_packages "essential" firefox gnome-clocks qalculate-gtk htop okular gedit pavucontrol grim keepassxc ffmpeg baobab kdeconnect

install_packages "development" docker git curl gcc go make cmake

install_packages "productivity" libreoffice gnome-calendar obsidian

echo "Script finished."
echo "Reboot recommended."
