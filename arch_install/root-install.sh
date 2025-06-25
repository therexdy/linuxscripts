#!/bin/bash

set -e

[[ $EUID -ne 0 ]] && { echo "This script must be run as root"; exit 1; }

detect_cpu() {
    if lscpu | grep -q "AuthenticAMD"; then
        MICROCODE="amd-ucode"
    elif lscpu | grep -q "GenuineIntel"; then
        MICROCODE="intel-ucode"
    else
        MICROCODE=""
    fi
}

detect_gpu() {
    GPU_PACKAGES=()
    lspci | grep -qi nvidia && GPU_PACKAGES+=(nvidia nvidia-utils)
    lspci | grep -qi -E "(amd|ati|radeon)" && GPU_PACKAGES+=(mesa vulkan-radeon)
    lspci | grep -qi "intel.*graphics" && GPU_PACKAGES+=(mesa vulkan-intel)
    [[ ${#GPU_PACKAGES[@]} -eq 0 ]] && GPU_PACKAGES=(mesa)
}

is_laptop() {
    ls /sys/class/power_supply/BAT* &> /dev/null
}

echo "Starting Arch Linux setup."

pacman -Syu --noconfirm

detect_cpu
detect_gpu

BASE_PACKAGES=(neovim sudo git ufw networkmanager base-devel grub efibootmgr linux-firmware)
[[ -n "$MICROCODE" ]] && BASE_PACKAGES+=("$MICROCODE")

pacman -S --noconfirm "${BASE_PACKAGES[@]}" "${GPU_PACKAGES[@]}"

command -v grub-install &> /dev/null || { echo "Essential packages missing. Exiting."; exit 1; }

if [[ -d /sys/firmware/efi ]]; then
    EFI_DIR="/boot"
    [[ -d "/boot/efi" ]] && EFI_DIR="/boot/efi"
    grub-install --target=x86_64-efi --efi-directory="$EFI_DIR" --bootloader-id=GRUB --recheck
else
    echo "BIOS detected. Run: grub-install --target=i386-pc /dev/sdX"
    exit 1
fi

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager systemd-timesyncd
ufw --force enable

grep -q "^en_IN.UTF-8 UTF-8" /etc/locale.gen || echo "en_IN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_IN.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

while true; do
    read -rp "Enter hostname: " hname
    if [[ "$hname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]] && [[ ${#hname} -le 63 ]]; then
        echo "$hname" > /etc/hostname
        cat > /etc/hosts << EOF
127.0.0.1       localhost
::1             localhost
127.0.1.1       $hname.localdomain $hname
EOF
        break
    else
        echo "Invalid hostname."
    fi
done

echo "Setting root password:"
passwd

[[ -f "/usr/share/zoneinfo/Asia/Kolkata" ]] && {
    ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
    hwclock --systohc
}

read -rp "Enter username: " uname
if [[ "$uname" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
    useradd -m -G wheel "$uname"
    passwd "$uname"
    echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
fi

read -rp "Disable root login? (y/n): " disable_root
[[ "$disable_root" == "y" ]] && {
    passwd -l root
    echo "Root account disabled. Use sudo."
}

is_laptop && {
    pacman -S --noconfirm tlp
    systemctl enable tlp
}

pacman -S --noconfirm pipewire pipewire-pulse wireplumber

echo "Arch Linux setup complete. Reboot recommended."
