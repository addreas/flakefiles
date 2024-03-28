{ pkgs, flakepkgs, lib, ... }:
{
  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

  programs.navi.enable = true;

  programs.bat.enable = true;

  # programs.atuin.enable = true; # synced shell history, would want to self host first

  # programs.jujutsu.enable = true; jj # jj git replacement
  # programs.jujutsu.enableZshIntegration = true;

  imports = [
    ./home.nix
    ./k9s.nix
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
    nodePackages.pnpm
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
    tio
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
      # https://jvns.ca/blog/2024/02/16/popular-git-config-options
      merge.conflictstyle = "zdiff3";
      push.default = "current";
      pull.rebase = true;
      fetch.prune = true;
      init.defaultBranch = "main";
      rerere.enabled = true;
      help.autocorrect = "prompt";
      diff.algorithm = "histogram";
      diff.colorMoved = true;
      branch.autosetupmerge = true;
    };

    delta = {
      enable = true;
      options = {
        features = "decorations";
        line-numbers = true;
        right-arrow = "⟶";
        relative-paths = true;
        navigate = true;
        # hyperlinks = true;

        decorations = {
          file-decoration-style = "ul ol";
          hunk-header-style = "syntax";
          hunk-header-decoration-style = "none";
        };
      };
    };
  };
}
