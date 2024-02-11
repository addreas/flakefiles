{ config, pkgs, flakepkgs, ... }:
{
  services.udev.packages = [
    pkgs.openocd
    pkgs.segger-jlink
    flakepkgs.nrf-udev
  ];

  environment.systemPackages = with pkgs; [
    openocd
    segger-jlink
    nrfconnect
  ];
}

