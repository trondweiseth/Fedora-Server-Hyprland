#!/usr/bin/env bash
set -euo pipefail

############################################
# Fedora Server → Hyprland + ML4W Bootstrap
############################################

if [[ $EUID -eq 0 ]]; then
  echo "Do NOT run as root. Run as normal user."
  exit 1
fi

echo "=== Updating system ==="
sudo dnf upgrade -y

echo "=== Installing base desktop stack ==="
sudo dnf groupinstall -y "Basic Desktop"

echo "=== Installing Hyprland + Wayland tools ==="
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

echo "=== Cloning ML4W Hyprland Starter ==="
if [ ! -d "$HOME/.ml4w" ]; then
  git clone https://github.com/mylinuxforwork/hyprland-starter.git "$HOME/.ml4w"
fi

echo "=== Installing ML4W dotfiles ==="
mkdir -p "$HOME/.config"

# Copy only config files
cp -r "$HOME/.ml4w/dotfiles/.config/"* "$HOME/.config/" 2>/dev/null || true

echo "=== Patching Arch-specific Waybar pacman module (if present) ==="

if grep -q "pacman" "$HOME/.config/waybar/config" 2>/dev/null; then
  sed -i 's/pacman.*/dnf check-update | wc -l/g' "$HOME/.config/waybar/config"
fi

echo "=== Cleaning potential Arch-specific autostart entries ==="
sed -i '/pacman/d' "$HOME/.config/hypr/hyprland.conf" 2>/dev/null || true
sed -i '/yay/d' "$HOME/.config/hypr/hyprland.conf" 2>/dev/null || true

echo "=== Creating basic fallback hyprland.conf if missing ==="
if [ ! -f "$HOME/.config/hypr/hyprland.conf" ]; then
  mkdir -p "$HOME/.config/hypr"
  cat <<EOF > "$HOME/.config/hypr/hyprland.conf"
monitor=,preferred,auto,1

exec-once = waybar
exec-once = nm-applet
exec-once = hyprpaper

EOF
fi

echo "=== Bootstrap Complete ==="
echo "Reboot the system."
echo "Select Hyprland from login manager."
