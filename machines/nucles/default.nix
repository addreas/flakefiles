{}: {
  imports = [
    ./kube.nix

    ../../users/addem.nix
    ../../packages/basic/common.nix
    ../../packages/basic/services.nix
  ];
  swapDevices = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = false;

  system.stateVersion = "22.11";

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

  networking.domain = "localdomain";

  systemd.network.enable = true;
  systemd.network.networks.lan.name = "en*";
  systemd.network.networks.lan.DHCP = true;
  # systemd.network.networks.lan.dns = [ "192.168.1.1" ];
  systemd.network.wait-online.anyInterface = true;
}
