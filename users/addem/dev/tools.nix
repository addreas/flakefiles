{ pkgs, ... }:
{
  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

  programs.navi.enable = true;

  programs.bat.enable = true;

  # programs.atuin.enable = true; # synced shell history, would want to self host first

  # programs.jujutsu.enable = true; jj # jj git replacement
  # programs.jujutsu.enableZshIntegration = true;

  home.packages = with pkgs; [
    unzip
    file
    rlwrap
    inotify-tools
    openssl

    nixpkgs-fmt
    cntr

    kubeseal
    mask
    sops
    age
  ];
}
