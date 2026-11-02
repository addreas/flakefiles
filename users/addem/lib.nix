{ config, lib }:
rec {
  sessionPath = [
    "${config.home.homeDirectory}/.nix-profile"
    "/etc/profiles/per-user/${config.home.username}"
    "${config.xdg.stateHome}/nix/profile"
    "/run/current-system/sw"
  ];

  pathEnvironment = "PATH=${lib.makeBinPath sessionPath}";
}
