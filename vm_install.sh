#!/bin/bash
set -euo pipefail

check_virt_support() {
  if grep -E -q '(vmx|svm)' /proc/cpuinfo; then
    echo "Virtualization support detected."
  else
    echo "Warning: No virtualization support detected in CPU. KVM might not work."
  fi
}

install_packages() {
  echo "Updating package database..."
  sudo pacman -Sy --noconfirm

  echo "Installing QEMU, KVM, libvirt, and virt-manager..."
  sudo pacman -S --noconfirm qemu libvirt virt-manager dnsmasq vde2 bridge-utils openbsd-netcat

  echo "Enabling and starting libvirtd service..."
  sudo systemctl enable --now libvirtd
}

add_user_to_group() {
  local user=$1
  if id -nG "$user" | grep -qw libvirt; then
    echo "User $user is already in the libvirt group."
  else
    echo "Adding user $user to libvirt group..."
    sudo usermod -aG libvirt "$user"
  fi
}

main() {
  check_virt_support

  install_packages

  current_user=$(id -un)
  echo "Adding $current_user to libvirt group..."
  add_user_to_group "$current_user"

  echo
  echo "Setup complete."
  echo "Please reboot your system for all changes to take effect."
  echo "After reboot, you can start virt-manager by running: virt-manager"
}

main

