#!/bin/bash
read -rp "Set up Desktop Environment? (y/n): " setup_desktop_env
[ "${setup_desktop_env,,}" = "y" ] || { echo "Desktop environment setup skipped."; exit 0; }

echo "Installing desktop environment packages."
sudo pacman -Syu --noconfirm networkmanager ntfs-3g sway swaybg swaylock swayidle waybar wl-clipboard grim slurp vlc imv ibus gvfs gvfs-mtp scrcpy wofi nautilus mako lxsession lightdm zip unzip neovim xdg-desktop-portal xdg-desktop-portal-wlr fontconfig ttf-dejavu noto-fonts udisks2 brightnessctl pavucontrol alsa-utils lightdm-gtk-greeter terminator tmux tar qt5ct qt6ct gnome-themes-extra breeze gsettings-desktop-schemas dconf

echo "Configuring dark theme."
mkdir -p ~/.config/gtk-{3,4}.0 ~/.config/qt{5,6}ct

cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-application-prefer-dark-theme=true
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
EOF

cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/

cat > ~/.config/qt5ct/qt5ct.conf << 'EOF'
[Appearance]
icon_theme=Adwaita
style=Breeze-Dark
EOF

cp ~/.config/qt5ct/qt5ct.conf ~/.config/qt6ct/

for env in 'QT_QPA_PLATFORMTHEME="qt5ct"' 'GTK_THEME="Adwaita-dark"' 'XDG_CURRENT_DESKTOP="sway"' 'COLOR_SCHEME="dark"'; do
    echo "export $env" | sudo tee "/etc/profile.d/$(echo "$env" | cut -d'=' -f1 | tr '[:upper:]' '[:lower:]').sh" > /dev/null
done

command -v gsettings > /dev/null && gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

systemctl --user enable --now xdg-desktop-portal-wlr.service

echo "Copying dotfiles."
[ -d "dotconfig" ] && { cp -r dotconfig/* ~/.config/; echo "Dotfiles copied."; } || echo "Warning: 'dotconfig' not found. Skipping dotfile copy."

echo "Copying fonts."
[ -d "assets/MyFonts" ] && { sudo cp -r assets/MyFonts /usr/share/fonts/; sudo fc-cache -fv; echo "Fonts copied and cache updated."; } || echo "Warning: 'assets/MyFonts' not found. Skipping font copy."

echo "Desktop environment setup complete. Configure greetd manually."
