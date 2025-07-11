{ lib, ... }:
{
  wayland.windowManager.hyprland.settings = {
    # layer rules
    layerrule =
      let
        toRegex =
          list:
          let
            elements = lib.concatStringsSep "|" list;
          in
          "^(${elements})$";

        layers = [
          "bar"
          "side-left"
          "side-right"
          "launcher"
          "floating-player"
          "notifications"
        ];
      in
      [
        "blur, ${toRegex layers}"
        "ignorealpha 0.4, ${toRegex layers}"
        "animation slide, ${toRegex layers}"
      ];

    # window rules
    windowrulev2 = [
      "dimaround, class:^(gcr-prompter)$"
      "dimaround, class:^(xdg-desktop-portal-gtk)$"
      "dimaround, class:^(polkit-gnome-authentication-agent-1)$"
      "float, class:^(clipse)$"
      "float, class:^(imv)$"
      "float, class:^(io.bassi.Amberol)$"
      "float, class:^(io.github.celluloid_player.Celluloid)$"
      "float, class:^(nm-connection-editor)$"
      "float, class:^(org.gnome.Loupe)$"
      "float, class:^(pavucontrol)$"
      "float, class:^(xdg-desktop-portal-gtk)$"
      "float, title:^(Media viewer)$"
      "float, title:^(Picture-in-Picture)$"
      "float, class:^(obsidian)$"
      "idleinhibit focus, class:^(mpv|.+exe|celluloid)$"
      "idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$"
      "idleinhibit fullscreen, class:^(firefox)$"
      "pin, title:^(Picture-in-Picture)$"
      "workspace special silent, title:^(.*is sharing (your screen|a window).)$"
      "workspace special silent, title:^(Firefox — Sharing Indicator)$"
      "workspace special, class:^(obsidian)$"
      "workspace 2,class:^(firefox)$"
      "workspace 2,class:^(zen-alpha)$"
      "workspace 4,class:^(Spotify)$"
      "workspace 5,class:^(Slack)$"
    ];
  };
}
