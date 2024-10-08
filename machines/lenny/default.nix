# ./users/mkshadow.d.sh addem
# ./users/mkshadow.d.sh addem /mnt
# sudo nixos-install --root /mnt --flake .#expessy --no-root-password
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/base.nix
    ../common/services.nix
    ../common/desktop.nix
    ../common/embedded.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = false;
  
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "23.05";

  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.flake = "/home/addem/github.com/addreas/flakefiles";
  # system.autoUpgrade.flags = [ "--update-input" "nixpkgs" ];

  # requires manual `sudo btrfs subvolume create /.snapshots`
  # services.snapper.snapshotRootOnBoot = true;
  # services.snapper.configs.root.subvolume = /;

  networking.hostName = "lenny";
  networking.domain = "localdomain";

  networking.networkmanager.enable = true;

  users.mutableUsers = false;

  environment.pathsToLink = [ "/share" ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    # extraUpFlags = ["--accept-dns" "--accept-routes"];
  };
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false; # https://github.com/NixOS/nixpkgs/issues/180175
  programs.wireshark.enable = true;
  services.tlp.enable = true;
  services.fwupd.enable = true;

  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    lutris
    winetricks
    wineWowPackages.waylandFull
    # cura
    prusa-slicer
  ];

  networking.firewall.allowedTCPPorts = [
    8080
    8081
    5580
  ];
}

