{ config, ... }:
{
  imports = [
    ./base.nix

    ./dev/embedded.nix
    ./dev/git.nix
    ./dev/languages.nix
    ./dev/make.nix
    ./dev/tools.nix

    ./desktop/alacritty.nix
    ./desktop/packages.nix
    ./desktop/env.nix
    ./desktop/kanshi.nix
    ./desktop/services.nix
    ./desktop/sway.nix
    ./desktop/plain.nix
    ./desktop/swaylock.nix
    ./desktop/theming.nix
    ./desktop/variety.nix
    ./desktop/wezterm.nix
    ./desktop/zed.nix
  ];

  xdg.systemDirs.data = [
    "/var/lib/flatpak/exports/share"
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
  ];
}
