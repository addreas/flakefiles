{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../default.nix
  ];
  networking.hostName = "nucle1";
  systemd.network.networks.lan.name = "eno1";

  services.kubeadm.controlPlane = true;
}

