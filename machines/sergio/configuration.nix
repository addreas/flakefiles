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

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./sergio-fs.nix
    ];
  swapDevices = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  services.snapper.snapshotRootOnBoot = true;
  system.autoUpgrade.enable = true;

  networking.hostName = "sergio"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  systemd.network.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  services.xserver.layout = "gb";

  fonts.enableDefaultFonts = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.addem = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo3m9mk9k2s9agfYQQ9pn3qyjCEd+ArYsn8mcUtxTxFbk9HnXFqdyyawnTr/GHfo77rNnjNOSlhjIEEJnm8+NkZ0OPPlkOTKZoievFhxRyXHdgWW277Lb7LczeYtv0CGUJzAs2WUOeKUShA1jalDJPUVjNG92HbQdCvHJX20Tl/e7TdIIlNadYVo4QZi0I9viIYDYCPTxzQPW3hHaEnCgcBd5Ra6wWyxjRYmZwganTNQ6Qx3LM0y9qUZkyO8pNk0JkqpZ6X9+dJzt2iDQX1OT/lD3RmD1ybHgmg5+e3T8/tsDqkB3Bq5Gs41gluZIGrAVEuX8B665ihegLBtIP6Gkv addem1234@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPZtM7nXSugwZIc3RUd0A/mC5uLX+25CwB15lAKvXEgy andreas@yanzi.network"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4ASGDaGjOmmbjIHxQbVwRrd+oBwFp/R+4nxcR8EtP0 andreas@addem.se"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    btrfs-progs
    podman
    vim
    helix
    wget
    curl
    fzf
    jq
    dig
  ];

  programs.zsh.ohMyZsh = {
    enable = true;
    theme = "arrow";
    plugins = [
      "git"
      "command-not-found"
      "colored-man-pages"
      "fzf"
      "fast-syntax-highlighting"
    ];
  };

  services.openssh.enable = true;
  services.locate.enable = true;
  services.locate.locate = pkgs.plocate;
  services.locate.localuser = null;

  services.kmscon.enable = true;

  #services.kubernetes.kubelet.enable = true;
  #services.kubernetes.kubelet.manifests = {};
  #virtualisation.cri-o.enable = true;
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
    extraOptions = [
      "--network=host"
    ];
  };

  services.rpcbind.enable = true;
  services.nfs.server.enable = true;
  services.nfs.server.statdPort = 4000;
  services.nfs.server.lockdPort = 4001;
  services.nfs.server.mountdPort = 4002;
  services.nfs.server.exports = ''
    /export/pictures *(rw,async,insecure)
    /export/backups *(rw,no_root_squash,async,insecure)
    /export/longhorn-backup *(rw,no_root_squash,async,insecure)
    /export/videos *(rw,async,insecure)
  '';

  services.samba.enable = true;
  services.samba-wsdd.enable = true;
  services.samba.openFirewall = true;
  services.samba.extraConfig = ''
    unix password sync = yes
  '';

  services.samba.shares =
    let
      simpleShare = path: {
        path = path;
        "read only" = false;
        browseable = "yes";
        "guest ok" = "no";
        "admin users" = "addem jonas";
      };
    in
    {
      videos = simpleShare "/mnt/videos";
      pictures = simpleShare "/mnt/pictures";
      backups = simpleShare "/mnt/backups";
    };

  services.netatalk.enable = true;
  services.netatalk.settings =
    let
      simpleShare = path: {
        path = path;
        "time machine" = "no";
      };
    in
    {
      videos = simpleShare "/mnt/videos";
      pictures = simpleShare "/mnt/pictures";
      backups = simpleShare "/mnt/backups" // {
        "time machine" = "yes";
      };
    };

  services.smartd.enable = true;
  services.smartd.notifications.mail.enable = true;
  services.prometheus.exporters.smartctl.enable = true;

  services.btrfs.autoScrub.enable = true;

  services.apcupsd.enable = true;
  services.prometheus.exporters.apcupsd.enable = true;

  # power.ups.enable = true;
  # power.ups.mode = "netserver";
  # power.ups.ups.ups = {
  #   port = "auto";
  #   driver = "usbhid-ups";
  # };

  networking.firewall.allowedTCPPorts = [
    22
    80
    443

    111 # rpcbind
    139 # smbd // covered by module?
    445 # smbd // covered by module?

    548 # netatalk afpd
    5357 # services.samba-wsdd

    2049 # nfs
    4000 # nfs statd
    4001 # nfs lockd
    4002 # nfs mountd

    3005 # plex
    8324 # plex
    32400 # plex
    32469 # plex
  ];
  networking.firewall.allowedUDPPorts = [
    1900 # upnp / ssdp (plex)
    3702 # services.samba-wsdd // covered bymodule?
    5353 # mdns (plex)

    32410 # plex
    32412 # plex
    32413 # plex
    32414 # plex
  ];

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
  # nixpkgs.config.packageOverrides = pkgs:
  #   { 
  #     nut = pkgs.nut.overrideAttrs (oldAttrs: {
  #         makeFlags = [ "CPPFLAGS=-std=c++14"];
  #       });
  #   };
}

