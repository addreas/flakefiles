{ config, pkgs, lib, modulesPath, ... }:
let pixieApiContent = pkgs.stdenv.mkDerivation {
  name = "pixie-api-content";
  src = ;
    };
  in
  {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64-installer.nix")

    ../../users/addem.nix
    ../../packages/basic/common.nix
    ../../packages/basic/services.nix
  ];

  system.stateVersion = "22.11";

  sdImage.compressImage = false;

  networking.hostName = "pixie-pie";

  networking.firewall.enable = true;
  networking.interfaces.eth0.useDHCP = true;

  services.pixiecore = {
    enable = true;
    mode = "api";
    apiServer = "http://pixie-api.localhost:8080";
    openFirewall = true;
    dhcpNoBind = true;
  };

  hardware.raspberry-pi."4".poe-hat.enable = true;
}
