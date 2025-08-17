#!/bin/bash
set -e

echo "Updating system packages..."
sudo pacman -Syu --noconfirm

echo "Installing Wine and dependencies..."
sudo pacman -S --noconfirm wine wine-mono wine-gecko

read -rp "Install Winetricks? (y/N): " install_winetricks
if [[ "$install_winetricks" =~ ^[Yy]$ ]]; then
    echo "Installing Winetricks..."
    sudo pacman -S --noconfirm winetricks
fi

read -rp "Install 32-bit libraries for Wine (requires multilib repo)? (y/N): " install_32bit
if [[ "$install_32bit" =~ ^[Yy]$ ]]; then
    echo "Checking if multilib repo is enabled..."
    if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
        echo "Error: multilib repo is NOT enabled. Please enable it in /etc/pacman.conf and rerun the script."
        exit 1
    fi

    echo "Installing 32-bit libraries..."

    libs=(
        lib32-giflib lib32-mpg123 lib32-openal lib32-v4l-utils
        lib32-alsa-plugins lib32-alsa-lib lib32-libpulse lib32-libxcomposite
        lib32-libxinerama lib32-libxslt lib32-libxrandr lib32-libx11
        lib32-libxcursor lib32-libxdamage lib32-libxi lib32-libxext
        lib32-freetype2 lib32-libgl lib32-mesa
    )

    if pacman -Qs nvidia > /dev/null; then
        echo "NVIDIA drivers detected. Adding lib32-nvidia-utils to installation list."
        libs+=(lib32-nvidia-utils)
    else
        echo "NVIDIA drivers NOT detected. Skipping lib32-nvidia-utils."
    fi

    sudo pacman -S --noconfirm "${libs[@]}"
fi

echo "Wine installation process complete!"

