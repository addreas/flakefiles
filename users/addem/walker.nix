{ config, pkgs, lib, inputs, ... }:
{
  imports = [inputs.walker.homeManagerModules.default];

  programs.walker = {
    enable = true;
    runAsService = true;
    elephant.debug = true;
  };

  # services.walker = {
  #   enable = true;
  #   settings = {
  #     app_launch_prefix = "";
  #     as_window = false;
  #     close_when_open = false;
  #     disable_click_to_close = false;
  #     force_keyboard_focus = false;
  #     hotreload_theme = false;
  #     locale = "";
  #     monitor = "";
  #     terminal_title_flag = "";
  #     theme = "default";
  #     timeout = 0;
  #   };
  #   systemd.enable = true;
  # };

  

  # systemd.user.services.walker.Service.Environment = "PATH=${lib.makeBinPath (with pkgs; [
  #   wl-clipboard
  #   libqalculate
  # ])}";
}
