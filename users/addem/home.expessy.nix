{
  desktop.sway.enable = false;

  imports = [
    ./base.nix

    ./dev/git.nix
    ./dev/languages.nix
    ./dev/tools.nix

    ./desktop/alacritty.nix
    ./desktop/packages.nix
    ./desktop/env.nix
    ./desktop/kanshi.nix
    ./desktop/niri.nix
    ./desktop/dms.nix
    ./desktop/plain.nix
    ./desktop/services.nix
    ./desktop/sway.nix
    ./desktop/swaylock.nix
    ./desktop/theming.nix
    ./desktop/variety.nix
    ./desktop/wallpapers.nix
  ];
}
