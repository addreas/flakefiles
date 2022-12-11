{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../default.nix
  ];
  networking.hostName = "nucle4";
  systemd.network.networks.lan.name = "eno1";
}

