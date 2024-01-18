{ pkgs, flakepkgs, lib, ... }:
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
    elixir
    elixir-ls
    nodejs
    deno
    python3
    rustup

    kubeseal

    gnumake
    pkg-config
    cmake
    ninja
    gcc
    gcc-arm-embedded
    openocd
    # blackmagic

    unzip
    file
    rlwrap

    nixpkgs-fmt
    cntr
  ];

  programs.go = {
    enable = true;
    goPath = ".go";
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
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
