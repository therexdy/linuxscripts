#!/bin/bash

pacman_packages=(iproute2 net-tools dhcpcd wpa_supplicant networkmanager iw wireless_tools rfkill iputils traceroute mtr nmap netcat tcpdump curl wget ethtool bind dnsutils nftables bmon)

apt_packages=(iproute2 net-tools isc-dhcp-client wpasupplicant network-manager iw wireless-tools rfkill iputils-ping traceroute mtr nmap netcat-openbsd tcpdump curl wget ethtool bind9-host dnsutils nftables bmon)

if command -v apt > /dev/null 2>&1; then
    apt-get update
    apt-get -y install "${apt_packages[@]}" 
elif command -v pacman > /dev/null 2>&1; then
    pacman -Sy
    pacman -S --noconfirm "${pacman_packages[@]}" 
else
    echo "No supported package manager found"
    exit 1
fi
