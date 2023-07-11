# ./users/mkshadow.d.sh addem
# ./users/mkshadow.d.sh addem /mnt
# sudo nixos-install --root /mnt --flake .#expessy --no-root-password
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/base.nix
    ../common/nix-builder.nix
    ../common/services.nix
    ../common/desktop.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = false;

  system.stateVersion = "23.05";

  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.flake = "/home/addem/github.com/addreas/flakefiles";
  # system.autoUpgrade.flags = [ "--update-input" "nixpkgs" ];

  # requires manual `sudo btrfs subvolume create /.snapshots`
  # services.snapper.snapshotRootOnBoot = true;
  # services.snapper.configs.root.subvolume = /;

  networking.hostName = "expessy";
  networking.domain = "localdomain";

  networking.networkmanager.enable = true;

  users.mutableUsers = false;

  environment.pathsToLink = [ "/share" ];

  # services.tailscale.enable = true;
  programs.wireshark.enable = true;
}

