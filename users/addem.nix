{ lib, pkgs, config, modulesPath, ... }:
{
  users.users.addem = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "wireshark" ];
    passwordFile = "/etc/shadow.d/addem";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo3m9mk9k2s9agfYQQ9pn3qyjCEd+ArYsn8mcUtxTxFbk9HnXFqdyyawnTr/GHfo77rNnjNOSlhjIEEJnm8+NkZ0OPPlkOTKZoievFhxRyXHdgWW277Lb7LczeYtv0CGUJzAs2WUOeKUShA1jalDJPUVjNG92HbQdCvHJX20Tl/e7TdIIlNadYVo4QZi0I9viIYDYCPTxzQPW3hHaEnCgcBd5Ra6wWyxjRYmZwganTNQ6Qx3LM0y9qUZkyO8pNk0JkqpZ6X9+dJzt2iDQX1OT/lD3RmD1ybHgmg5+e3T8/tsDqkB3Bq5Gs41gluZIGrAVEuX8B665ihegLBtIP6Gkv addem1234@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4ASGDaGjOmmbjIHxQbVwRrd+oBwFp/R+4nxcR8EtP0 andreas@addem.se"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9Vo7cki3sDDlWWyNi59wTFRa9rzkVf38cY/r86v5yj addem@nixos"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    helix
    wget
    curl
    fzf
    jq
    yq
    dig
    git
    rlwrap
    git-lfs

    home-manager
  ];

  programs.zsh.enable = true;

  programs.wireshark.enable = true;
}
