{ pkgs, lib, ... }:
{
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  imports = [
    ./helix.nix
    ./kanshi.nix
    ./kdeconnect.nix
    ./kitty.nix
    ./swayidle.nix
    ./swaylock.nix
    ./sway.nix
    ./ulauncher.nix
    ./variety.nix
    ./waybar.nix
    ./zsh.nix
    ./zsh-omp.nix
  ];

  home.sessionVariables = {
    EDITOR = "hx";
  };

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";

    gtk.enable = true;
    x11.enable = true;
  };
}
