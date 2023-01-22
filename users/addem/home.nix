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

  home.packages = with pkgs; [
    go
    deno
    cue
  ];

  programs.home-manager.enable = true;

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;
}
