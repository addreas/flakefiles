{ pkgs, lib, ... }:
{
  home.stateVersion = "22.11";
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
    rust-analyzer
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
  ];

  programs.go = {
    enable = true;
    goPath = ".go";
  };
}
