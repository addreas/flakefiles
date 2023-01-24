{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../default.nix
  ];
  networking.hostName = "nucle2";

  services.kubeadm.controlPlane = true;

  services.kubeadm.init = {
    enable = true;
    bootstrapTokenFile = "/var/secret/kubeadm-bootstrap-token"; 
    certificateKeyFile = "/var/secret/kubeadm-cert-key";
  };
}

