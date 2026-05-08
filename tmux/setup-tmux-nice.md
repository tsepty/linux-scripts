# tmux Nice Setup for Ubuntu

This document explains how to use the companion script:

```bash
setup-tmux-nice.sh
```

The script customizes tmux on Ubuntu with a cleaner, more modern development setup.

It is designed for users who want tmux to look and feel better for coding, server work, Django development, Kubernetes work, and general terminal multitasking.

---

## What the script does

The script performs these tasks:

1. Installs required Ubuntu packages:
   - `tmux`
   - `git`
   - `curl`

2. Installs or updates TPM:

   ```text
   tmux-plugins/tpm
   ```

3. Backs up your existing tmux config:

   ```bash
   ~/.tmux.conf
   ```

4. Writes a new polished tmux config.

5. Adds useful tmux plugins:

   ```text
   tmux-plugins/tmux-sensible
   tmux-plugins/tmux-yank
   tmux-plugins/tmux-resurrect
   tmux-plugins/tmux-continuum
   catppuccin/tmux
   ```

6. Enables:
   - mouse support
   - true color
   - better pane navigation
   - better split shortcuts
   - session restore
   - Catppuccin theme
   - larger scrollback history
   - Vim-style copy mode

7. Optionally installs Starship prompt.

---

## Files changed

The script creates or updates:

```bash
~/.tmux.conf
```

If a previous config exists, it creates a backup like this:

```bash
~/.tmux.conf.backup.YYYYMMDD-HHMMSS
```

TPM is installed here:

```bash
~/.tmux/plugins/tpm
```

---

## How to run the script

Make the script executable:

```bash
chmod +x setup-tmux-nice.sh
```

Run it:

```bash
./setup-tmux-nice.sh
```

Then start tmux:

```bash
tmux
```

Inside tmux, install the plugins:

```text
Ctrl-a then Shift-i
```

That means:

1. Hold `Ctrl` and press `a`
2. Release both keys
3. Press capital `I`

Because capital `I` is needed, press:

```text
Shift + i
```

---

## Optional flags

### Install Starship prompt

```bash
./setup-tmux-nice.sh --with-starship
```

This installs Starship and adds the correct init line to your shell config if you use Bash or Zsh.

For Bash, it updates:

```bash
~/.bashrc
```

For Zsh, it updates:

```bash
~/.zshrc
```

Starship makes your shell prompt look much nicer inside and outside tmux.

---

### Keep the default tmux prefix

By default, the script changes the tmux prefix from:

```text
Ctrl-b
```

to:

```text
Ctrl-a
```

This is common because `Ctrl-a` is easier to press.

If you want to keep the default tmux prefix, run:

```bash
./setup-tmux-nice.sh --prefix-ctrl-b
```

Then your tmux commands will use:

```text
Ctrl-b
```

instead of:

```text
Ctrl-a
```

---

### Choose Catppuccin theme flavor

Default flavor:

```text
mocha
```

Available options:

```bash
./setup-tmux-nice.sh --flavor-latte
./setup-tmux-nice.sh --flavor-frappe
./setup-tmux-nice.sh --flavor-macchiato
./setup-tmux-nice.sh --flavor-mocha
```

Recommended:

```bash
./setup-tmux-nice.sh --flavor-mocha
```

For a light theme:

```bash
./setup-tmux-nice.sh --flavor-latte
```

---

### Full example

```bash
./setup-tmux-nice.sh --with-starship --flavor-mocha
```

Or, if you want the default tmux prefix:

```bash
./setup-tmux-nice.sh --with-starship --prefix-ctrl-b --flavor-mocha
```

---

## Important: install a Nerd Font

For the theme icons to look correct, your terminal must use a Nerd Font.

Recommended fonts:

```text
JetBrainsMono Nerd Font
FiraCode Nerd Font
Hack Nerd Font
MesloLGS Nerd Font
```

If you do not use a Nerd Font, the tmux status bar may show broken squares or missing icons.

After installing a Nerd Font, set it in your terminal.

For Ubuntu GNOME Terminal:

```text
Terminal → Preferences → Your Profile → Text → Custom font
```

Then choose something like:

```text
JetBrainsMono Nerd Font Mono
```

---

## Recommended terminal apps

The setup works with normal Ubuntu Terminal, but it looks best with:

```text
WezTerm
Kitty
Alacritty
GNOME Terminal
```

Best visual experience:

```text
WezTerm or Kitty + JetBrainsMono Nerd Font + Catppuccin Mocha
```

---

## Main tmux keybindings

The script uses `Ctrl-a` as the default prefix unless you run it with `--prefix-ctrl-b`.

In the examples below, assume the prefix is:

```text
Ctrl-a
```

If you used `--prefix-ctrl-b`, replace `Ctrl-a` with `Ctrl-b`.

---

### Reload tmux config

```text
Ctrl-a then r
```

---

### Install tmux plugins

```text
Ctrl-a then Shift-i
```

This is required the first time after running the script.

---

### Split panes

Vertical split:

```text
Ctrl-a then |
```

Horizontal split:

```text
Ctrl-a then -
```

Both splits open in the current directory.

---

### Create a new window

```text
Ctrl-a then c
```

The new window opens in the current directory.

---

### Move between panes

```text
Ctrl-a then h
Ctrl-a then j
Ctrl-a then k
Ctrl-a then l
```

This matches Vim-style movement:

| Key | Direction |
|---|---|
| `h` | left |
| `j` | down |
| `k` | up |
| `l` | right |

---

### Resize panes

```text
Ctrl-a then H
Ctrl-a then J
Ctrl-a then K
Ctrl-a then L
```

Capital letters resize panes by larger steps.

---

### Enter copy mode

```text
Ctrl-a then Enter
```

In copy mode:

```text
v
```

starts selection.

```text
y
```

copies selection.

---

### Clear pane history

```text
Ctrl-a then Ctrl-l
```

This sends `Ctrl-l` and clears the tmux history for that pane.

---

## Installed tmux plugins

### TPM

```text
tmux-plugins/tpm
```

TPM is the tmux plugin manager. It installs and updates plugins from your `.tmux.conf`.

---

### tmux-sensible

```text
tmux-plugins/tmux-sensible
```

Adds sane default tmux settings.

---

### tmux-yank

```text
tmux-plugins/tmux-yank
```

Improves copying text from tmux to the system clipboard.

On Ubuntu, clipboard support may require:

```bash
sudo apt install xclip xsel wl-clipboard
```

For Wayland desktops, `wl-clipboard` is especially useful.

---

### tmux-resurrect

```text
tmux-plugins/tmux-resurrect
```

Lets tmux save and restore sessions, windows, panes, and commands.

---

### tmux-continuum

```text
tmux-plugins/tmux-continuum
```

Automatically saves tmux sessions and can restore them when tmux starts.

The script enables:

```tmux
set -g @continuum-restore 'on'
```

---

### Catppuccin tmux

```text
catppuccin/tmux
```

This provides the modern tmux status bar theme.

Default flavor used by the script:

```text
mocha
```

---

## Common workflow

Start a tmux session:

```bash
tmux
```

Create a named session:

```bash
tmux new -s dev
```

Detach from tmux:

```text
Ctrl-a then d
```

List sessions:

```bash
tmux ls
```

Reattach:

```bash
tmux attach -t dev
```

Kill a session:

```bash
tmux kill-session -t dev
```

---

## Useful tmux commands

Reload config manually:

```bash
tmux source-file ~/.tmux.conf
```

Check tmux version:

```bash
tmux -V
```

Show current terminal type inside tmux:

```bash
echo $TERM
```

Expected:

```text
tmux-256color
```

Check color support:

```bash
echo $COLORTERM
```

Often expected:

```text
truecolor
```

---

## Troubleshooting

### Icons look like boxes

Your terminal is not using a Nerd Font.

Fix:

1. Install a Nerd Font.
2. Set it as your terminal font.
3. Restart the terminal.
4. Restart tmux.

---

### Colors look wrong

Try restarting your terminal completely.

Then run:

```bash
tmux kill-server
tmux
```

Also make sure your terminal supports true color.

Recommended terminals:

```text
WezTerm
Kitty
Alacritty
GNOME Terminal
```

---

### Plugins did not install

Inside tmux, run:

```text
Ctrl-a then Shift-i
```

If you kept the default prefix:

```text
Ctrl-b then Shift-i
```

Also verify TPM exists:

```bash
ls ~/.tmux/plugins/tpm
```

---

### `Ctrl-a` conflicts with shell behavior

In Bash, `Ctrl-a` usually moves the cursor to the beginning of the line.

This script changes tmux prefix to `Ctrl-a`, so inside tmux that key is used by tmux first.

If you do not like that, rerun the script with:

```bash
./setup-tmux-nice.sh --prefix-ctrl-b
```

---

### I want to restore my old tmux config

List backups:

```bash
ls ~/.tmux.conf.backup.*
```

Restore one:

```bash
cp ~/.tmux.conf.backup.YYYYMMDD-HHMMSS ~/.tmux.conf
```

Reload tmux:

```bash
tmux source-file ~/.tmux.conf
```

Or restart tmux:

```bash
tmux kill-server
tmux
```

---

### Copy/paste does not work

Install clipboard tools:

```bash
sudo apt install -y xclip xsel wl-clipboard
```

If you use Wayland, `wl-clipboard` is usually the most important one.

Then restart tmux:

```bash
tmux kill-server
tmux
```

---

### Neovim colors look wrong inside tmux

In Neovim, enable true color:

For Vimscript:

```vim
set termguicolors
```

For Lua:

```lua
vim.opt.termguicolors = true
```

Also make sure tmux has:

```tmux
set -g default-terminal "tmux-256color"
```

The script already adds this.

---

## How to update tmux plugins

Inside tmux:

```text
Ctrl-a then U
```

Capital `U`.

If you kept the default prefix:

```text
Ctrl-b then U
```

---

## How to remove tmux plugins

1. Edit:

   ```bash
   nano ~/.tmux.conf
   ```

2. Remove or comment out the plugin line.

3. Reload tmux:

   ```text
   Ctrl-a then r
   ```

4. Clean removed plugins:

   ```text
   Ctrl-a then Alt-u
   ```

---

## Best setup recommendation

For the nicest experience, use:

```text
Terminal: WezTerm or Kitty
Font: JetBrainsMono Nerd Font
tmux theme: Catppuccin Mocha
Prompt: Starship
Prefix: Ctrl-a
```

Run:

```bash
./setup-tmux-nice.sh --with-starship --flavor-mocha
```

Then inside tmux:

```text
Ctrl-a then Shift-i
```

---

## Summary

The script gives you:

```text
modern tmux look
nice status bar
mouse support
true color
better pane navigation
session restore
plugin management
optional Starship prompt
```

The most important follow-up step is installing a Nerd Font and selecting it in your terminal.
