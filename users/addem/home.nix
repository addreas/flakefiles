{ pkgs, lib, ... }:
{
  home = {
    stateVersion = "22.11";
    username = "addem";
    homeDirectory = "/home/addem";
  };

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
    kubectx
    kustomize
    krew
    k9s
    fluxcd
    kubernetes-helm
    cilium-cli
  ];
}
