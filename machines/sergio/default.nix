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
  nixpkgs.overlays = [
    (self: super: {
      kubernetes = super.kubernetes.overrideAttrs
        (oldAttrs: rec {
          version = "1.24.5";
          src = pkgs.fetchFromGitHub {
            owner = "kubernetes";
            repo = "kubernetes";
            rev = "v${version}";
            sha256 = "sha256-8fEn2ac6bzqRtDbMzs7ZuUKfaLaJZuPoLQ3LZ/lnmTo=";
          };

        });
    })
  ];

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nas.nix
    ./monitoring.nix
    ./kube.nix
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";

  # requires manual `sudo btrfs subvolume create /.snapshots`
  services.snapper.snapshotRootOnBoot = true;
  services.snapper.configs.root.subvolume = "/";

  time.timeZone = "Europe/Stockholm";

  networking.hostName = "sergio";
  networking.domain = "localdomain";

  systemd.network.enable = true;
  systemd.network.networks.lan.name = "en*";
  systemd.network.networks.lan.dns = [ "192.168.1.1" ];

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
    git
    cntr
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
  services.kmscon.enable = true;
  services.locate.enable = true;
  services.locate.locate = pkgs.plocate;
  services.locate.localuser = null;
  services.avahi.enable = true;
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


  networking.firewall.checkReversePath = "loose";

  networking.firewall.allowedTCPPorts = [
    22
    80
    443

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

