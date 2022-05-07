{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.pcp;
  pcp = pkgs.pcp;
in
{
  options.services.pcp.enable = mkEnableOption "performance copilot";

  config = mkIf cfg.enable {
    systemd.packages = [ pcp ];

    environment.etc."pcp.env".source = "${pcp}/etc/pcp.env";
    environment.etc."pcp.conf".source = "${pcp}/etc/pcp.conf";

    environment.systemPackages = [ pcp ];
  };
}
