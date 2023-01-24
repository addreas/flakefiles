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
    deno
    cue
    rlwrap
    openocd
    blackmagic
    gnumake
    cmake
    gcc
    gcc-arm-embedded
  ];
}
