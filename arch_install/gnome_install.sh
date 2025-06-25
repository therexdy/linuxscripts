#!/bin/bash
set -e
[[ $EUID -eq 0 ]] && { echo "Error: Do not run as root"; exit 1; }
command -v sudo > /dev/null || { echo "Error: sudo not found"; exit 1; }

echo "Updating system packages..."
sudo pacman -Syu --noconfirm

echo "Installing Wayland display server..."
sudo pacman -S --noconfirm wayland

echo "Installing minimal GNOME desktop environment..."
sudo pacman -S --noconfirm gnome-shell gnome-session gnome-desktop gnome-control-center nautilus

echo "Installing essential GNOME utilities..."
sudo pacman -S --noconfirm gnome-keyring gnome-settings-daemon gnome-screenshot gnome-system-monitor gnome-disk-utility gnome-calculator gnome-clocks

echo "Installing system utilities..."
sudo pacman -S --noconfirm networkmanager pipewire pipewire-pulse wireplumber

echo "Enabling NetworkManager..."
sudo systemctl enable NetworkManager

echo "Cleaning pacman cache..."
sudo pacman -Sc --noconfirm

echo "Removing orphaned packages..."
pacman -Qtdq > /dev/null 2>&1 && { sudo pacman -Rns $(pacman -Qtdq) --noconfirm; echo "Orphaned packages removed."; } || echo "No orphaned packages found."

echo "Performing final cache cleanup..."
sudo pacman -Scc --noconfirm

echo "Minimal GNOME with Wayland installation completed successfully!"
echo "To start GNOME, run 'gnome-session' from a TTY (Ctrl+Alt+F2)"
echo "GNOME will automatically use Wayland when available."
echo

read -p "Would you like to reboot now? (y/N): " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] && { echo "Rebooting system..."; sudo reboot; } || echo "Please reboot manually when ready."
