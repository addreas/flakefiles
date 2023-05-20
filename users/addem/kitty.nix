{ pkgs, lib, ... }:
{
  programs.kitty = {
    enable = true;
    font.name = "Hack Nerd Font";
    # theme = "One Dark";
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      background_opacity = "0.85";
    };
  };
}
