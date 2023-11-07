{ pkgs, lib, ... }:
{
  home = {
    stateVersion = "23.05";
    username = "addem";
    homeDirectory = "/home/addem";
  };

  programs.home-manager.enable = true;

  imports = [
    ./helix.nix
    ./zsh.nix
    # ./zsh-omp.nix
    ./zsh-starship.nix
  ];

  home.sessionPath = [
    "$HOME/.bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.go/bin"
    "$HOME/.krew/bin"
  ];

  home.sessionVariables = {
    EDITOR = "hx";
    PAGER = "less";
    LESS = "-R";
    # LESS = "-F -X";
    VIRTUAL_ENV_DISABLE_PROMPT = "1";
    PIPENV_SHELL_FANCY = "1";
    ERL_AFLAGS = "-kernel shell_history enabled";
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

    kitty.terminfo
  ];
}
