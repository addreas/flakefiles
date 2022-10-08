{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
     (modulesPath + "/installer/scan/not-detected.nix")
     (modulesPath + "/installer/netboot/netboot-minimal.nix")
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  services.xserver.layout = "gb";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.addem = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo3m9mk9k2s9agfYQQ9pn3qyjCEd+ArYsn8mcUtxTxFbk9HnXFqdyyawnTr/GHfo77rNnjNOSlhjIEEJnm8+NkZ0OPPlkOTKZoievFhxRyXHdgWW277Lb7LczeYtv0CGUJzAs2WUOeKUShA1jalDJPUVjNG92HbQdCvHJX20Tl/e7TdIIlNadYVo4QZi0I9viIYDYCPTxzQPW3hHaEnCgcBd5Ra6wWyxjRYmZwganTNQ6Qx3LM0y9qUZkyO8pNk0JkqpZ6X9+dJzt2iDQX1OT/lD3RmD1ybHgmg5+e3T8/tsDqkB3Bq5Gs41gluZIGrAVEuX8B665ihegLBtIP6Gkv addem1234@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4ASGDaGjOmmbjIHxQbVwRrd+oBwFp/R+4nxcR8EtP0 andreas@addem.se"
    ];
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    vim
    helix
    wget
    curl
    fzf
    jq
    dig
    git
  ];

  services.openssh.enable = true;
  services.kmscon.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ 1900 5353 ];
}

