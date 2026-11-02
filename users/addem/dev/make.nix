{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gnumake
    pkg-config
    cmake
    ninja
    gcc
  ];
}
