#!/bin/bash

set -e

echo "Starting Arch Linux Desktop Environment setup."

sudo -v || exit 1

read -rp "Set up CUPS? (y/n): " setup_cups
if [[ "${setup_cups,,}" == "y" ]]; then
    sudo pacman -S --noconfirm cups
    sudo systemctl enable --now cups.service
fi

read -rp "Set up Bluetooth? (y/n): " setup_bluetooth
if [[ "${setup_bluetooth,,}" == "y" ]]; then
    sudo pacman -S --noconfirm bluez bluez-utils
    sudo systemctl enable --now bluetooth.service
fi

read -rp "Set up audio (PipeWire)? (y/n): " setup_audio
if [[ "${setup_audio,,}" == "y" ]]; then
    sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol
    systemctl --user enable --now pipewire pipewire-pulse wireplumber
fi

read -rp "Set up Desktop Environment(sway)? (y/n): " setup_desktop
if [[ "${setup_desktop,,}" == "y" ]]; then
    sudo pacman -S --noconfirm networkmanager ntfs-3g sway swaybg swaylock swayidle waybar wl-clipboard grim slurp vlc imv gvfs gvfs-mtp wofi nautilus mako xdg-desktop-portal-wlr udisks2 brightnessctl terminator tmux qt5ct qt6ct gnome-themes-extra breeze zip unzip ufw neovim htop ly bash-completion

    sudo tee /etc/environment > /dev/null << 'EOF'
QT_QPA_PLATFORMTHEME=qt5ct
GTK_THEME=Adwaita-dark
XDG_CURRENT_DESKTOP=sway
COLOR_SCHEME=dark
EOF

    git clone https://github.com/truerexdy/dotfiles.git

    mkdir -p ~/.config/
    [[ -d "dotfiles/dotconfig" ]] && cp -r dotfiles/dotconfig/* ~/.config/
    if [[ -d "dotfiles/my_fonts" ]]; then
        sudo cp -r dotfiles/my_fonts /usr/share/fonts/
        fc-cache -f
    fi

    sudo systemctl enable NetworkManager ufw ly
    echo "username=\"$USER\"" | sudo tee -a /etc/ly/config.ini > /dev/null

fi

read -rp "Install Yay? (y/n): " setup_yay
if [[ "${setup_yay,,}" == "y" ]]; then
    sudo pacman -S --noconfirm git base-devel
    
    temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$temp_dir"
    cd "$temp_dir"
    makepkg -si --noconfirm
    cd - > /dev/null
    rm -rf "$temp_dir"
fi

echo "Setup complete. Reboot recommended."
echo
echo "IMPORTANT"
echo "If this is a Laptop, install tlp and enable it by doing"
echo "sudo pacman -S --noconfirm tlp"
echo "sudo systemctl enable tlp"
echo
