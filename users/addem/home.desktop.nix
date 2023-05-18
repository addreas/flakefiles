{ pkgs, lib, ... }:
{
  imports = [
    ./home.nix
    ./home.dev.nix
    ./kanshi.nix
    ./mako.nix
    ./kitty.nix
    ./swayidle.nix
    ./swaylock.nix
    ./sway.nix
    ./ulauncher.nix
    ./variety.nix
    ./waybar.nix
  ];

  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";

    gtk.enable = true;
    x11.enable = true;
  };

  # home.extraOutputsToInstall = ["share"];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    WLR_DRM_NO_MODIFIERS = "1";
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      arcticicestudio.nord-visual-studio-code
      # brian-anders.sublime-duplicate-text
      # Cardinal90.multi-cursor-case-preserve
      denoland.vscode-deno
      esbenp.prettier-vscode
      firefox-devtools.vscode-firefox-debug
      golang.go
      # jallen7usa.vscode-cue-fmt
      jnoortheen.nix-ide
      matklad.rust-analyzer
      # maximus136.change-string-case
      # ms-python.isort
      ms-python.python
      ms-python.vscode-pylance
      ms-vscode.cpptools
      ms-vscode.makefile-tools
      # nico-castell.linux-desktop-file
      redhat.vscode-yaml
      tomoki1207.pdf
      # xoronic.pestfile
    ];
  };

  services.batsignal.enable = true; # todo: auto suspend
  # services.poweralertd.enable = true;
  services.gnome-keyring.enable = true;
  services.network-manager-applet.enable  = true;
}
