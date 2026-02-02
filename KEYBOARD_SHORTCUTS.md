# Keyboard Shortcuts Reference

This document lists all keyboard shortcut configuration files in the repository.

## Window Manager Shortcuts

### Hyprland
**File:** `modules/home/wm/hyprland/config/binds.nix`

Key shortcuts include:
- `SUPER + Q` - Kill active window
- `SUPER + Return` - Open terminal
- `SUPER + D` - Launch application launcher (vicinae)
- `SUPER + F` - Fullscreen
- `SUPER + Space` - Toggle floating
- `SUPER + M` - Toggle monocle mode
- `SUPER + G` - Toggle group
- `SUPER + TAB` - Change group active forward
- `SUPER + [1-9,0]` - Switch to workspace
- `SUPER + SHIFT + [1-9,0]` - Move window to workspace
- Media keys for volume and brightness control

### Niri
**File:** `modules/home/wm/niri/default.nix` (lines 127-169)

Key shortcuts include:
- `Mod + Q` / `Mod + W` - Close window
- `Mod + Return` - Open terminal (foot)
- `Mod + Space` - Launch application launcher (vicinae)
- `Mod + B` - Open browser (zen-beta)
- `Mod + V` - Open file manager (nautilus)
- `Mod + F` - Maximize column
- `Mod + Shift + F` - Fullscreen window
- `Mod + H/J/K/L` - Focus navigation (vim-like)
- `Mod + [1-5]` - Focus named workspaces (code, browser, test, music, slack)
- `Print` - Screenshot
- Media keys for volume and brightness control

### SwayFX
**File:** `modules/home/wm/swayfx/default.nix`

Key shortcuts include:
- `Mod + Q` - Kill window
- `Mod + Return` - Open terminal
- `Mod + D` - Launch application launcher (rofi)
- `Mod + F` - Fullscreen
- `Mod + Space` - Focus mode toggle
- `Mod + Shift + Space` - Floating toggle
- `Mod + [1-9,0]` - Switch to workspace
- `Mod + Shift + [1-9,0]` - Move container to workspace
- `Mod + H/J/K/L` (via keycodes) - Focus navigation (vim-like)
- `Mod + R` - Resize mode
- Media keys for volume and brightness control

## Terminal Shortcuts

### Kitty
**File:** `modules/home/terminals/kitty/default.nix`

Contains keybindings configuration for the Kitty terminal emulator.

### Ghostty
**File:** `modules/home/terminals/ghostty/default.nix`

Contains keybindings configuration for the Ghostty terminal emulator.

## Application Shortcuts

### Zellij
**File:** `modules/home/programs/zellij/default.nix`

Terminal multiplexer with its own keybindings configuration.

### K9s
**File:** `modules/home/programs/k9s/default.nix`

Kubernetes CLI tool shortcuts:
- `Shift + D` - Add debug container (custom plugin)

## System-Level Keyboard Configuration

### Kanata
**File:** `modules/nixos/kanata/default.nix`

Keyboard remapping configuration at the system level. Currently configured with empty base layer but allows for advanced keyboard customization.

---

## How to Modify Shortcuts

Each configuration file is written in Nix and follows the respective application's configuration format:
- Hyprland uses Nix attribute sets for `bind`, `binde`, `bindr`, and `bindm`
- Niri uses KDL (Document Language) format embedded in Nix
- SwayFX uses Nix attribute sets for keybindings
- Terminal and application configs use their respective formats

To modify shortcuts, edit the corresponding file and rebuild your NixOS/home-manager configuration.
