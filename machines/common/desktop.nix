{ config, pkgs, lib, ... }:
{
  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';

    wrapperFeatures.base = true;
    wrapperFeatures.gtk = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };


  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  services.dbus.enable = true;

  sound.enable = true;
  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.hardware.bolt.enable = true;

  fonts.enableDefaultFonts = true;
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" ]; })
    noto-fonts
    noto-fonts-extra
    noto-fonts-emoji
    noto-fonts-emoji-blob-bin
    roboto
    font-awesome
    liberation_ttf
  ];

  environment.systemPackages = with pkgs; [
    waybar
    sway
    swaylock-effects
    swaybg
    swayidle
    sway-contrib.grimshot
    mako
    qt5.qtwayland
    wayland
    glib
    xdg-utils

    firefox-bin
    # chromium
    kitty
    wl-clipboard
    gnome.nautilus
    gnome.file-roller
    gnome.sushi
    gnome.adwaita-icon-theme
    evince
    wireshark
    ulauncher
    wdisplays
    swappy
    pavucontrol
    brightnessctl

    usbutils
    pciutils
    util-linux
  ];
}

