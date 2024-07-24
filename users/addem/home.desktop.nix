{ pkgs, lib, flakepkgs, ... }:
{
  imports = [
    ./home.nix
    ./home.dev.nix
    ./kanshi.nix
    ./mako.nix
    ./alacritty.nix
    ./wezterm.nix
    ./swayidle.nix
    ./swaylock.nix
    ./sway.nix
    ./ulauncher.nix
    ./variety.nix
    ./vscode.nix
    ./waybar.nix
  ];

  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";

    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    WLR_DRM_NO_MODIFIERS = "1";
    # NIXOS_OZONE_WL = "1"; # vscode hates this
  };

  fonts.fontconfig.enable = true;

  services.cliphist.enable = true;

  services.batsignal.enable = true; # todo: auto suspend
  services.batsignal.extraArgs = [
    "-c10" # critical level
    "-CCritical battery level. Suspending at 5%" # critical message
    "-d5" # danger level
    "-D${pkgs.systemd}/bin/systemctl suspend" # danger command
  ];
  # services.poweralertd.enable = true;
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;

  home.packages = [ pkgs.gcr ];
}
