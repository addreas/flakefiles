{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  defaultUser = "addem";
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    ../../users/addem.nix
    ../common/base.nix
  ];

  system.stateVersion = "22.05";
  networking.hostName = "LAPTOP-EK7DRJB8";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings = {
    extra-platforms = ["aarch64-linux" "arm-linux" ];
    system-features = ["big-parallel"];
  };

  documentation.enable = true;
  documentation.doc.enable = true;
  documentation.info.enable = true;
  documentation.man.enable = true;
  documentation.nixos.enable = true;

  programs.ccache.enable = true;
  programs.ccache.cacheDir = "/nix/var/cache/ccache";
  nix.settings.extra-sandbox-paths = [ (toString config.programs.ccache.cacheDir) ];

  wsl = {
    enable = true;
    inherit defaultUser;
    nativeSystemd  = true;
    startMenuLaunchers = false;
    interop.register = true;
  };

  systemd.services.systemd-tmpfiles-setup-dev.enable = false;
  systemd.services.systemd-tmpfiles-setup.enable = false;
  systemd.services.systemd-sysctl.enable = false;

  virtualisation.podman.enable = true;

  services.vscode-server = {
    enable = true;
    enableFHS = true;
  };
}
