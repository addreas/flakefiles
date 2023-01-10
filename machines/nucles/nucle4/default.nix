{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../default.nix
  ];

  networking.hostName = "nucle4";

  services.kubeadm.init = {
    enable = true;
    bootstrapTokenFile = "/var/secret/kubeadm-bootstrap-token"; # ssh nucle1.localdomain -- kubeadm token create | ssh nucle4.localdomain -- sudo tee /var/secret/kubeadm-bootstrap-token
  };
}

