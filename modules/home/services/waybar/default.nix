{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.meadow.services.waybar;
in
{
  options.meadow.services.waybar.enable = mkEnableOption "waybar";

  config.programs.waybar = {
    enable = mkIf cfg.enable true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
    settings = [
      {
        layer = "top";
        height = 37;
        spacing = 5;
        modules-left = [
          "image"
          "hyprland/workspaces"
          "custom/spotify"
        ];
        modules-center = [
          "user"
        ];
        modules-right = [
          "tray"
          "power-profiles-daemon"
          "pulseaudio"
          "network"
          "battery"
          "clock"
          "custom/notification"
          "custom/power"
        ];

        "hyprland/window" = {
          separate-outputs = false;
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          format-icons = {
            "1" = "󰌽";
            "2" = "󰮯";
            "3" = "";
            "4" = "󰊤";
            "5" = "󰣇";
            urgent = "";
            active = "";
            default = "";
          };
          sort-by-number = true;
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
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
          path = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          size = 20;
          interval = 5;
          on-click = "firefox https://search.nixos.org/packages";
        };

        "tray" = {
          spacing = 10;
        };

        "clock" = {
          tooltip-format = "{:%A, %B %d, %Y}";
          format = "{:%I:%M}";
        };

        "battery" = {
          states = {
            warning = 40;
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
          format-warning = "󰂃 {capacity}%";
          tooltip-format = "{capacity}%";
        };

        "network" = {
          format-wifi = "{ipaddr}";
          format-ethernet = "";
          format-disconnected = "";
          tooltip-format = "Connected to {essid}";
          tooltip-format-ethernet = "{ifname}";
          on-click = "hyprctl dispatch exec '[float]' 'foot -e nmtui'";
        };

        "pulseaudio" = {
          scroll-step = 5;
          format = "{icon}";
          format-muted = "";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          tooltip-format = "{volume}% volume";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        };

        "custom/power" = {
          format = "󰐥";
          on-click = "wlogout";
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
          format = "{} {icon}";
          format-icons = {
            notification = "󱅫";
            none = "";
            dnd-notification = " ";
            dnd-none = "󰂛";
            inhibited-notification = " ";
            inhibited-none = "";
            dnd-inhibited-notification = " ";
            dnd-inhibited-none = " ";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "sleep 0.1 && swaync-client -t -sw";
          on-click-right = "sleep 0.1 && swaync-client -d -sw";
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
          "Symbols Nerd Font";
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

      #workspaces button:hover {
        color: @blue;
        box-shadow: inherit;
        text-shadow: inherit;
        background: @crust;
        border: @crust;
      }

      #workspaces button.empty {
        color: #44475a;
      }

      #workspaces button {
        padding: 0 5px;
        color: @surface2;
        margin: 4px 0 4px 0;
        transition: color 200ms ease-in-out;
      }

      #workspaces button.selected {
        color: @blue;
      }

      #workspaces button.active {
        color: @mauve;
      }

      #workspaces button.urgent {
        color: @red;
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
      #network.wifi,
      #network.disconnected,
      #wireplumber,
      #custom-pacman,
      #custom-power,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #mpd {
        padding: 0 6px;
        color: @text;
        border-radius: 15px;
        margin: 5px 0;
      }

      #power-profiles-daemon.balanced,
      #power-profiles-daemon.power-saver {
        margin-right: 7px;
      }

      #pulseaudio {
        padding: 0 10px;
        color: @text;
        border-radius: 15px;
        margin: 5px 0;
      }

      #window,
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

      #network {
        color: @blue;
      }

      #network.disconnected {
        color: @surface2;
      }

      #network.ethernet {
        margin-right: 8px;
        margin-left: 8px;
      }

      #battery {
        color: @green;
      }

      #battery.warning:not(.charging) {
        color: @red;
      }

      #custom-power {
        color: @maroon;
      }

      #bluetooth {
        margin-right: 10px;
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
        background-color: @crust;
        border-radius: 10px;
        padding-right: 10px;
        margin: 5px 0 0 10px;
      }

      .modules-center {
        background-color: @crust;
        border-radius: 10px;
        padding: 0 10px;
        margin-top: 5px;
        border: solid cyan 2px;
      }

      .modules-right {
        background-color: @crust;
        border-radius: 10px;
        padding: 0 10px;
        margin: 5px 10px 0 0;
      }

      #custom-spotify {
        color: #6fcf97;
        padding-right: 10px;
      }

      #custom-notification {
        color: white;
        padding-right: 10px;
      }
    '';
  };
}
