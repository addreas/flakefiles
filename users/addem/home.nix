{ pkgs, lib, ... }:
{
  home = {
    stateVersion = "23.05";
    username = "addem";
    homeDirectory = "/home/addem";
  };

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

    tree
  ];

  programs.home-manager.enable = true;

  programs.fzf.enable = true;
  programs.ripgrep.enable = true;

  # z auto jump thing, would i use it?
  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;
  # programs.pazi.enable = true;

  # filemanagers, yazi + broot frankenstein wouldbe cool
  # programs.yazi.enable = true;
  # programs.broot.enable = true;
  # programs.joshuto.enable = true;

  home.file.digrc = {
    target = ".digrc";
    text = ''
      +nostats +nocomments +nocmd +noquestion +recurse
    '';
  };
}
