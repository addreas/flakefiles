{ config, pkgs, lib, modulesPath, ... }:

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
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
    ./hardware-config.nix
    ./kube.nix
  ];
  # boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  # boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";

  # requires manual `sudo btrfs subvolume create /.snapshots`
  services.snapper.snapshotRootOnBoot = true;
  services.snapper.configs.root.subvolume = "@";

  time.timeZone = "Europe/Stockholm";

  networking.hostName = "pixie-trixie";
  networking.domain = "localdomain";

  systemd.network.enable = true;
  systemd.network.networks.lan.name = "enp4s0";
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

  networking.firewall.checkReversePath = "loose";

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPorts = [ 1900 5353 ];
}

