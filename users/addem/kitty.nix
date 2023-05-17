{ pkgs, lib, ... }:
{
  programs.kitty = {
    enable = true;
    # theme = "One Dark";
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      background_opacity = "0.85";
    };
  };
}
