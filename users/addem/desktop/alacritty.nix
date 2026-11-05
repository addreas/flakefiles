{ config, pkgs, ... }:
let
  # DMS/matugen writes this; don't set colours below or they win over it.
  dankTheme = "~/.config/alacritty/dank-theme.toml";

  fallbackColors = {
    primary = {
      background = "#020202";
      foreground = "#B3B1AD";
    };

    normal = {
      black = "#0D0D0D";
      red = "#DD3E25";
      green = "#5A8025";
      yellow = "#F9AF4F";
      blue = "#53BDFA";
      magenta = "#FAE994";
      cyan = "#90E1C6";
      white = "#C7C7C7";
    };

    bright = {
      black = "#686868";
      red = "#F07178";
      green = "#C2D94C";
      yellow = "#CFCA0D";
      blue = "#59C2FF";
      magenta = "#FFEE99";
      cyan = "#95E6CB";
      white = "#FFFFFF";
    };
  };
in
{
  programs.alacritty = {
    enable = true;

    settings = {
      general.import = [
        "~/.config/alacritty/fallback-theme.toml"
        dankTheme
      ];

      window = {
        opacity = 0.9;
        padding.x = 1;
        dynamic_padding = true;
        decorations = "none";
        dynamic_title = true;
        title = "";
      };

      scrolling.history = 10000;
      scrolling.multiplier = 5;

      font.normal.family = "Hack Nerd Font";

      keyboard.bindings = [
        { key = "PageUp"; action = "ScrollLineUp"; }
        { key = "PageDown"; action = "ScrollLineDown"; }
      ];
    };
  };

  xdg.configFile."alacritty/fallback-theme.toml".source =
    (pkgs.formats.toml { }).generate "alacritty-fallback-theme.toml" {
      colors = fallbackColors;
    };
}
