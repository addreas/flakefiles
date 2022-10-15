{ config, pkgs, lib, ... }:
{
  nix.package = pkgs.nixVersions.stable;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc.automatic = true;
  nix.gc.dates = "weekly";

  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  services.xserver.layout = "gb";

  fonts.enableDefaultFonts = true;

  environment.systemPackages = with pkgs; [
    zsh
    vim
    wget
    curl
    git
    cntr
  ];
  
  users.defaultUserShell = pkgs.zsh;
}

