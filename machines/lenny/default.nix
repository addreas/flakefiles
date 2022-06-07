{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  defaultUser = "addem";
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
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  system.stateVersion = "22.05";

  networking.hostName = "LAPTOP-EK7DRJB8";

  nix.package = pkgs.nixFlakes; # or versioned attributes like nix_2_7
  nix.extraOptions = ''
    experimental-features = nix-command flakes

    extra-sandbox-paths = /nix/var/cache/ccache
  '';

  programs.ccache.enable = true;
  programs.ccache.cacheDir = "/nix/var/cache/ccache";
  nix.sandboxPaths = [ (toString config.programs.ccache.cacheDir) ];

  wsl = {
    enable = true;
    automountPath = "/mnt";
    inherit defaultUser;
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  users.users.${defaultUser} = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "nixbld" ];
  };

  environment.systemPackages = with pkgs; [
    fzf-zsh
    zshFastHighlight
  ];

  services.pcp.enable = true;
  services.cockpit.enable = true;
  services.cockpit.extraPackages = [ config.services.pcp.package ];

  # systemd.services.cockpit.enable = true;
  # systemd.services.pmcd.enable = true;
  # systemd.services.pmlogger.enable = true;


  # virtualisation.podman.enable = true;
  # virtualisation.libvirtd.enable = true;

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
