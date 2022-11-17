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

    extraPackages = with pkgs; [
      waybar
      swaylock-effects
      swaybg
      swayidle
      sway-contrib.grimshot

      qt5.qtwayland
    ];
  };

  programs.xwayland.enable = true;

  xdg.portal.wlr.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  services.pipewire.enable = true;
  services.pipewire.wireplumber.enable = true;
  services.pipewire.pulse.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.hardware.bolt.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
    chromium
    kitty
    wl-clipboard
    nautilus
    evince
    file-roller
    wireshark
    ulauncher
    wdisplays
    swappy
    pavucontrol
    brightnessctl
    usbutils
  ];
}

