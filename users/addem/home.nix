{ pkgs, lib, ... }:
{
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

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
    kubectl
    fluxcd
    kubernetes-helm
    cilium-cli
  ];
}
