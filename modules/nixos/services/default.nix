{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    ;
in
{
  options.meadow.services = {
    pipewire.enable = mkEnableOption "pipewire";
    power-profiles-daemon.enable = mkEnableOption "power-profiles-daemon";
  };
  config = {
    services = {
      gvfs.enable = true;
      blueman.enable = true;
      dbus.enable = true;
      upower.enable = true;
      logind = {
        settings = {
          Login = {
            HandlePowerKey = "suspend";
            HandleLidSwitch = "suspend";
            HandleLidSwitchExternalPower = "suspend";
          };
        };
      };

      tailscale = mkIf config.meadow.programs.tailscale.enable { enable = true; };

      # xserver.enable = true;

      xserver.xkb = {
        layout = "us";
      };

      xserver.xkb.options = "compose:rctrl";

      pipewire = mkIf config.meadow.services.pipewire.enable {
        enable = true;
        pulse.enable = true;
      };

      power-profiles-daemon = mkIf config.meadow.services.power-profiles-daemon.enable {
        enable = true;
      };

      gnome = {
        gnome-keyring.enable = true;
        glib-networking.enable = true;
      };

      greetd = mkIf config.meadow.programs.wayland.enable {
        enable = true;
        settings = {
          terminal.vt = 1;
          default_session = {
            command = "${pkgs.greetd}/bin/agreety --cmd ${pkgs.hyprland}/bin/Hyprland";
          };
        };
      };
    };
  };
}
