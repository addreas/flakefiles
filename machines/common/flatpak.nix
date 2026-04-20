{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [ flatpak ];
  services.flatpak.enable = true;
  services.flatpak.packages = [
    # { appId = "com.brave.Browser"; origin = "flathub";  }
    # "com.obsproject.Studio"
    # "im.riot.Riot"
    "com.orcaslicer.OrcaSlicer"
  ];
}

