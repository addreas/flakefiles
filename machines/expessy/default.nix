# ./users/mkshadow.d.sh addem
# ./users/mkshadow.d.sh addem /mnt
# sudo nixos-install --root /mnt --flake .#expessy --no-root-password
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../users/addem.nix
    ../../packages/basic/common.nix
    ../../packages/basic/services.nix
    ../../packages/basic/desktop.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = false;

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  system.autoUpgrade.enable = true;
  system.autoUpgrade.flake = "/home/addem/github.com/addreas/flakefiles";
  system.autoUpgrade.flags = [ "--update-input" "nixpkgs" ];

  # requires manual `sudo btrfs subvolume create /.snapshots`
  # services.snapper.snapshotRootOnBoot = true;
  # services.snapper.configs.root.subvolume = /;

  networking.hostName = "expessy";
  networking.domain = "localdomain";

  networking.networkmanager.enable = true;

  users.mutableUsers = false;

  environment.pathsToLink = [ "/share" ];

  # services.tailscale.enable = true;
}

