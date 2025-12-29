{ config, pkgs, lib, ... }:
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
    gleam
    erlang_27
    rebar3
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
    ttylog
    # blackmagic
    # nrfutil
    nrf-command-line-tools
    (nrfutil.withExtensions [
      "nrfutil-nrf5sdk-tools"
      "nrfutil-device"
    ])

    unzip
    file
    rlwrap
    inotify-tools
    openssl

    nixpkgs-fmt
    cntr

    (pkgs.buildFHSEnv {
      name = "pixi";
      runScript = "pixi";
      targetPkgs = pkgs: with pkgs; [
        pixi

        glib
        dbus
        fontconfig
        freetype
        libGL
        libxkbcommon
        xorg.libX11
        xorg.libXext
        xorg.libxcb
        xorg.xcbutilwm
        xorg.xcbutilimage
        xorg.xcbutilkeysyms
        xorg.xcbutilrenderutil

        musl
        iconv
        glibc_multi

        zlib
        zstd
        xz
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        bzip2
        libxml2
        acl
        libsodium
        util-linux
      ];
    })
  ];

  programs.go = {
    enable = true;
    env.GOPATH = ["${config.home.homeDirectory}/.go"];
  };

  programs.git = {
    enable = true;
    lfs.enable = true;


    settings = {
      # https://jvns.ca/blog/2024/02/16/popular-git-config-options
      user.name = "Andreas Mårtensson";
      user.email = "andreas@addem.se";
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

  };
  programs.delta = {
      enable = true;
      enableGitIntegration = true;
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
}
