{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.ulauncher ];

  systemd.user.services.ulauncher = {
    Unit = {
      Description = "Linux Application Launcher";
      Documentation = "https://ulauncher.io/";
    };
    Service = {
      Environment = ["PATH=${lib.strings.makeBinPath [
        "/run/wrappers"
        "/home/addem/.nix-profile"
        "/etc/profiles/per-user/addem"
        "/nix/var/nix/profiles/default"
        "/run/current-system/sw"
      ]}"];
      ExecStart = "${pkgs.ulauncher}/bin/ulauncher --hide-window";
    };
    Install = { WantedBy = ["graphical-session.target"]; };
  };

}
