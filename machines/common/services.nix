{ config, pkgs, lib, ... }:
{
  services.openssh.enable = true;
  services.locate.enable = true;
  services.locate.package = pkgs.plocate;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  virtualisation.podman.enable = true;

  environment.systemPackages = with pkgs; [
    podman
  ];
}

