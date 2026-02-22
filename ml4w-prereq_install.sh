#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Kjør som vanlig bruker, ikke root."
  exit 1
fi

echo "=== Fedora 43 Server -> Hyprland (ML4W deps) ==="

echo "[1/6] Oppdater system"
sudo dnf upgrade -y

echo "[2/6] Installer dnf-plugins-core (trengs for COPR)"
sudo dnf install -y dnf-plugins-core

echo "[3/6] Enable COPR: solopasha/hyprland"
sudo dnf copr enable -y solopasha/hyprland

echo "[4/6] Enable COPR: che/nerd-fonts (for Nerd glyphs/fallback)"
sudo dnf copr enable -y che/nerd-fonts

echo "[5/6] Installer avhengigheter (Fedora-navn)"

PKGS=(
  # core
  hyprland
  waybar
  rofi-wayland
  kitty
  dunst
  thunar
  xdg-desktop-portal-hyprland
  qt5-qtwayland
  qt6-qtwayland
  hyprpaper
  hyprlock
  firefox

  # fonts
  fontawesome-fonts-all
  mozilla-fira-sans-fonts
  fira-code-fonts
  nerd-fonts

  # utils
  vim
  fastfetch
  jq
  brightnessctl
  NetworkManager
  wireplumber
)

# Installer kun pakker som faktisk finnes i aktive repos
INSTALL=()
SKIP=()

for p in "${PKGS[@]}"; do
  if dnf -q list --available "$p" >/dev/null 2>&1 || dnf -q list --installed "$p" >/dev/null 2>&1; then
    INSTALL+=("$p")
  else
    SKIP+=("$p")
  fi
done

if ((${#INSTALL[@]})); then
  sudo dnf install -y "${INSTALL[@]}"
fi

if ((${#SKIP[@]})); then
  echo "SKIPPET (ikke funnet i repos): ${SKIP[*]}"
fi

echo "[6/6] Enable tjenester"
sudo systemctl enable NetworkManager
sudo systemctl set-default graphical.target

echo "FERDIG. Reboot."
