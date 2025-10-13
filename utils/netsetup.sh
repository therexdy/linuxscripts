#!/bin/bash

set -e

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distro)

case "$DISTRO" in
    ubuntu|debian)
        echo "Detected Debian-based system"
        apt-get update
        apt-get -y install \
            iproute2 \
            net-tools \
            isc-dhcp-client \
            wpasupplicant \
            network-manager \
            iw \
            wireless-tools \
            rfkill \
            iputils-ping \
            traceroute \
            mtr \
            nmap \
            netcat-openbsd \
            tcpdump \
            curl \
            wget \
            ethtool \
            bind9-host \
            dnsutils \
            nftables \
            bmon
        ;;
    arch|manjaro)
        echo "Detected Arch-based system"
        pacman -Sy --noconfirm
        pacman -S --noconfirm \
            iproute2 \
            net-tools \
            dhcpcd \
            wpa_supplicant \
            networkmanager \
            iw \
            wireless_tools \
            rfkill \
            iputils \
            traceroute \
            mtr \
            nmap \
            netcat \
            tcpdump \
            curl \
            wget \
            ethtool \
            bind \
            nftables \
            bmon
        ;;
    fedora|rhel|centos|rocky|almalinux)
        echo "Detected RedHat-based system"
        dnf update -y
        dnf install -y \
            iproute \
            net-tools \
            dhcp-client \
            wpa_supplicant \
            NetworkManager \
            iw \
            wireless-tools \
            rfkill \
            iputils \
            traceroute \
            mtr \
            nmap \
            nmap-ncat \
            tcpdump \
            curl \
            wget \
            ethtool \
            bind-utils \
            nftables \
            bmon
        ;;
    *)
        echo "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

echo "Network tools installation complete!"

