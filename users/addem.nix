{ lib, pkgs, config, modulesPath, ... }:
with lib;
let
  zshFastHighlight = (pkgs.zsh-fast-syntax-highlighting.overrideAttrs (_: {
    installPhase = ''
      plugindir="$out/share/zsh/plugins/fast-syntax-highlighting"
      mkdir -p "$plugindir"
      cp -r -- {,_,-,.}fast-* *chroma themes "$plugindir"/
    '';
  })
  );
in
{
  users.users.addem = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "nixbld" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo3m9mk9k2s9agfYQQ9pn3qyjCEd+ArYsn8mcUtxTxFbk9HnXFqdyyawnTr/GHfo77rNnjNOSlhjIEEJnm8+NkZ0OPPlkOTKZoievFhxRyXHdgWW277Lb7LczeYtv0CGUJzAs2WUOeKUShA1jalDJPUVjNG92HbQdCvHJX20Tl/e7TdIIlNadYVo4QZi0I9viIYDYCPTxzQPW3hHaEnCgcBd5Ra6wWyxjRYmZwganTNQ6Qx3LM0y9qUZkyO8pNk0JkqpZ6X9+dJzt2iDQX1OT/lD3RmD1ybHgmg5+e3T8/tsDqkB3Bq5Gs41gluZIGrAVEuX8B665ihegLBtIP6Gkv addem1234@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4ASGDaGjOmmbjIHxQbVwRrd+oBwFp/R+4nxcR8EtP0 andreas@addem.se"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    helix
    wget
    curl
    fzf
    jq
    dig
    git
    fzf-zsh
    zshFastHighlight
  ];

  programs.zsh.enable = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.theme = "arrow";
  programs.zsh.ohMyZsh.customPkgs = [ zshFastHighlight ];
  programs.zsh.ohMyZsh.plugins = [
    "git"
    "command-not-found"
    "colored-man-pages"
    "fzf"
  ];
}
