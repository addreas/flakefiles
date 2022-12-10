{ pkgs, lib, ... }:
let
  ulauncher = pkgs.ulauncher.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      pkgs.python3Packages.pytz
    ];
  });
in
{
  home.packages = [ ulauncher ];

  systemd.user.services.ulauncher = {
    Unit = {
      Description = "Linux Application Launcher";
      Documentation = "https://ulauncher.io/";
    };
    Service = {
      Environment = [ "PATH=${lib.strings.makeBinPath [ "$HOME/.nix-profile" "/run/current-system/sw" ]}" ];
      ExecStart = "${ulauncher}/bin/ulauncher --hide-window";
    };
    Install = { WantedBy = ["graphical-session.target"]; };
  };

}
