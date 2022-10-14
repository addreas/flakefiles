{ config, pkgs, lib, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";

  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  services.xserver.layout = "gb";

  fonts.enableDefaultFonts = true;

  services.openssh.enable = true;
  services.kmscon.enable = true;
  services.locate.enable = true;
  services.locate.locate = pkgs.plocate;
  services.locate.localuser = null;
  services.avahi.enable = true;

  virtualisation.podman.enable = true;

  environment.systemPackages = with pkgs; [
    btrfs-progs
    podman
    vim
    wget
    curl
    git
    cntr
  ];
}

