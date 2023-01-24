{ config, pkgs, lib, ... }:
{
  services.openssh.enable = true;
  services.locate.enable = true;
  services.locate.locate = pkgs.plocate;
  services.locate.localuser = null;
  services.avahi.enable = true;

  virtualisation.podman.enable = true;

  environment.systemPackages = with pkgs; [
    podman
  ];
}

