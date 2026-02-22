#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Do NOT run as root."
  exit 1
fi

echo "=== Updating system ==="
sudo dnf upgrade -y

echo "=== Installing COPR support ==="
sudo dnf install -y dnf-plugins-core

echo "=== Enabling solopasha Hyprland COPR ==="
sudo dnf copr enable -y solopasha/hyprland

echo "=== Installing Hyprland stack ==="
sudo dnf install -y \
  hyprland \
  waybar \
  wofi \
  kitty \
  grim \
  slurp \
  wl-clipboard \
  pipewire \
  wireplumber \
  polkit \
  xdg-desktop-portal-hyprland \
  sddm \
  git

echo "=== Enabling services ==="
sudo systemctl enable NetworkManager
sudo systemctl enable sddm
sudo systemctl set-default graphical.target

echo "=== Done ==="
echo "Reboot."
