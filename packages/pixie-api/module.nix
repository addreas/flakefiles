{ pkgs, lib, config, ... }:
let
  cfg = config.services.pixiecore-host-configs;
  content = pkgs.runCommandLocal "pixiecore-host-configs"
    {
      hosts = builtins.mapAttrs
        (mac: package: builtins.toJson
          {
            kernel = "file://${package}/kernel";
            initrd = [ "file://${package}/initrd" ];
            cmdline = "cloud-config-url={{ URL \"https://files.local/cloud-config\" }} non-proxied-url=https://files.local/something-else";
          })
        cfg.hosts;
    } ''
    BOOT=$out/v1/boot
    mkdir -p $BOOT

  '';
in
{
  options.services.pixiecore-host-configs = {
    enable = lib.mkEnableOption "pixiecore-host-configs";
    hosts = lib.mkOption {
      type = with lib.types; attrsOf (submodule {
        options = {
          hostname = mkOption { type = str; };
          kernel = mkOption { type = package; };
          initrd = mkOption { type = package; };
          cmdline = mkOption { type = nullOr str; };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy =
      {
        enable = true;
        configFile = ''
          http://pixie-host-configs.localhost:8080
          {
            root * ${content}
            file_server
          }
        '';
      };
  };

}
