{ pkgs, config, ... }:
{
  programs.swaylock.package = pkgs.swaylock-effects.overrideAttrs rec {
    version = "1.8.1";
    src = pkgs.fetchFromGitHub {
      owner = "hboetes";
      repo = "swaylock-effects";
      rev = "v${version}";
      hash = "sha256-6PZU72kvI+alpPSgsCixr254AjeRyaURCyhGRsTBEF8=";
    };
    mesonFlags = (pkgs.swaylock-effects.mesonFlags or [ ]) ++ [ "-Dfingerprint=disabled" ];
    patches = [ ./swaylock-screencopy-single-flight.patch ];
  };
  programs.swaylock.enable = true;
  programs.swaylock.settings = {
    indicator = true;
    clock = true;
    text-color = "EEEEEE";
    image = "${config.xdg.configHome}/variety/wallpaper/wallpaper.jpg";
    inside-clear-color = "000000C0";
    text-caps-lock-color = "FA0000C0";
    text-clear-color = "E5A555FF";
    line-uses-inside = true;
  };

  # expects `cp "$(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)" $HOME/.config/variety/wallpaper/wallpaper.jpg` in /home/addem/.config/variety/scripts/set_wallpaper
}
