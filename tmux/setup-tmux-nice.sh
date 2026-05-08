#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# tmux Nice Setup for Ubuntu - Polished Native Theme
# ============================================================
#
# Goal:
#   - Looks much nicer than bare tmux
#   - Keeps renamed window/tab names visible
#   - Does NOT use Catppuccin window modules that can hide #W
#   - Avoids tmux-continuum because it can cause:
#       "Tmux resurrect file not found!"
#
# Usage:
#   chmod +x setup-tmux-nice.sh
#   ./setup-tmux-nice.sh
#
# Optional:
#   ./setup-tmux-nice.sh --with-starship
#   ./setup-tmux-nice.sh --prefix-ctrl-b
#
# Default prefix:
#   Ctrl-a
#
# Rename window:
#   Ctrl-a then ,
#
# Manual tmux-resurrect:
#   Save session:    Ctrl-a then Ctrl-s
#   Restore session: Ctrl-a then Ctrl-r
# ============================================================

WITH_STARSHIP=false
PREFIX_KEY="C-a"

for arg in "$@"; do
  case "$arg" in
    --with-starship)
      WITH_STARSHIP=true
      ;;
    --prefix-ctrl-b)
      PREFIX_KEY="C-b"
      ;;
    --flavor-latte|--flavor-frappe|--flavor-macchiato|--flavor-mocha|--theme-none)
      # Accepted for backward compatibility.
      # This script uses a polished native tmux theme so renamed windows stay visible.
      ;;
    -h|--help)
      echo "Usage: $0 [--with-starship] [--prefix-ctrl-b]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: $0 [--with-starship] [--prefix-ctrl-b]"
      exit 1
      ;;
  esac
done

echo "==> Installing required Ubuntu packages..."
sudo apt update
sudo apt install -y tmux git curl xclip xsel wl-clipboard

echo
echo "==> tmux version:"
tmux -V

PLUGIN_ROOT="${HOME}/.tmux/plugins"
mkdir -p "$PLUGIN_ROOT"

install_or_update_plugin() {
  local repo="$1"
  local target="$2"

  if [ -d "$target/.git" ]; then
    echo "Updating plugin: $(basename "$target")"
    git -C "$target" pull --ff-only || true
  else
    echo "Installing plugin: $(basename "$target")"
    rm -rf "$target"
    git clone --depth 1 "https://github.com/${repo}.git" "$target"
  fi
}

echo
echo "==> Installing stable tmux plugins directly..."

install_or_update_plugin "tmux-plugins/tpm"              "${PLUGIN_ROOT}/tpm"
install_or_update_plugin "tmux-plugins/tmux-sensible"   "${PLUGIN_ROOT}/tmux-sensible"
install_or_update_plugin "tmux-plugins/tmux-yank"       "${PLUGIN_ROOT}/tmux-yank"
install_or_update_plugin "tmux-plugins/tmux-resurrect"  "${PLUGIN_ROOT}/tmux-resurrect"

# Remove plugins from older versions of this script that caused problems.
if [ -d "${PLUGIN_ROOT}/tmux-continuum" ]; then
  echo
  echo "==> Removing tmux-continuum to avoid resurrect lookup errors..."
  rm -rf "${PLUGIN_ROOT}/tmux-continuum"
fi

echo
echo "==> Verifying critical plugin files..."

if [ ! -f "${PLUGIN_ROOT}/tmux-resurrect/resurrect.tmux" ]; then
  echo "ERROR: tmux-resurrect did not install correctly."
  echo "Expected file missing:"
  echo "  ${PLUGIN_ROOT}/tmux-resurrect/resurrect.tmux"
  exit 1
fi

echo "All critical plugin files found."

echo
echo "==> Backing up existing tmux config if present..."

TMUX_CONF="${HOME}/.tmux.conf"
BACKUP_FILE="${TMUX_CONF}.backup.$(date +%Y%m%d-%H%M%S)"

if [ -f "$TMUX_CONF" ]; then
  cp "$TMUX_CONF" "$BACKUP_FILE"
  echo "Backup created:"
  echo "$BACKUP_FILE"
else
  echo "No existing ~/.tmux.conf found."
fi

echo
echo "==> Writing polished tmux config with visible native window names..."

cat > "$TMUX_CONF" <<'EOF'
# ============================================================
# Polished tmux config for Ubuntu
# Native status bar with reliable visible window names
# ============================================================

# ------------------------------------------------------------
# Core behavior
# ------------------------------------------------------------

set -g mouse on
set -g history-limit 100000
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g detach-on-destroy off
set -g set-clipboard on

setw -g mode-keys vi
set -sg escape-time 10

# ------------------------------------------------------------
# Window naming - IMPORTANT
# ------------------------------------------------------------

# Prevent programs/shells from renaming windows to hostname/command.
set -g allow-rename off
set -g automatic-rename off
setw -g automatic-rename off

# Keep manually assigned names.
set -g automatic-rename-format "#{window_name}"

# ------------------------------------------------------------
# Prefix key
# ------------------------------------------------------------

EOF

if [ "$PREFIX_KEY" = "C-a" ]; then
  cat >> "$TMUX_CONF" <<'EOF'
unbind C-b
set -g prefix C-a
bind C-a send-prefix

EOF
else
  cat >> "$TMUX_CONF" <<'EOF'
set -g prefix C-b
bind C-b send-prefix

EOF
fi

cat >> "$TMUX_CONF" <<'EOF'
# ------------------------------------------------------------
# Quality-of-life keybindings
# ------------------------------------------------------------

bind r source-file ~/.tmux.conf \; display-message "tmux config reloaded"

bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

bind Enter copy-mode
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

bind C-l send-keys C-l \; clear-history

# ------------------------------------------------------------
# tmux-resurrect manual save / restore
# ------------------------------------------------------------

# Save session:
#   prefix + Ctrl-s
#
# Restore session:
#   prefix + Ctrl-r

set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-vim 'session'
set -g @resurrect-strategy-nvim 'session'

# ------------------------------------------------------------
# True color / terminal behavior
# ------------------------------------------------------------

set -g default-terminal "tmux-256color"

set -as terminal-features ",xterm-256color:RGB"
set -as terminal-features ",gnome*:RGB"
set -as terminal-features ",alacritty*:RGB"
set -as terminal-features ",kitty*:RGB"
set -as terminal-features ",wezterm*:RGB"
set -as terminal-features ",screen-256color:RGB"
set -as terminal-features ",tmux-256color:RGB"

set -g focus-events on

# ------------------------------------------------------------
# Polished native status bar
# ------------------------------------------------------------

set -g status on
set -g status-position bottom
set -g status-interval 5
set -g status-justify left

# Keep left/right compact so the window list is always visible.
set -g status-left-length 28
set -g status-right-length 55

# Catppuccin-like mocha colors using native tmux styles.
# This avoids plugin-controlled status modules.
set -g status-style "bg=#1e1e2e,fg=#cdd6f4"

# Left block: session name.
set -g status-left "#[fg=#1e1e2e,bg=#89b4fa,bold]  #S  #[fg=#89b4fa,bg=#1e1e2e] "

# Right block: host and time.
set -g status-right "#[fg=#313244,bg=#1e1e2e]#[fg=#cdd6f4,bg=#313244] #H #[fg=#45475a,bg=#313244]#[fg=#f9e2af,bg=#45475a] %H:%M #[fg=#cba6f7,bg=#45475a]#[fg=#cdd6f4,bg=#45475a] %Y-%m-%d "

# Window separator.
set -g window-status-separator ""

# Inactive windows.
# #I = window index, #W = window name, #F = flags
set -g window-status-format "#[fg=#6c7086,bg=#1e1e2e]#[fg=#cdd6f4,bg=#313244] #I:#W#F #[fg=#313244,bg=#1e1e2e]"

# Active/current window.
set -g window-status-current-format "#[fg=#1e1e2e,bg=#a6e3a1,bold] #I:#W#F #[fg=#a6e3a1,bg=#1e1e2e]"

# Activity/bell styles.
set -g window-status-activity-style "fg=#f9e2af,bg=#313244,bold"
set -g window-status-bell-style "fg=#f38ba8,bg=#313244,bold"

# Pane borders.
set -g pane-border-style "fg=#313244"
set -g pane-active-border-style "fg=#89b4fa"

# Messages.
set -g message-style "bg=#313244,fg=#cdd6f4"
set -g message-command-style "bg=#313244,fg=#cdd6f4"

# Copy mode highlight.
set -g mode-style "bg=#45475a,fg=#cdd6f4"

# Clock.
set -g clock-mode-colour "#89b4fa"

# ------------------------------------------------------------
# Load plugins directly
# ------------------------------------------------------------

run-shell ~/.tmux/plugins/tmux-sensible/sensible.tmux
run-shell ~/.tmux/plugins/tmux-yank/yank.tmux
run-shell ~/.tmux/plugins/tmux-resurrect/resurrect.tmux

# ------------------------------------------------------------
# TPM is installed for future manual plugin management
# ------------------------------------------------------------

set -g @plugin 'tmux-plugins/tpm'
run '~/.tmux/plugins/tpm/tpm'
EOF

echo "Wrote: $TMUX_CONF"

echo
echo "==> Killing old tmux server if running..."

if tmux ls >/dev/null 2>&1; then
  tmux kill-server || true
  echo "Old tmux server stopped."
else
  echo "No existing tmux server detected."
fi

echo
echo "==> Optional Starship prompt..."

if [ "$WITH_STARSHIP" = true ]; then
  if command -v starship >/dev/null 2>&1; then
    echo "Starship already installed: $(command -v starship)"
  else
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  SHELL_NAME="$(basename "${SHELL:-}")"

  if [ "$SHELL_NAME" = "bash" ]; then
    BASHRC="${HOME}/.bashrc"
    if ! grep -q 'starship init bash' "$BASHRC" 2>/dev/null; then
      echo '' >> "$BASHRC"
      echo '# Starship prompt' >> "$BASHRC"
      echo 'eval "$(starship init bash)"' >> "$BASHRC"
      echo "Added Starship init to ~/.bashrc"
    else
      echo "Starship already configured in ~/.bashrc"
    fi
  elif [ "$SHELL_NAME" = "zsh" ]; then
    ZSHRC="${HOME}/.zshrc"
    if ! grep -q 'starship init zsh' "$ZSHRC" 2>/dev/null; then
      echo '' >> "$ZSHRC"
      echo '# Starship prompt' >> "$ZSHRC"
      echo 'eval "$(starship init zsh)"' >> "$ZSHRC"
      echo "Added Starship init to ~/.zshrc"
    else
      echo "Starship already configured in ~/.zshrc"
    fi
  else
    echo "Starship installed, but shell auto-config was skipped."
    echo "Add the Starship init line manually for your shell."
  fi
else
  echo "Skipped Starship. Use --with-starship to install it."
fi

echo
echo "==> Done."
echo
echo "Start tmux:"
echo "  tmux"
echo
echo "Rename a window:"
if [ "$PREFIX_KEY" = "C-a" ]; then
  echo "  Ctrl-a then ,"
else
  echo "  Ctrl-b then ,"
fi
echo
echo "You should see polished tabs like:"
echo "  1:django*  2:server  3:logs"
echo
echo "Important:"
echo "  For best look, your terminal must use a Nerd Font."
echo "  Recommended: JetBrainsMono Nerd Font Mono"
echo
echo "Your old ~/.tmux.conf was backed up if it existed."
