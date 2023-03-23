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

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "22.05";

  networking.hostName = "LAPTOP-EK7DRJB8";

  nix.settings = {
    extra-platforms = ["aarch64-linux" "arm-linux" ];
    system-features = ["big-parallel"];
  };



  programs.ccache.enable = true;
  programs.ccache.cacheDir = "/nix/var/cache/ccache";
  nix.settings.extra-sandbox-paths = [ (toString config.programs.ccache.cacheDir) ];

  wsl = {
    enable = true;
    inherit defaultUser;
    nativeSystemd  = true;
    startMenuLaunchers = false;
    interop.register = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;
  };

  systemd.services.systemd-tmpfiles-setup-dev.enable = false;
  systemd.services.systemd-tmpfiles-setup.enable = false;
  systemd.services.systemd-sysctl.enable = false;

  # virtualisation.podman.enable = true;
}
