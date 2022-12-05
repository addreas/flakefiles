{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.variety ];

  systemd.user.services.variety = {
    Unit = { Description = "Variety"; };
    Service = {
      Environment = ["PATH=${lib.strings.makeBinPath [
        pkgs.bash
        "/run/current-system/sw"
      ]}"];
      ExecStart = "${pkgs.variety}/bin/variety";
    };
    Install = { WantedBy = ["graphical-session.target"]; };
  };

}
