{ config, pkgs, flakepkgs, ... }:
{
  services.udev.packages = [
    pkgs.openocd
    flakepkgs.nrf-udev
    flakepkgs.jlink
  ];

  environment.systemPackages = with pkgs; [
    openocd
  ];
}

