# parted /dev/sda -- mklabel gpt
# parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
# parted /dev/sda -- mkpart OS btrfs 512MiB 100%
# parted /dev/sda -- set 1 esp on

# mkfs.fat -F 32 -n boot /dev/sda1
# mkfs.btrfs -L OS /dev/sda2

# nixos-generate-config --root /mnt
# nixos-install
# reboot

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{


  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nas.nix
    ./monitoring.nix
    ./kube.nix

    ../../users/addem.nix
    ../../packages/basic/common.nix
    ../../packages/basic/services.nix

    ../../packages/cockpit/module.nix
    ../../packages/pcp/module.nix

  ];
  swapDevices = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = false;

  # boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  # boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  system.autoUpgrade.enable = true;
  system.autoUpgrade.flake = "/home/addem/flakefiles";
  system.autoUpgrade.flags = [ "--update-input" "nixpkgs" ];

  # requires manual `sudo btrfs subvolume create /.snapshots`
  # services.snapper.snapshotRootOnBoot = true;
  # services.snapper.configs.root.subvolume = "/";
  # services.snapper.configs.root.extraConfig = ''
  #   NUMBER_CLEANUP=yes
  #   NUMBER_LIMIT=10
  #   '';
  # services.locate.prunePaths = ["./snapshots"];

  networking.hostName = "sergio";
  networking.domain = "localdomain";

  systemd.network.enable = true;
  systemd.network.networks.lan.name = "eno1";
  # systemd.network.networks.lan.dns = ["192.168.1.1"];
  systemd.network.networks.lan.DHCP = "yes";
  networking.dhcpcd.enable = false;
  services.resolved.dnssec = "false"; # dnssec fails for localdomain and breaks stuff

  services.tailscale.enable = true;

  # services.pcp.enable = true;
  # services.cockpit.enable = true;

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.plex = {
    image = "linuxserver/plex";
    environment = {
      PUID = "1000";
      PGID = "1000";
      VERSION = "latest";
    };
    volumes = [
      "/mnt/videos:/data"
      "/mnt/plex-config:/config"
      "/etc/localtime:/etc/localtime"
    ];
    extraOptions = [ "--network=host" ];
  };

  virtualisation.oci-containers.containers.minio = {
    image = "minio/minio";
    cmd = [ "server" "--console-address" ":9001" "/data" ];
    environmentFiles = [
      # expecting  MINIO_ROOT_PASSWORD, MINIO_ROOT_USER
      "/home/addem/.minio-env"
    ];
    user = "1000:1000";
    ports = [ "9000:9000" "9001:9001" ];
    volumes = [
      "/mnt/minio-objects:/data"
    ];
  };


  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/secret/local-nix-secret-key";
  };


  # networking.firewall.enable = false;
  networking.firewall.logReversePathDrops = true;
  # networking.firewall.logRefusedPackets = true;
  # networking.firewall.logRefusedUnicastsOnly = true;

  networking.firewall.checkReversePath = false; # even loose breaks kube-dns responses

  networking.firewall.allowedTCPPorts = [
    22
    80
    443

    config.services.nix-serve.port

    9000 #minio
    9001 #minio

    3005 # plex
    8324 # plex
    32400 # plex
    32469 # plex
  ];
  networking.firewall.allowedUDPPorts = [
    1900 # upnp / ssdp (plex)
    5353 # mdns (plex)

    32410 # plex
    32412 # plex
    32413 # plex
    32414 # plex
  ];
}

