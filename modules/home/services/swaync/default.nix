#              ╭──────────────────────────────────────────────────╮
#              │             CREDITS TO: @khaneliman              │
#              │ THIS IS A FORK OF HIS CONFIG, ALL CREDITS TO HIM │
#              ╰──────────────────────────────────────────────────╯
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  dependencies = with pkgs; [
    bash
    config.wayland.windowManager.hyprland.package
    coreutils
    grim
    hyprpicker
    jq
    libnotify
    slurp
    wl-clipboard
  ];

  settings = import ./settings.nix { inherit lib pkgs; };
  style = import ./style.nix { inherit config; };

  cfg = config.meadow.services.swaync;
in
{
  options.meadow.services.swaync.enable = mkEnableOption "swaync";

  config = mkIf cfg.enable {
    services.swaync = {
      enable = true;
      package = pkgs.swaynotificationcenter;

      inherit settings;
      inherit (style) style;
    };

    systemd.user.services.swaync.Service.Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}";
  };
}
