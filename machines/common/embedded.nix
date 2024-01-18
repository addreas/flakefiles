{ config, pkgs, flakepkgs, ... }:
{
  services.udev.packages = [
    pkgs.openocd
    flakepkgs.nrf-udev
    flakepkgs.segger-jlink
  ];

  environment.systemPackages = with pkgs; [
    pkgs.openocd
    flakepkgs.segger-jlink
    flakepkgs.nrfconnect
  ];
}

