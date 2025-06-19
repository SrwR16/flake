{
  security = {
    rtkit.enable = true;
    pam.services = {
      astal-auth = { };
      hyprlock = {
        gnupg.enable = true;
        enableGnomeKeyring = true;
      };
      greetd = {
        gnupg.enable = true;
        enableGnomeKeyring = true;
      };
      login = {
        enableGnomeKeyring = true;
        gnupg = {
          enable = true;
          noAutostart = true;
          storeOnly = true;
        };
      };
    };
    polkit.enable = true;
  };
}
