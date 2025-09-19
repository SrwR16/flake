{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.meadow.services.waybar;
  powerPanel = import ./power-panel.nix { inherit pkgs lib; };
  audioControl = import ./audio-control.nix { inherit pkgs lib; };
in
{
  options.meadow.services.waybar.enable = mkEnableOption "waybar";

  config = mkIf cfg.enable {
    home.packages = [
      powerPanel
      audioControl
      pkgs.fuzzel
      pkgs.networkmanagerapplet # For WiFi applet and connection editor
      pkgs.gnome-calendar # For calendar
    ];

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
      settings = [
        {
          layer = "top";
          height = 28;
          spacing = 0;
          modules-left = [
            "image"
            "hyprland/workspaces"
            "hyprland/window"
            "custom/spotify"
          ];
          modules-center = [
            "user"
          ];
          modules-right = [
            "custom/audio-input"
            "pulseaudio"
            "bluetooth"
            "tray"
            "power-profiles-daemon"
            "battery"
            "clock"
            "custom/notification"
            "custom/power"
          ];

          "hyprland/window" = {
            format = "{}";
            separate-outputs = false;
            max-length = 50;
            rewrite = {
              "" = "Desktop";
            };
          };

          "hyprland/workspaces" = {
            format = "{name}";
            on-click = "activate";
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
            sort-by-number = true;
            all-outputs = false;
            show-special = false;
            persistent-workspaces = {
              "1" = [ ];
            };
          };

          "user" = {
            format = "  ${config.home.username} | ({work_H}hr {work_M} mins ↑)";
            interval = 60;
            height = 23;
            width = 23;
            icon = true;
          };

          "image" = {
            path = "/home/xi/flake/modules/home/services/waybar/icon.png";
            size = 24;
            interval = 5;
          };

          "tray" = {
            spacing = 10;
          };

          "clock" = {
            tooltip-format = "{:%A, %B %d, %Y}";
            format = "{:%I:%M}";
            format-alt = "{:%Y-%m-%d}";
            on-click = "gnome-calendar";
            interval = 60;
          };

          "battery" = {
            states = {
              good = 80;
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-icons = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󰚥 {capacity}%";
            format-alt = "{time} {icon}";
            format-full = "󰁹 Full";
            format-warning = "󰂃 {capacity}%";
            format-critical = "󰁺 {capacity}%";
            tooltip-format = "Battery: {capacity}%\n{timeTo}\nPower: {power}W\nHealth: {health}%";
            tooltip-format-charging = "Charging: {capacity}%\nTime to full: {time}\nPower: {power}W";
            tooltip-format-plugged = "Plugged: {capacity}%\nPower: {power}W";
            tooltip-format-full = "Battery Full\nPower: {power}W";
            interval = 30;
            bat = "BAT0";
            adapter = "ADP1";
          };

          "pulseaudio" = {
            scroll-step = 5;
            format = "{icon} {volume}%";
            format-muted = "󰝟 Muted";
            format-icons = {
              default = [
                "󰕿"
                "󰖀"
                "󰕾"
              ];
            };
            tooltip-format = "{desc}\nVolume: {volume}%\nLeft click: Mute toggle\nRight click: Device selection\nScroll: Volume control";
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-click-right = "${lib.getExe audioControl} output";
            on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.0";
          };

          "custom/audio-input" = {
            format = "󰍬";
            tooltip = true;
            tooltip-format = "Audio Input Controls\nLeft click: Mute toggle\nRight click: Device selection\nMiddle click: Open mixer";
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            on-click-right = "${lib.getExe audioControl} input";
            on-click-middle = "${lib.getExe audioControl} mixer";
            interval = 1;
          };

          "custom/power" = {
            format = "󰐥";
            tooltip = true;
            tooltip-format = "Power Options";
            on-click = "${lib.getExe powerPanel}";
          };

          "power-profiles-daemon" = {
            format = "{icon}";
            tooltip-format = "Power profile: {profile}\nDriver: {driver}";
            tooltip = true;
            format-icons = {
              default = "";
              performance = "";
              balanced = "";
              power-saver = "";
            };
          };

          "bluetooth" = {
            format = "󰂯";
            format-disabled = "󰂲";
            format-connected = "󰂱";
            tooltip-format = "{controller_alias}\t{controller_address}";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            on-click = "blueman-manager";
          };

          "custom/spotify" = {
            interval = 1;
            return-type = "json";
            exec = "playerctl -p spotify metadata --format '{\"text\": \"{{artist}} - {{title}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' 2>/dev/null || echo '{\"text\":\"\",\"tooltip\":\"\",\"alt\":\"\",\"class\":\"\"}'";
            on-click = "playerctl -p spotify play-pause";
            escape = true;
          };

          "custom/notification" = {
            tooltip = false;
            format = "{icon}";
            format-icons = {
              notification = "󱅫";
              none = "";
            };
            exec-if = "which dunst";
            exec = "echo '{\"text\":\"\",\"tooltip\":\"\",\"alt\":\"\",\"class\":\"\"}'";
            on-click = "dunstctl history-pop";
            on-click-right = "dunstctl close-all";
            on-click-middle = "dunstctl set-paused toggle";
            return-type = "json";
            interval = 5;
            escape = true;
          };
        }
      ];

      style = ''
        @define-color base #1e1e2e;
        @define-color mantle #181825;
        @define-color crust #11111b;

        @define-color text #cdd6f4;
        @define-color subtext0 #a6adc8;
        @define-color subtext1 #bac2de;

        @define-color surface0 #313244;
        @define-color surface1 #45475a;
        @define-color surface2 #585b70;

        @define-color overlay0 #6c7086;
        @define-color overlay1 #7f849c;
        @define-color overlay2 #9399b2;

        @define-color blue #89b4fa;
        @define-color lavender #b4befe;
        @define-color sapphire #74c7ec;
        @define-color sky #89dceb;
        @define-color teal #94e2d5;
        @define-color green #a6e3a1;
        @define-color yellow #f9e2af;
        @define-color peach #fab387;
        @define-color maroon #eba0ac;
        @define-color red #f38ba8;
        @define-color mauve #cba6f7;
        @define-color pink #f5c2e7;
        @define-color flamingo #f2cdcd;
        @define-color rosewater #f5e0dc;

        * {
          font-family:
            "JetBrainsMono NF",
            "Symbols Nerd Font",
            "Noto Sans Bengali",
            "Noto Serif Bengali",
            "Liberation Sans",
            "DejaVu Sans";
          font-weight: bolder;
          font-size: 14px;
        }

        window#waybar {
          background-color: transparent;
          color: @sapphire;
          transition-property: background-color;
          transition-duration: 0.5s;
        }

        window#waybar.hidden {
          opacity: 0.2;
        }

        window#waybar.termite {
          background-color: #3f3f3f;
        }

        window#waybar.chromium {
          background-color: #000000;
          border: none;
        }

        button {
          box-shadow: inset 0 -3px transparent;
          border: none;
          border-radius: 0;
        }

        #workspaces {
          background: transparent;
          border-radius: 6px;
          padding: 1px 4px;
          margin: 1px 3px;
        }

        #workspaces button {
          padding: 4px 12px;
          margin: 2px 3px;
          border-radius: 999px;
          background: transparent;
          color: @subtext0;
          border: 1px solid rgba(255, 255, 255, 0.2);
          transition: all 300ms ease-in-out;
          min-width: 24px;
          font-weight: 500;
          font-size: 11px;
        }

        #workspaces button:hover {
          color: @blue;
          background: rgba(137, 180, 250, 0.2);
          border-color: @blue;
        }

        #workspaces button.empty {
          color: @surface2;
          opacity: 0.7;
        }

        #workspaces button.visible {
          color: @text;
          background: @surface1;
          border-color: @text;
        }

        #workspaces button.active {
          color: @crust;
          background: @mauve;
          border-color: @mauve;
          box-shadow: 0 0 8px rgba(203, 166, 247, 0.6);
        }

        #workspaces button.urgent {
          color: @crust;
          background: @red;
          border-color: @red;
          box-shadow: 0 1px 4px rgba(243, 139, 168, 0.4);
        }

        #image {
          margin: 4px 0 4px 10px;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #wireplumber,
        #custom-pacman,
        #custom-power,
        #mode,
        #idle_inhibitor,
        #scratchpad,
        #mpd {
          padding: 4px 8px;
          color: @text;
          border-radius: 999px;
          margin: 2px 3px;
          background: rgba(255, 255, 255, 0.05);
          border: 1px solid rgba(255, 255, 255, 0.1);
          transition: all 300ms ease-in-out;
        }

        /* Power profiles pill */
        #power-profiles-daemon {
          padding: 4px 8px;
          color: @text;
          background: rgba(249, 226, 175, 0.1);
          border: 1px solid rgba(249, 226, 175, 0.3);
          border-radius: 999px;
          margin: 2px 3px;
          transition: all 300ms ease-in-out;
        }

        #power-profiles-daemon:hover {
          background: rgba(249, 226, 175, 0.2);
          border-color: rgba(249, 226, 175, 0.5);
          box-shadow: 0 2px 8px rgba(249, 226, 175, 0.3);
        }

        /* Audio group - one complete pill */
        #custom-audio-input, #pulseaudio {
          padding: 4px 8px;
          color: @text;
          background: rgba(203, 166, 247, 0.1);
          border: 1px solid rgba(203, 166, 247, 0.3);
          transition: all 300ms ease-in-out;
        }

        #custom-audio-input {
          border-radius: 999px 0 0 999px;
          margin: 2px 0 2px 3px;
          margin-right: 0;
          border-right: none;
        }

        #pulseaudio {
          border-radius: 0 999px 999px 0;
          margin: 2px 3px 2px 0;
          margin-left: 0;
          border-left: none;
        }



        /* Individual bluetooth and network pills */
        #bluetooth {
          padding: 4px 8px;
          color: @text;
          background: rgba(137, 180, 250, 0.1);
          border: 1px solid rgba(137, 180, 250, 0.3);
          border-radius: 999px;
          margin: 2px 3px;
          transition: all 300ms ease-in-out;
        }



        #custom-audio-input:hover, #pulseaudio:hover {
          background: rgba(203, 166, 247, 0.2);
          border-color: rgba(203, 166, 247, 0.5);
          box-shadow: 0 2px 8px rgba(203, 166, 247, 0.3);
        }

        /* Tray pill - using network blue colors for nm-applet */
        #tray {
          padding: 4px 8px;
          color: @text;
          background: rgba(137, 180, 250, 0.1);
          border: 1px solid rgba(137, 180, 250, 0.3);
          border-radius: 999px;
          margin: 2px 3px;
          transition: all 300ms ease-in-out;
        }

        #bluetooth:hover {
          background: rgba(137, 180, 250, 0.2);
          border-color: rgba(137, 180, 250, 0.5);
          box-shadow: 0 2px 8px rgba(137, 180, 250, 0.3);
        }

        #tray:hover {
          background: rgba(137, 180, 250, 0.2);
          border-color: rgba(137, 180, 250, 0.5);
          box-shadow: 0 2px 8px rgba(137, 180, 250, 0.3);
        }

        #custom-power:hover, #battery:hover, #clock:hover {
          background: rgba(255, 255, 255, 0.1);
          border-color: rgba(255, 255, 255, 0.2);
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }

        #window {
          margin: 0 4px;
          padding: 4px 12px;
          background: rgba(255, 255, 255, 0.05);
          border: 1px solid rgba(255, 255, 255, 0.1);
          border-radius: 999px;
          color: @text;
          font-weight: 500;
          transition: all 300ms ease-in-out;
        }

        #window:hover {
          background: rgba(255, 255, 255, 0.1);
          border-color: rgba(255, 255, 255, 0.2);
        }

        #window.empty {
          opacity: 0;
          margin: 0;
          padding: 0;
          min-width: 0;
        }

        #workspaces {
          margin: 0 4px;
        }

        .modules-left>widget:first-child>#workspaces {
          margin-left: 2px;
        }

        #clock {
          color: @text;
        }

        #custom-pacman {
          color: @peach;
        }

        #pulseaudio {
          color: @mauve;
        }

        #pulseaudio.muted {
          color: @surface2;
        }



        #battery {
          color: @green;
        }

        #battery.good {
          color: @green;
        }

        #battery.warning:not(.charging) {
          color: @yellow;
        }

        #battery.critical:not(.charging) {
          color: @red;
          animation: blink 1s linear infinite alternate;
        }

        #battery.charging {
          color: @blue;
        }

        #battery.plugged {
          color: @sapphire;
        }

        #battery.full {
          color: @teal;
        }

        @keyframes blink {
          from { opacity: 1; }
          to { opacity: 0.7; }
        }

        #custom-power {
          color: @maroon;
        }



        #bluetooth {
          font-size: 17px;
          color: white;
        }

        #keyboard-state>label {
          padding: 0 5px;
        }

        #keyboard-state>label.locked {
          background: rgba(0, 0, 0, 0.2);
        }

        #scratchpad {
          background: rgba(0, 0, 0, 0.2);
        }

        #scratchpad.empty {
          background-color: transparent;
        }

        .modules-left {
          background: rgba(45, 47, 58, 0.7);
          border-radius: 999px;
          padding-right: 12px;
          padding-left: 4px;
          margin: 3px 0 0 8px;
          border: 1px solid rgba(255, 255, 255, 0.15);
          box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
        }

        .modules-center {
          background: rgba(45, 47, 58, 0.7);
          border-radius: 999px;
          padding: 0 12px;
          margin-top: 3px;
          border: 1px solid rgba(137, 180, 250, 0.4);
          box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
        }

        .modules-right {
          background: rgba(45, 47, 58, 0.7);
          border-radius: 999px;
          padding: 0 12px;
          margin: 3px 8px 0 0;
          border: 1px solid rgba(255, 255, 255, 0.15);
          box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
        }

        #custom-spotify {
          color: @green;
          padding-right: 10px;
          transition: all 300ms ease-in-out;
        }

        #custom-spotify.playing {
          color: @green;
        }

        #custom-spotify.paused {
          color: @yellow;
        }

        #custom-spotify.stopped {
          color: @surface2;
          opacity: 0.7;
        }

        #custom-notification {
          color: white;
          padding-right: 10px;
        }
      '';
    };

    # Network Manager Applet service
    systemd.user.services.nm-applet = {
      Unit = {
        Description = "Network Manager Applet";
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };

    # Explicitly manage systemd service state
    systemd.user.services.waybar = mkIf (!cfg.enable) {
      Unit.Description = "Disabled waybar service";
      Install = { };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "/run/current-system/sw/bin/true";
      };
    };
  };
}
