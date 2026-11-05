{ config, pkgs, ... }:
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";

    gtk.enable = true;
    x11.enable = true;
  };

  # DMS/matugen writes these from the wallpaper palette.
  gtk = {
    enable = true;

    iconTheme = {
      name = config.home.pointerCursor.name;
      package = config.home.pointerCursor.package;
    };

    gtk3.extraCss = ''@import url("file://${config.xdg.configHome}/gtk-3.0/dank-colors.css");'';
    gtk4.extraCss = ''@import url("file://${config.xdg.configHome}/gtk-4.0/dank-colors.css");'';
  };

  fonts.fontconfig.enable = true;
}
