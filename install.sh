#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Do NOT run as root."
  exit 1
fi

echo "=== Updating system ==="
sudo dnf upgrade -y

echo "=== Installing Wayland + Hyprland stack ==="
sudo dnf install -y \
  hyprland \
  waybar \
  wofi \
  kitty \
  alacritty \
  grim \
  slurp \
  swappy \
  wl-clipboard \
  pipewire \
  wireplumber \
  polkit-gnome \
  network-manager-applet \
  xdg-desktop-portal-hyprland \
  jetbrains-mono-fonts \
  fontawesome-fonts \
  brightnessctl \
  playerctl \
  pamixer \
  swaylock \
  hyprpaper \
  git \
  curl \
  unzip

echo "=== Enabling required services ==="
sudo systemctl enable NetworkManager
sudo systemctl set-default graphical.target

systemctl --user enable pipewire || true
systemctl --user enable wireplumber || true

echo "=== Installing minimal display manager ==="
sudo dnf install -y sddm
sudo systemctl enable sddm

echo "=== Cloning ML4W ==="
if [ ! -d "$HOME/.ml4w" ]; then
  git clone https://github.com/mylinuxforwork/hyprland-starter.git "$HOME/.ml4w"
fi

mkdir -p "$HOME/.config"
cp -r "$HOME/.ml4w/dotfiles/.config/"* "$HOME/.config/" 2>/dev/null || true

echo "=== Cleaning Arch references ==="
sed -i '/pacman/d' "$HOME/.config/hypr/hyprland.conf" 2>/dev/null || true
sed -i '/yay/d' "$HOME/.config/hypr/hyprland.conf" 2>/dev/null || true

echo "=== Done ==="
echo "Reboot. Select Hyprland in SDDM."
