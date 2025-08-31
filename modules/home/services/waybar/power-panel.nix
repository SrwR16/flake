{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe;
in
pkgs.writeShellScriptBin "waybar-power-panel" ''
  #!/usr/bin/env bash

  # Power management options
  options="⏾ Suspend\n🔒 Lock\n🔄 Restart\n⏻ Shutdown\n🚪 Logout"

  # Show options using fuzzel with custom styling
  chosen=$(echo -e "$options" | ${getExe pkgs.fuzzel} --dmenu \
    --prompt "Power Options: " \
    --width 25 \
    --lines 5 \
    --background-color 1e1e2eff \
    --text-color cdd6f4ff \
    --match-color 89b4faff \
    --selection-color 45475aff \
    --selection-text-color cdd6f4ff \
    --border-width 2 \
    --border-color 89b4faff \
    --border-radius 10 \
    --font "JetBrainsMono Nerd Font:size=11" \
    --horizontal-pad 10 \
    --vertical-pad 8)

  case $chosen in
      "⏾ Suspend")
          systemctl suspend
          ;;
      "🔒 Lock")
          ${getExe pkgs.hyprlock} --immediate
          ;;
      "🔄 Restart")
          systemctl reboot
          ;;
      "⏻ Shutdown")
          systemctl poweroff
          ;;
      "🚪 Logout")
          hyprctl dispatch exit
          ;;
  esac
''
