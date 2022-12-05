{ pkgs, lib, ... }:
{
  # programs.swaylock.package = pkgs.swaylock-effects;
  programs.swaylock.settings = {
    indicator = true;
    clock = true;
    text-color = "EEEEEE";
    image = "$(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)";
    effect-blur =  "5x1";
    inside-clear-color =  "000000C0";
    text-caps-lock-color = "FA0000C0";
    text-clear-color = "E5A555FF";
    line-uses-inside = true;
  };
}
