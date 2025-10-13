#!/bin/bash

set -e

echo "Requesting sudo access..."
sudo -v

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

install_snap_if_needed() {
    if ! command -v snap &> /dev/null; then
        echo "Installing snapd..."
        sudo apt update
        sudo apt install -y snapd
        sudo systemctl enable --now snapd.socket
        
        if [ ! -L /snap ]; then
            sudo ln -s /var/lib/snapd/snap /snap
        fi
        
        echo "Installing snap core..."
        sudo snap install core
        
        export PATH="/snap/bin:$PATH"
    fi
}

DISTRO=$(detect_distro)

case "$DISTRO" in
    ubuntu)
        echo "Detected Ubuntu"
        sudo snap install nvim --classic
        sudo apt update
        sudo apt install -y git npm
        ;;
    debian)
        echo "Detected Debian"
        install_snap_if_needed
        sudo snap install nvim --classic
        sudo apt update
        sudo apt install -y git npm
        ;;
    arch|manjaro)
        echo "Detected Arch-based system"
        sudo pacman -Syu --noconfirm
        sudo pacman -S --noconfirm neovim git npm
        ;;
    fedora|rhel|centos|rocky|almalinux)
        echo "Detected RedHat-based system"
        sudo dnf update -y
        sudo dnf install -y neovim git npm
        ;;
    *)
        echo "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

echo "Cloning linuxscripts..."
git clone https://github.com/therexdy/linuxscripts.git

echo "Running netsetup.sh..."
sudo bash linuxscripts/utils/netsetup.sh

rm -rf linuxscripts

echo "Cloning nvim config..."
git clone https://gist.github.com/3657283998504c72da23eb1233bcbf7e.git

mkdir -p "$HOME/.config/nvim"

if [ -f "$HOME/.config/nvim/init.lua" ]; then
    mv "$HOME/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua.backup.$(date +%s)"
    echo "Existing init.lua backed up"
fi

cp 3657283998504c72da23eb1233bcbf7e/init.lua "$HOME/.config/nvim/"
rm -rf 3657283998504c72da23eb1233bcbf7e

echo "Setup complete!"
echo "Note: On Debian, you may need to logout/login for snap paths to update fully"

