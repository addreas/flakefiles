{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/installer/netboot/netboot-minimal.nix")

    ../../packages/common.nix
    ../../packages/services.nix
    ../../users/addem.nix
  ];
}

