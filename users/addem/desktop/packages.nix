{ pkgs, ... }:
{
  home.packages = with pkgs; [
    firefox-bin
    chromium
    nautilus
    file-roller
    evince
    pavucontrol
    wl-clipboard
    wdisplays
    nfs-utils
    cifs-utils
  ];
}
