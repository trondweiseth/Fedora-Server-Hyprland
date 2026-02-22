#!/usr/bin/env bash
set -e

echo "[+] Oppdaterer system"
sudo dnf upgrade -y

echo "[+] Installerer nødvendige verktøy"
sudo dnf install -y \
    dnf5-plugins \
    curl \
    git

echo "[+] Aktiverer COPR for Hyprland"
if ! sudo dnf copr list | grep -q solopasha/hyprland; then
    sudo dnf copr enable -y solopasha/hyprland || {
        echo "[!] COPR via dnf feilet, bruker fallback repo-fil"
        sudo curl -o /etc/yum.repos.d/_copr_solopasha-hyprland.repo \
        https://copr.fedorainfracloud.org/coprs/solopasha/hyprland/repo/fedora-43/solopasha-hyprland-fedora-43.repo
    }
fi

echo "[+] Oppdaterer cache"
sudo dnf makecache

echo "[+] Installerer Hyprland stack"
sudo dnf install -y \
    hyprland \
    kitty \
    wofi \
    waybar \
    sddm \
    xorg-x11-server-Xwayland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-wlr \
    polkit-kde-agent \
    pipewire wireplumber \
    grim slurp wl-clipboard \
    google-noto-fonts \
    NetworkManager

echo "[+] Aktiverer tjenester"
sudo systemctl enable NetworkManager
sudo systemctl enable sddm
sudo systemctl set-default graphical.target

echo "[+] Lager standard Hyprland config hvis mangler"
mkdir -p ~/.config/hypr
if [ ! -f ~/.config/hypr/hyprland.conf ]; then
    cp /usr/share/hyprland/hyprland.conf ~/.config/hypr/
fi

echo "[+] Ferdig."
echo "Reboot anbefales."
