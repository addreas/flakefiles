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

  # services.ulauncher.enable = true;
  # services.kanshi.enable = true;
  # services.swayidle.enable = true;
  # services.variety.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    swaylock-effects
    swaybg
    swayidle
    sway-contrib.grimshot
    mako
    qt5.qtwayland
    wayland
    glib

    firefox
    chromium
    kitty
    wl-clipboard
    gnome.nautilus
    gnome.file-roller
    gnome.sushi
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

  fonts.fonts = with pkgs; [
    dejavu_fonts
    font-awesome
  ];
}

