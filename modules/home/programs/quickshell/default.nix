{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;

  cfg = config.meadow.programs.quickshell;
in
{
  options.meadow.programs.quickshell = {
    enable = mkEnableOption "Wether to create quickshell custom theme";
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.quickshell.packages."${pkgs.system}".quickshell
      pkgs.kdePackages.qt5compat
      pkgs.kdePackages.qtmultimedia
      pkgs.kdePackages.qtwayland

      inputs.caelestia-cli.packages."${pkgs.system}".default
      inputs.caelestia.packages."${pkgs.system}".default

      # DankMaterialShell dependencies
      pkgs.material-symbols # Material Design icons
      pkgs.inter # Inter font family
      pkgs.fira-code # Fira Code font
      pkgs.cava # Console audio visualizer
      pkgs.wl-clipboard # Wayland clipboard
      pkgs.cliphist # Clipboard history
      pkgs.ddcutil # Display control
      pkgs.libsForQt5.qt5ct # Qt5 configuration tool
      pkgs.kdePackages.qt6ct # Qt6 configuration tool
      pkgs.matugen # Material theme generator

      # System integration dependencies
      pkgs.upower # Battery management
      pkgs.pipewire # Audio system
      pkgs.wireplumber # Audio session manager
      pkgs.networkmanagerapplet # Network management
      pkgs.bluez # Bluetooth
      pkgs.brightnessctl # Brightness control
      pkgs.playerctl # Media controls (MPRIS)
      pkgs.libnotify # Notifications
      pkgs.grim # Screenshots
      pkgs.slurp # Screen selection
      pkgs.jq # JSON processing
      pkgs.curl # Network requests
    ];

    # DankMaterialShell configuration
    home.file = {
      # Complete DankMaterialShell configuration
      ".config/quickshell/DankMaterialShell".source = ./.;

      # Create symbolic link for short name
      ".config/quickshell/dms".source = ./.;
    };

    # QuickShell bar systemd service
    systemd.user.services.quickshell-bar = {
      Unit = {
        Description = "QuickShell Bar";
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${inputs.quickshell.packages."${pkgs.system}".quickshell}/bin/quickshell -c dms";
        Restart = "on-failure";
        RestartSec = 1;
        Environment = [
          "QT_QPA_PLATFORM=wayland"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION=1"
        ];
      };
    };

    wayland.windowManager.hyprland = {
      settings = {
        bind = [
          # "SUPER, D, global, caelestia:launcher"
          "SUPER, C, global, caelestia:clearNotifs"
          "SUPER, L, global, caelestia:lock"

          "SUPERSHIFT, S, global, caelestia:screenshot"
        ];

        # Launch QuickShell on startup
        exec-once = [
          "systemctl --user start quickshell-bar"
        ];
      };
    };
  };
}
