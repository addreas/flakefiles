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

  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.hardware.bolt.enable = true;

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    hack-font
    roboto
    (nerdfonts.override { fonts = [ "Hack" ]; })
    noto-fonts
    noto-fonts-extra
    noto-fonts-emoji
    noto-fonts-emoji-blob-bin
    liberation_ttf
  ];

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    sway
    swaybg
    sway-contrib.grimshot
    swappy
    mako
    qt5.qtwayland
    wayland
    glib
    xdg-utils

    firefox-bin
    # chromium
    wl-clipboard
    nautilus
    nfs-utils
    cifs-utils
    file-roller
    sushi
    adwaita-icon-theme
    evince
    wireshark
    wdisplays
    pavucontrol


    usbutils
    pciutils
    util-linux
    man-pages
  ];

  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
  };
}

