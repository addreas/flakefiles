{ pkgs, lib, ... }:
{
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  imports = [
    ./zsh.nix
    ./sway.nix
  ];

  home.packages = with pkgs; [
    variety
    ulauncher
  ];

  systemd.user.services.ulauncher = {
    Unit = {
      Description = "Linux Application Launcher";
      Documentation = "https://ulauncher.io/";
    };
    Service = {
      Path = "/run/wrappers/bin:/home/addem/.nix-profile/bin:/etc/profiles/per-user/addem/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
      # Path = lib.strings.makeBinPath [
      #   "/run/wrappers"
      #   "/home/addem/.nix-profile"
      #   "/etc/profiles/per-user/addem"
      #   "/nix/var/nix/profiles/default"
      #   "/run/current-system/sw"
      # ];
      ExecStart = "${pkgs.ulauncher}/bin/ulauncher --hide-window";
    };
    Install = { WantedBy = ["graphical-session.target"]; };
  };

  systemd.user.services.variety = {
    Unit = { Description = "Variety"; };
    Service = {
      Path = lib.strings.makeBinPath [pkgs.bash];
      ExecStart = "${pkgs.variety}/bin/variety";
    };
    Install = { WantedBy = ["graphical-session.target"]; };
  };

  # services.kdeconnect.enable = true;
}
