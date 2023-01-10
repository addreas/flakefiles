{
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

  networking.domain = "localdomain";

  systemd.network.enable = true;
  systemd.network.networks.lan.name = "en*";
  systemd.network.networks.lan.DHCP = "yes";
  services.resolved.dnssec = "false"; # dnssec fails for localdomain and breaks stuff

  security.sudo.wheelNeedsPassword = false;
}
