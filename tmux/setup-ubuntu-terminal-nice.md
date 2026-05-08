# Ubuntu Terminal Nice Setup

This document explains how to use the companion script:

```bash
setup-ubuntu-terminal-nice.sh
```

The script is intended for Ubuntu users who want their terminal to look better for tmux, Django development, Codex, VS Code, Kubernetes work, and general shell usage.

It installs recommended Nerd Fonts and can optionally configure GNOME Terminal automatically.

---

## What the script does

The script can:

1. Install required packages:

   ```text
   wget
   unzip
   fontconfig
   dconf-cli
   ```

2. Install recommended Nerd Fonts locally for your user account:

   ```text
   JetBrainsMono Nerd Font
   FiraCode Nerd Font
   Hack Nerd Font
   MesloLGS Nerd Font
   ```

3. Refresh the Linux font cache.

4. Optionally set your GNOME Terminal font.

5. Optionally apply a darker modern terminal color palette.

6. Create a backup of your current GNOME Terminal profile before modifying it.

---

## Why Nerd Fonts matter

Nerd Fonts include extra developer icons used by tools like:

```text
tmux themes
Starship prompt
Powerlevel10k
Neovim status lines
Lazygit
modern terminal prompts
```

Without a Nerd Font, icons may appear as boxes or broken symbols.

Example of broken icons:

```text
□ □ □ □
```

Example of working icons:

```text
󰣇  󰌠  󰈙  󰊢  󰆍  󰘬
```

---

## Fonts installed by default

By default, the script installs all four recommended fonts:

```text
JetBrainsMono
FiraCode
Hack
Meslo
```

The fonts are installed into:

```bash
~/.local/share/fonts/NerdFonts
```

This means the fonts are installed only for your current Linux user, not system-wide.

---

## Recommended font

For most users, I recommend:

```text
JetBrainsMono Nerd Font Mono
```

It looks clean, is easy to read, and works very well with tmux, VS Code, Starship, and terminal development.

---

## How to run the script

Make it executable:

```bash
chmod +x setup-ubuntu-terminal-nice.sh
```

Run the basic setup:

```bash
./setup-ubuntu-terminal-nice.sh
```

This installs all recommended Nerd Fonts and refreshes the font cache.

---

## Recommended full setup

For GNOME Terminal on Ubuntu, run:

```bash
./setup-ubuntu-terminal-nice.sh --font JetBrainsMono --set-gnome-terminal --dark-colors
```

This does three things:

1. Installs the fonts.
2. Sets GNOME Terminal to use JetBrainsMono Nerd Font.
3. Applies a dark modern color palette.

After running it, close and reopen your terminal.

---

## Script options

### `--set-gnome-terminal`

Automatically configures your default GNOME Terminal profile to use the selected Nerd Font.

Example:

```bash
./setup-ubuntu-terminal-nice.sh --set-gnome-terminal
```

Default selected font:

```text
JetBrainsMono
```

---

### `--dark-colors`

Applies a dark modern color palette to GNOME Terminal.

Use it together with:

```bash
--set-gnome-terminal
```

Example:

```bash
./setup-ubuntu-terminal-nice.sh --set-gnome-terminal --dark-colors
```

---

### `--font NAME`

Selects which font should be used for GNOME Terminal.

Supported values:

```text
JetBrainsMono
FiraCode
Hack
Meslo
```

Examples:

```bash
./setup-ubuntu-terminal-nice.sh --font JetBrainsMono --set-gnome-terminal
```

```bash
./setup-ubuntu-terminal-nice.sh --font FiraCode --set-gnome-terminal
```

```bash
./setup-ubuntu-terminal-nice.sh --font Hack --set-gnome-terminal
```

```bash
./setup-ubuntu-terminal-nice.sh --font Meslo --set-gnome-terminal
```

---

### `--only-selected-font`

Installs only the selected font instead of all recommended fonts.

Example:

```bash
./setup-ubuntu-terminal-nice.sh --font JetBrainsMono --only-selected-font --set-gnome-terminal
```

This is useful if you want a minimal setup.

---

### `--help`

Shows usage information:

```bash
./setup-ubuntu-terminal-nice.sh --help
```

---

## Common examples

### Install all fonts only

```bash
./setup-ubuntu-terminal-nice.sh
```

---

### Install all fonts and set GNOME Terminal to JetBrainsMono

```bash
./setup-ubuntu-terminal-nice.sh --set-gnome-terminal
```

---

### Install all fonts, set GNOME Terminal, and use dark colors

```bash
./setup-ubuntu-terminal-nice.sh --set-gnome-terminal --dark-colors
```

---

### Install only JetBrainsMono and configure GNOME Terminal

```bash
./setup-ubuntu-terminal-nice.sh --font JetBrainsMono --only-selected-font --set-gnome-terminal
```

---

### Use FiraCode instead

```bash
./setup-ubuntu-terminal-nice.sh --font FiraCode --set-gnome-terminal --dark-colors
```

---

## GNOME Terminal backup

Before changing your GNOME Terminal profile, the script creates a backup file like this:

```bash
~/gnome-terminal-profile-backup-YYYYMMDD-HHMMSS.dconf
```

This backup contains your previous terminal profile settings.

---

## Restore GNOME Terminal backup

To restore a backup, first find the backup file:

```bash
ls ~/gnome-terminal-profile-backup-*.dconf
```

Then find your GNOME Terminal profile path:

```bash
gsettings get org.gnome.Terminal.ProfilesList default
```

It will show something like:

```text
'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
```

Use that UUID in this command:

```bash
dconf load /org/gnome/terminal/legacy/profiles:/:YOUR-UUID-HERE/ < ~/gnome-terminal-profile-backup-YYYYMMDD-HHMMSS.dconf
```

Then close and reopen GNOME Terminal.

---

## Manual font selection

If automatic GNOME Terminal configuration does not work, set the font manually.

Open Terminal preferences:

```text
Terminal → Preferences → Your Profile → Text
```

Enable:

```text
Custom font
```

Choose one of:

```text
JetBrainsMono Nerd Font Mono
FiraCode Nerd Font Mono
Hack Nerd Font Mono
MesloLGS Nerd Font Mono
```

Then close and reopen Terminal.

---

## Verify installed fonts

List installed Nerd Fonts:

```bash
fc-list | grep -Ei "JetBrainsMono|FiraCode|Hack Nerd|Meslo"
```

Check only JetBrainsMono:

```bash
fc-list | grep -i "JetBrains"
```

Check only FiraCode:

```bash
fc-list | grep -i "FiraCode"
```

Check only Hack:

```bash
fc-list | grep -i "Hack"
```

Check only Meslo:

```bash
fc-list | grep -i "Meslo"
```

---

## Test icons

Run:

```bash
echo "󰣇  󰌠  󰈙  󰊢  󰆍  󰘬"
```

If the font is working, you should see icons.

If you see boxes, your terminal is probably not using the Nerd Font yet.

---

## Troubleshooting

### Icons still look broken

Most likely cause:

```text
The font is installed, but your terminal profile is not using it.
```

Fix:

1. Open Terminal preferences.
2. Enable custom font.
3. Select `JetBrainsMono Nerd Font Mono`.
4. Close and reopen the terminal.

---

### Font does not appear in the terminal font list

Refresh the font cache manually:

```bash
fc-cache -fv ~/.local/share/fonts
```

Then restart Terminal.

If it still does not appear, log out and log back in.

---

### `wget: command not found`

Install required tools:

```bash
sudo apt update
sudo apt install -y wget unzip fontconfig dconf-cli
```

Then rerun the script.

---

### `dconf: command not found`

Install `dconf-cli`:

```bash
sudo apt install -y dconf-cli
```

Then rerun the script.

---

### GNOME Terminal settings did not change

Some Ubuntu setups use a different terminal app, such as:

```text
Tilix
Konsole
Xfce Terminal
Alacritty
Kitty
WezTerm
```

The automatic profile configuration only targets **GNOME Terminal**.

For other terminals, set the font manually in that terminal’s settings.

---

### I use VS Code integrated terminal

After installing the font, open VS Code settings JSON:

```bash
code ~/.config/Code/User/settings.json
```

Add or update:

```json
{
  "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font Mono"
}
```

If that does not work, try:

```json
{
  "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font"
}
```

Restart VS Code.

---

### I use Kitty

Edit:

```bash
nano ~/.config/kitty/kitty.conf
```

Add:

```conf
font_family JetBrainsMono Nerd Font Mono
font_size 12.0
```

Restart Kitty.

---

### I use Alacritty

Edit:

```bash
nano ~/.config/alacritty/alacritty.toml
```

Add or update:

```toml
[font]
size = 12.0

[font.normal]
family = "JetBrainsMono Nerd Font Mono"
style = "Regular"
```

Restart Alacritty.

---

### I use WezTerm

Edit:

```bash
nano ~/.wezterm.lua
```

Add:

```lua
local wezterm = require 'wezterm'

return {
  font = wezterm.font("JetBrainsMono Nerd Font Mono"),
  font_size = 12.0,
}
```

Restart WezTerm.

---

## Removing installed fonts

Fonts are installed here:

```bash
~/.local/share/fonts/NerdFonts
```

To remove them:

```bash
rm -rf ~/.local/share/fonts/NerdFonts
fc-cache -fv ~/.local/share/fonts
```

Then restart your terminal.

---

## Best setup with tmux

For the tmux script created earlier, the recommended terminal setup is:

```text
Font: JetBrainsMono Nerd Font Mono
Terminal: GNOME Terminal, Kitty, WezTerm, or Alacritty
Theme: dark colors
tmux theme: Catppuccin Mocha
Optional prompt: Starship
```

Recommended command:

```bash
./setup-ubuntu-terminal-nice.sh --font JetBrainsMono --set-gnome-terminal --dark-colors
```

Then run the tmux setup:

```bash
./setup-tmux-nice.sh --with-starship --flavor-mocha
```

---

## Best setup with VS Code

After installing the font, set the VS Code integrated terminal font:

```json
{
  "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font Mono",
  "terminal.integrated.fontSize": 13
}
```

This makes tmux and Starship icons work inside VS Code’s terminal too.

---

## Summary

The script gives you:

```text
Nerd Font support
better terminal icons
better tmux theme rendering
optional GNOME Terminal font setup
optional dark color palette
backup of previous terminal profile
```

The most important thing after running it is to make sure your terminal is actually using the Nerd Font.
