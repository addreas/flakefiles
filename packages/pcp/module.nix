{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.pcp;
  pcp = pkgs.callPackage ./default.nix { };
in
{
  options.services.pcp.enable = mkEnableOption "performance copilot";

  config = mkIf cfg.enable {
    systemd.packages = with  pkgs; [ pcp ];

    environment.etc."pcp.env".source = "${pcp}/etc/pcp.env";
    environment.etc."pcp.conf".source = "${pcp}/etc/pcp.conf";

    environment.systemPackages = with pkgs; [ pcp ];
  };
}
