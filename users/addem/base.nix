{ ... }:
{
  imports = [
    ./shell/helix.nix
    ./shell/zsh.nix
    ./shell/zsh-starship.nix
    ./shell/cli.nix
    ./k8s.nix
  ];

  home = {
    stateVersion = "23.05";
    username = "addem";
    homeDirectory = "/home/addem";
  };

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

  programs.home-manager.enable = true;
}
