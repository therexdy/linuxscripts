#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

echo "Starting Arch Linux Desktop Environment setup."

# Ensure sudo keeps asking for password if it expires
sudo -v || exit 1

read -rp "Set up CUPS? (y/n): " setup_cups
if [[ "${setup_cups,,}" == "y" ]]; then
    sudo pacman -S --noconfirm cups
    sudo systemctl enable --now cups.service
fi

read -rp "Set up Bluetooth? (y/n): " setup_bluetooth
if [[ "${setup_bluetooth,,}" == "y" ]]; then
    sudo pacman -S --noconfirm bluez bluez-utils blueman
    sudo systemctl enable --now bluetooth.service
fi

read -rp "Set up audio (PipeWire)? (y/n): " setup_audio
if [[ "${setup_audio,,}" == "y" ]]; then
    sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol
    systemctl --user enable --now pipewire pipewire-pulse wireplumber
fi

read -rp "Set up Desktop Environment (Sway)? (y/n): " setup_desktop
if [[ "${setup_desktop,,}" == "y" ]]; then
    sudo pacman -S --noconfirm networkmanager ntfs-3g sway swaybg swaylock swayidle waybar wl-clipboard grim slurp vlc imv thunar thunar-volman tumbler ffmpegthumbnailer thunar-archive-plugin file-roller gvfs gvfs-smb gvfs-afc gvfs-mtp gvfs-nfs samba avahi nss-mdns wofi mako xdg-desktop-portal-wlr udisks2 brightnessctl terminator tmux qt5ct qt6ct gnome-themes-extra breeze zip unzip nftables neovim htop ly bash-completion fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool

    sudo systemctl enable --now avahi-daemon

    if ! grep -q "mdns_minimal" /etc/nsswitch.conf; then
        sudo sed -i 's/^\(hosts:.*\) resolve/\1 mdns_minimal [NOTFOUND=return] resolve/' /etc/nsswitch.conf
    fi

    sudo tee /etc/environment > /dev/null << 'EOF'
QT_QPA_PLATFORMTHEME=qt5ct
GTK_THEME=Adwaita-dark
XDG_CURRENT_DESKTOP=sway
COLOR_SCHEME=dark
EOF

    # Clone dotfiles repo
    git clone https://gitlab.com/rexdy/dotfiles.git || {
        echo "Failed to clone dotfiles repository. Exiting." >&2
        exit 1
    }

    mkdir -p "$HOME/.config/"

    if [[ -d "dotfiles/dotconfig" ]]; then
        cp -r dotfiles/dotconfig/* "$HOME/.config/"
    fi

    if [[ -f "dotfiles/bashrc" ]]; then
        cp "dotfiles/bashrc" "$HOME/.bashrc"
    fi

    if [[ -d "dotfiles/my_fonts" ]]; then
        sudo cp -r "dotfiles/my_fonts" /usr/share/fonts/
        fc-cache -f
    fi

    FCITX_ENV_FILE="$HOME/.profile"
    {
        echo ''
        echo '# Fcitx5 environment variables'
        echo 'export GTK_IM_MODULE=fcitx'
        echo 'export QT_IM_MODULE=fcitx'
        echo 'export XMODIFIERS="@im=fcitx"'
        echo 'export INPUT_METHOD=fcitx'
    } >> "$FCITX_ENV_FILE"

    sudo systemctl enable NetworkManager ly

    if ! grep -q "^username=" /etc/ly/config.ini 2>/dev/null; then
        echo "username=$USER" | sudo tee -a /etc/ly/config.ini > /dev/null
    fi
fi

read -rp "Install Yay (AUR helper)? (y/n): " setup_yay
if [[ "${setup_yay,,}" == "y" ]]; then
    sudo pacman -S --noconfirm git base-devel

    temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$temp_dir"
    pushd "$temp_dir" > /dev/null
    makepkg -si --noconfirm
    popd > /dev/null
    rm -rf "$temp_dir"
fi

echo
echo "✅ Setup complete. Reboot recommended."
echo
echo "📌 IMPORTANT:"
echo "- If this is a laptop, install TLP and enable it:"
echo "    sudo pacman -S --noconfirm tlp"
echo "    sudo systemctl enable tlp"
echo
echo "- Set up Keyboard Layouts via 'fcitx5-configtool'"
echo

