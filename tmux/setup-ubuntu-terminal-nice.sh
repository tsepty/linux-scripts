#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Ubuntu Terminal Nice Setup
# ============================================================
# What this does:
#   - Installs font utilities
#   - Installs recommended Nerd Fonts locally for the current user
#   - Refreshes the font cache
#   - Optionally configures GNOME Terminal to use JetBrainsMono Nerd Font
#   - Optionally configures GNOME Terminal colors for a darker modern look
#
# Fonts installed by default:
#   - JetBrainsMono Nerd Font
#   - FiraCode Nerd Font
#   - Hack Nerd Font
#   - MesloLGS Nerd Font
#
# Usage:
#   chmod +x setup-ubuntu-terminal-nice.sh
#   ./setup-ubuntu-terminal-nice.sh
#
# Optional:
#   ./setup-ubuntu-terminal-nice.sh --set-gnome-terminal
#   ./setup-ubuntu-terminal-nice.sh --set-gnome-terminal --dark-colors
#   ./setup-ubuntu-terminal-nice.sh --font JetBrainsMono
#   ./setup-ubuntu-terminal-nice.sh --font FiraCode
#   ./setup-ubuntu-terminal-nice.sh --font Hack
#   ./setup-ubuntu-terminal-nice.sh --font Meslo
# ============================================================

SET_GNOME_TERMINAL=false
DARK_COLORS=false
SELECTED_FONT="JetBrainsMono"
INSTALL_ALL_FONTS=true

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --set-gnome-terminal       Set GNOME Terminal font to selected Nerd Font
  --dark-colors              Apply a dark terminal color palette to GNOME Terminal
  --font NAME                Select font for GNOME Terminal profile
                             Options: JetBrainsMono, FiraCode, Hack, Meslo
  --only-selected-font       Install only the selected font instead of all recommended fonts
  -h, --help                 Show this help

Examples:
  $0
  $0 --set-gnome-terminal
  $0 --set-gnome-terminal --dark-colors
  $0 --font FiraCode --set-gnome-terminal
  $0 --font JetBrainsMono --only-selected-font --set-gnome-terminal
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --set-gnome-terminal)
      SET_GNOME_TERMINAL=true
      shift
      ;;
    --dark-colors)
      DARK_COLORS=true
      shift
      ;;
    --font)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --font requires a value."
        usage
        exit 1
      fi
      SELECTED_FONT="$2"
      shift 2
      ;;
    --only-selected-font)
      INSTALL_ALL_FONTS=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

case "$SELECTED_FONT" in
  JetBrainsMono|FiraCode|Hack|Meslo)
    ;;
  *)
    echo "ERROR: Unsupported font: $SELECTED_FONT"
    echo "Supported fonts: JetBrainsMono, FiraCode, Hack, Meslo"
    exit 1
    ;;
esac

echo "==> Installing required packages..."
sudo apt update
sudo apt install -y wget unzip fontconfig dconf-cli

FONT_BASE_DIR="${HOME}/.local/share/fonts"
NERD_FONT_DIR="${FONT_BASE_DIR}/NerdFonts"
TMP_DIR="$(mktemp -d)"

mkdir -p "$NERD_FONT_DIR"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

install_nerd_font() {
  local font_name="$1"
  local zip_name="$2"
  local target_dir="${NERD_FONT_DIR}/${font_name}"

  echo
  echo "==> Installing ${font_name} Nerd Font..."

  if find "$target_dir" -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null | grep -q .; then
    echo "${font_name} Nerd Font already appears to be installed at:"
    echo "  $target_dir"
    return 0
  fi

  mkdir -p "$target_dir"

  local zip_path="${TMP_DIR}/${zip_name}.zip"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${zip_name}.zip"

  echo "Downloading:"
  echo "  $url"

  wget -q --show-progress "$url" -O "$zip_path"

  echo "Extracting to:"
  echo "  $target_dir"

  unzip -q -o "$zip_path" -d "$target_dir"

  # Remove Windows compatibility files if present.
  find "$target_dir" -type f -iname "*Windows Compatible*" -delete 2>/dev/null || true
  find "$target_dir" -type f -iname "*Windows*" -delete 2>/dev/null || true

  echo "${font_name} Nerd Font installed."
}

if [[ "$INSTALL_ALL_FONTS" == true ]]; then
  install_nerd_font "JetBrainsMono" "JetBrainsMono"
  install_nerd_font "FiraCode" "FiraCode"
  install_nerd_font "Hack" "Hack"
  install_nerd_font "Meslo" "Meslo"
else
  case "$SELECTED_FONT" in
    JetBrainsMono)
      install_nerd_font "JetBrainsMono" "JetBrainsMono"
      ;;
    FiraCode)
      install_nerd_font "FiraCode" "FiraCode"
      ;;
    Hack)
      install_nerd_font "Hack" "Hack"
      ;;
    Meslo)
      install_nerd_font "Meslo" "Meslo"
      ;;
  esac
fi

echo
echo "==> Refreshing font cache..."
fc-cache -fv "$FONT_BASE_DIR" >/dev/null

echo
echo "==> Installed Nerd Font matches:"
fc-list | grep -Ei "JetBrainsMono|FiraCode|Hack Nerd|Meslo" | head -n 20 || true

get_gnome_terminal_profile_path() {
  local profile_list
  local default_uuid

  profile_list="$(gsettings get org.gnome.Terminal.ProfilesList list 2>/dev/null || true)"
  default_uuid="$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'" || true)"

  if [[ -z "$default_uuid" || "$default_uuid" == "@as []" ]]; then
    echo ""
    return
  fi

  echo "/org/gnome/terminal/legacy/profiles:/:${default_uuid}/"
}

font_display_name() {
  case "$1" in
    JetBrainsMono)
      echo "JetBrainsMono Nerd Font Mono 12"
      ;;
    FiraCode)
      echo "FiraCode Nerd Font Mono 12"
      ;;
    Hack)
      echo "Hack Nerd Font Mono 12"
      ;;
    Meslo)
      echo "MesloLGS Nerd Font Mono 12"
      ;;
  esac
}

if [[ "$SET_GNOME_TERMINAL" == true ]]; then
  echo
  echo "==> Configuring GNOME Terminal profile..."

  if ! command -v gsettings >/dev/null 2>&1; then
    echo "WARNING: gsettings not found. Cannot configure GNOME Terminal automatically."
  else
    PROFILE_PATH="$(get_gnome_terminal_profile_path)"

    if [[ -z "$PROFILE_PATH" ]]; then
      echo "WARNING: Could not find default GNOME Terminal profile."
      echo "You can still select the font manually in Terminal Preferences."
    else
      BACKUP_FILE="${HOME}/gnome-terminal-profile-backup-$(date +%Y%m%d-%H%M%S).dconf"

      echo "Backing up GNOME Terminal profile to:"
      echo "  $BACKUP_FILE"

      dconf dump "$PROFILE_PATH" > "$BACKUP_FILE" || true

      FONT_NAME="$(font_display_name "$SELECTED_FONT")"

      echo "Setting GNOME Terminal font:"
      echo "  $FONT_NAME"

      dconf write "${PROFILE_PATH}use-system-font" "false"
      dconf write "${PROFILE_PATH}font" "'${FONT_NAME}'"

      if [[ "$DARK_COLORS" == true ]]; then
        echo "Applying dark color palette..."

        dconf write "${PROFILE_PATH}use-theme-colors" "false"
        dconf write "${PROFILE_PATH}background-color" "'rgb(17,17,27)'"
        dconf write "${PROFILE_PATH}foreground-color" "'rgb(205,214,244)'"
        dconf write "${PROFILE_PATH}bold-color-same-as-fg" "true"

        # Catppuccin-ish terminal palette.
        dconf write "${PROFILE_PATH}palette" "['rgb(69,71,90)', 'rgb(243,139,168)', 'rgb(166,227,161)', 'rgb(249,226,175)', 'rgb(137,180,250)', 'rgb(203,166,247)', 'rgb(148,226,213)', 'rgb(186,194,222)', 'rgb(88,91,112)', 'rgb(243,139,168)', 'rgb(166,227,161)', 'rgb(249,226,175)', 'rgb(137,180,250)', 'rgb(203,166,247)', 'rgb(148,226,213)', 'rgb(205,214,244)']"
      fi

      echo "GNOME Terminal profile updated."
      echo "Close and reopen Terminal to see the changes."
    fi
  fi
fi

echo
echo "==> Nerd Font icon test:"
echo "If your terminal font is set correctly, these should appear as icons, not boxes:"
echo "  󰣇  󰌠  󰈙  󰊢  󰆍  󰘬"

echo
echo "==> Done."
echo
echo "Recommended manual terminal font setting:"
echo "  Terminal → Preferences → Your Profile → Text → Custom font"
echo
echo "Recommended font:"
echo "  $(font_display_name "$SELECTED_FONT")"
echo
echo "Best next command for your setup:"
echo "  ./setup-ubuntu-terminal-nice.sh --font JetBrainsMono --set-gnome-terminal --dark-colors"
