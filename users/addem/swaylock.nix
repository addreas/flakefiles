{ pkgs, lib, config, ... }:
{
  programs.swaylock.package = pkgs.swaylock-effects;
  programs.swaylock.settings = {
    indicator = true;
    clock = true;
    text-color = "EEEEEE";
    image = "${config.xdg.configHome}/variety/wallpaper/wallpaper.jpg";
    effect-blur = "5x1";
    inside-clear-color = "000000C0";
    text-caps-lock-color = "FA0000C0";
    text-clear-color = "E5A555FF";
    line-uses-inside = true;
  };

  # expects `cp $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt) $HOME/.config/variety/wallpaper/wallpaper.jpg` in /home/addem/.config/variety/scripts/set_wallpaper
}
