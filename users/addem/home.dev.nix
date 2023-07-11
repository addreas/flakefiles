{ pkgs, lib, ... }:
{
  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

  imports = [
    ./home.nix
  ];

  home.packages = with pkgs; [
    go
    ko
    go-jsonnet
    jsonnet-bundler
    cue
    nodejs
    python3
    rustup
    # rust-analyzer
    deno
    rlwrap
    # openocd
    # blackmagic
    gnumake
    cmake
    pkgconfig
    gcc
    kubeseal
    # gcc-arm-embedded

    nixpkgs-fmt
  ];

  programs.go = {
    enable = true;
    goPath = ".go";
  };

  programs.git = {
    enable = true;
    userName = "Andreas Mårtensson";
    userEmail = "andreas@addem.se";

    extraConfig = {
      push.default = "simple";
      push.autoSetupRemote = true;
      pull.rebase = true;
      fetch.prune = true;
      init.defaultBranch = "main";
      branch.autosetupmerge = true;
    };

    delta.enable = true;
    # diff-so-fancy.enable = true;
    # difftastic.enable = true;
  };
}
