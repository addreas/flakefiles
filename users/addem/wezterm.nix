{ pkgs, lib, ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;

    extraConfig = ''
      return {
        font = wezterm.font("Hack"),
        font_size = 12.0,
        adjust_window_size_when_changing_font_size = false;
        hide_tab_bar_if_only_one_tab = true,
        enable_scroll_bar = true,
        window_background_opacity = 0.9,
      }
    '';
  };
}
