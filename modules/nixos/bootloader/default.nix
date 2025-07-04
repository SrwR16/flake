{ lib, ... }:
{
  boot = {
    kernel.sysctl."net.isoc" = true;
    loader = {
      # Disable GRUB completely
      grub.enable = lib.mkForce false;

      # Enable systemd-boot
      systemd-boot = {
        enable = true;
        configurationLimit = 3; # Keep last 15 generations
        consoleMode = "auto";
        editor = false; # Disable editing boot entries for security
      };

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };
}
