{
  imports = [
    ./kube.nix

    ../common/base.nix
    ../common/services.nix
  ];
  swapDevices = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = false;

  system.stateVersion = "22.11";

  system.autoUpgrade = {
    enable = true;
    flake = "/home/addem/flakefiles";
    # flags = [ "--update-input" "nixpkgs" ];
    operation = "boot";
  };

  networking.domain = "localdomain";

  systemd.network.enable = true;
  systemd.network.networks.lan.name = "en*";
  systemd.network.networks.lan.DHCP = "yes";
  networking.dhcpcd.enable = false;
  systemd.network.wait-online.anyInterface = true;
  services.resolved.dnssec = "false"; # dnssec fails for localdomain and breaks stuff

  security.sudo.wheelNeedsPassword = false;
}
