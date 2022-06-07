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
    users.groups.pcp = { };
    users.users.pcp = {
      isSystemUser = true;
      group = "pcp";
      home = "/var/lib/pcp";
      description = "Performance Co-Pilot";
    };

    systemd.packages = [ pcp ];
    # systemd.tmpfiles.packages = [ pcp ];

    environment.etc."pcp.env".source = "${pcp}/etc/pcp.env";
    environment.etc."pcp.conf".source = "${pcp}/etc/pcp.conf";

    environment.systemPackages = [ pcp ];
  };
}
