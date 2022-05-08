{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.pcp;
  pcp = cfg.package;
in
{
  options.services.pcp.enable = mkEnableOption "performance copilot";
  options.services.pcp.package = mkOption {
    type = types.package;
    default = pkgs.callPackage ./default.nix { };
  };

  config = mkIf cfg.enable {
    systemd.packages = [ pcp ];

    environment.etc."pcp.env".source = "${pcp}/etc/pcp.env";
    environment.etc."pcp.conf".source = "${pcp}/etc/pcp.conf";

    environment.systemPackages = [ pcp ];
  };
}
