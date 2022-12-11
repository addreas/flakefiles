{ pkgs, lib, ... }:
{
  home.stateVersion = "22.11";

  imports = [
    ./helix.nix
    ./zsh.nix
    ./zsh-omp.nix
  ];

  home.sessionVariables = {
    EDITOR = "hx";
    PAGER = "less";
    LESS = "-R";
  };

  programs.home-manager.enable = true;

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;
}
