{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.meadow.default.wm == "hyprland";

  inherit (lib) mkIf;

  _ = lib.getExe;

  # OCR (Optical Character Recognition) utility
  ocrScript =
    let
      inherit (pkgs)
        grim
        libnotify
        slurp
        tesseract5
        wl-clipboard
        ;
    in
    pkgs.writeShellScriptBin "wl-ocr" ''
      ${_ grim} -g "$(${_ slurp})" -t ppm - | ${_ tesseract5} - - | ${wl-clipboard}/bin/wl-copy
      ${_ libnotify} "$(${wl-clipboard}/bin/wl-paste)"
    '';

  # Volume control utility
  volumectl =
    let
      inherit (pkgs) libnotify pamixer libcanberra-gtk3;
    in
    pkgs.writeShellScriptBin "volumectl" ''
      #!/usr/bin/env bash

      case "$1" in
      up)
        ${_ pamixer} -i "$2"
        ;;
      down)
        ${_ pamixer} -d "$2"
        ;;
      toggle-mute)
        ${_ pamixer} -t
        ;;
      esac

      volume_percentage="$(${_ pamixer} --get-volume)"
      isMuted="$(${_ pamixer} --get-mute)"

      if [ "$isMuted" = "true" ]; then
        ${libnotify}/bin/notify-send --transient \
          -u normal \
          -a "VOLUMECTL" \
          -i audio-volume-muted-symbolic \
          "VOLUMECTL" "Volume Muted"
      else
        ${libnotify}/bin/notify-send --transient \
          -u normal \
          -a "VOLUMECTL" \
          -h string:x-canonical-private-synchronous:volumectl \
          -h int:value:"$volume_percentage" \
          -i audio-volume-high-symbolic \
          "VOLUMECTL" "Volume: $volume_percentage%"

        ${libcanberra-gtk3}/bin/canberra-gtk-play -i audio-volume-change -d "volumectl"
      fi
    '';

  # Brightness control utility
  lightctl =
    let
      inherit (pkgs) libnotify brightnessctl;
    in
    pkgs.writeShellScriptBin "lightctl" ''
      case "$1" in
      up)
        ${_ brightnessctl} -q s +"$2"%
        ;;
      down)
        ${_ brightnessctl} -q s "$2"%-
        ;;
      esac

      brightness_percentage=$((($(${_ brightnessctl} g) * 100) / $(${_ brightnessctl} m)))
      ${libnotify}/bin/notify-send --transient \
        -u normal \
        -a "LIGHTCTL" \
        -h string:x-canonical-private-synchronous:lightctl \
        -h int:value:"$brightness_percentage" \
        -i display-brightness-symbolic \
        -t 2000 \
        "LIGHTCTL" "Brightness: $brightness_percentage%"
    '';

  # Backlight control utility (keyboard backlight)
  backlightctl =
    let
      inherit (pkgs) libnotify;
    in
    pkgs.writeShellScriptBin "backlightctl" ''
      BACKLIGHT_PATH="/sys/class/leds/asus::kbd_backlight"

      if [ ! -w "$BACKLIGHT_PATH/brightness" ]; then
        echo "Error: Cannot write to keyboard backlight. Check permissions."
        exit 1
      fi

      current=$(cat "$BACKLIGHT_PATH/brightness" 2>/dev/null || echo "0")
      max_brightness=$(cat "$BACKLIGHT_PATH/max_brightness" 2>/dev/null || echo "3")

      case "$1" in
      up)
        if [ "$current" -lt "$max_brightness" ]; then
          new_brightness=$((current + 1))
          echo "$new_brightness" > "$BACKLIGHT_PATH/brightness"
        fi
        ;;
      down)
        if [ "$current" -gt 0 ]; then
          new_brightness=$((current - 1))
          echo "$new_brightness" > "$BACKLIGHT_PATH/brightness"
        fi
        ;;
      esac

      # Get updated value
      current=$(cat "$BACKLIGHT_PATH/brightness" 2>/dev/null || echo "0")
      max_brightness=$(cat "$BACKLIGHT_PATH/max_brightness" 2>/dev/null || echo "3")
      percentage=$(( (current * 100) / max_brightness ))

      ${libnotify}/bin/notify-send --transient \
        -u normal \
        -a "BACKLIGHTCTL" \
        -h string:x-canonical-private-synchronous:backlightctl \
        -h int:value:"$percentage" \
        -i keyboard-brightness-symbolic \
        -t 2000 \
        "BACKLIGHTCTL" "Keyboard Backlight: $percentage% ($current/$max_brightness)"
    '';
in
{
  imports = [
    ./config
  ];

  config = mkIf cfg {
    home = {
      packages = with pkgs; [
        brightnessctl
        cliphist
        dbus
        glib
        grim
        gtk3
        hyprpicker
        hyprpaper
        libcanberra-gtk3
        libnotify
        pamixer
        sassc
        slurp
        wf-recorder
        wl-clipboard
        brillo
        # wl-screenrec
        wlr-randr
        wlr-randr
        wtype
        ydotool
        wlprop
        xorg.xprop

        ocrScript
        volumectl
        lightctl
        backlightctl
      ];

      sessionVariables = {
        XDG_SESSION_DESKTOP = "Hyprland";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland,x11";
        XDG_SESSION_TYPE = "wayland";
        MOZ_ENABLE_WAYLAND = "1";
        QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
      };
    };

    wayland.windowManager.hyprland = {
      xwayland.enable = true;
      enable = true;
      package = null;
      portalPackage = null;
      systemd = {
        enable = true;
        variables = [ "--all" ];
        extraCommands = [
          "systemctl --user start graphical-session.target"
        ];
      };
    };

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };
  };
}
