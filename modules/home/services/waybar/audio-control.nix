{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe;
in
pkgs.writeShellScriptBin "waybar-audio-control" ''
  #!/usr/bin/env bash

  # Get list of audio devices
  get_sinks() {
    wpctl status | awk '/Sinks:/,/Sources:/ {if(/\*/ && !/Sinks:/) print $0}' | sed 's/.*\. //' | head -1
  }

  get_sources() {
    wpctl status | awk '/Sources:/,/Video/ {if(/\*/ && !/Sources:/) print $0}' | sed 's/.*\. //' | head -1
  }

  case "$1" in
    "output")
      # Show output device selection menu
      sinks=$(wpctl status | awk '/Sinks:/,/Sources:/ {if(!/Sinks:/ && !/Sources:/ && $0 != "") print $0}' | sed 's/[│├└─ ]//g; s/\*//g; s/[0-9]*\. //')
      current=$(get_sinks)

      chosen=$(echo "$sinks" | ${getExe pkgs.fuzzel} --dmenu \
        --prompt "Output Device: " \
        --width 35 \
        --background-color 1e1e2eff \
        --text-color cdd6f4ff \
        --match-color cba6f7ff \
        --selection-color 45475aff \
        --selection-text-color cdd6f4ff \
        --border-width 2 \
        --border-color cba6f7ff \
        --border-radius 10 \
        --font "JetBrainsMono Nerd Font:size=11" \
        --horizontal-pad 10 \
        --vertical-pad 8)

      if [ -n "$chosen" ]; then
        # Get device ID and set as default
        device_id=$(wpctl status | grep "$chosen" | sed 's/[│├└─ *]//g' | cut -d. -f1)
        wpctl set-default "$device_id"
        notify-send "Audio Output" "Switched to: $chosen"
      fi
      ;;
    "input")
      # Show input device selection menu
      sources=$(wpctl status | awk '/Sources:/,/Video/ {if(!/Sources:/ && !/Video/ && $0 != "") print $0}' | sed 's/[│├└─ ]//g; s/\*//g; s/[0-9]*\. //')
      current=$(get_sources)

      chosen=$(echo "$sources" | ${getExe pkgs.fuzzel} --dmenu \
        --prompt "Input Device: " \
        --width 35 \
        --background-color 1e1e2eff \
        --text-color cdd6f4ff \
        --match-color 94e2d5ff \
        --selection-color 45475aff \
        --selection-text-color cdd6f4ff \
        --border-width 2 \
        --border-color 94e2d5ff \
        --border-radius 10 \
        --font "JetBrainsMono Nerd Font:size=11" \
        --horizontal-pad 10 \
        --vertical-pad 8)

      if [ -n "$chosen" ]; then
        # Get device ID and set as default
        device_id=$(wpctl status | grep "$chosen" | sed 's/[│├└─ *]//g' | cut -d. -f1)
        wpctl set-default "$device_id"
        notify-send "Audio Input" "Switched to: $chosen"
      fi
      ;;
    "mixer")
      ${getExe pkgs.pavucontrol} &
      ;;
    *)
      echo "Usage: $0 {output|input|mixer}"
      exit 1
      ;;
  esac
''
