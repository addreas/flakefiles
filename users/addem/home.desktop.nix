{ pkgs, lib, ... }:
{
  imports = [
    ./home.nix
    ./home.dev.nix
    ./kanshi.nix
    ./kdeconnect.nix
    ./kitty.nix
    ./swayidle.nix
    ./swaylock.nix
    ./sway.nix
    ./ulauncher.nix
    ./variety.nix
    ./waybar.nix
  ];

  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";

    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    WLR_DRM_NO_MODIFIERS = "1";
  };
}
