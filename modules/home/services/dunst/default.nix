{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.meadow.services.dunst;
in
{
  options.meadow.services.dunst.enable = mkEnableOption "dunst";

  config = mkIf cfg.enable {
    services.dunst = {
      enable = true;
      package = pkgs.dunst;
      settings = {
        global = {
          # Display
          monitor = 0;
          follow = "mouse";
          width = 300;
          height = 300;
          origin = "top-right";
          offset = "10x50";
          scale = 0;
          notification_limit = 5;

          # Progress bar
          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;

          # Appearance
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          text_icon_padding = 0;
          frame_width = 2;
          gap_size = 0;
          separator_color = "frame";
          sort = "yes";

          # Text
          font = "JetBrainsMono Nerd Font 10";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\\n%b";
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 60;
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";

          # Icons
          enable_recursive_icon_lookup = true;
          icon_theme = "Adwaita";
          icon_position = "left";
          min_icon_size = 32;
          max_icon_size = 128;

          # History
          sticky_history = "yes";
          history_length = 20;

          # Misc/Advanced
          dmenu = "${pkgs.rofi-wayland}/bin/rofi -dmenu -p dunst";
          browser = "${pkgs.firefox}/bin/firefox";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          corner_radius = 10;
          ignore_dbusclose = false;
          force_xwayland = false;
          force_xinerama = false;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };

        experimental = {
          per_monitor_dpi = false;
        };

        urgency_low = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#89b4fa";
          timeout = 10;
        };

        urgency_normal = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#89b4fa";
          timeout = 10;
        };

        urgency_critical = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#f38ba8";
          timeout = 0;
        };

        # OSD notifications for brightness
        brightness = {
          appname = "LIGHTCTL";
          background = "#1e1e2e";
          foreground = "#f9e2af";
          frame_color = "#f9e2af";
          timeout = 2;
          format = "<b>%s</b>\\n%b";
        };

        # OSD notifications for volume
        volume = {
          appname = "VOLUMECTL";
          background = "#1e1e2e";
          foreground = "#cba6f7";
          frame_color = "#cba6f7";
          timeout = 2;
          format = "<b>%s</b>\\n%b";
        };

        # OSD notifications for backlight
        backlight = {
          appname = "BACKLIGHTCTL";
          background = "#1e1e2e";
          foreground = "#94e2d5";
          frame_color = "#94e2d5";
          timeout = 2;
          format = "<b>%s</b>\\n%b";
        };
      };
    };

    # Add dunst to home packages
    home.packages = with pkgs; [
      dunst
      libnotify
    ];
  };
}
