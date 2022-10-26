{ pkgs, lib, config, ... }:
let
  cfg = config.services.pixiecore-host-configs;

  optsToJson = opts: builtins.toJSON {
    kernel = "file://${opts.nixosSystem.config.system.build.kernel}/kernel";
    initrd = [ "file://${opts.nixosSystem.config.system.build.netbootRamdisk}/initrd" ];
    cmdline = builtins.concatStringsSep " " ([ "init=${opts.nixosSystem.config.system.build.toplevel}/init" ] ++ opts.kernelParams);
    # cmdline = "cloud-config-url={{ URL \"https://files.local/cloud-config\" }} non-proxied-url=https://files.local/something-else";
  };
  echoJsonCommands = lib.attrsets.mapAttrsToList (mac: opts: "echo '${optsToJson opts}' > $targetdir/${mac}") cfg.hosts;
  content = pkgs.runCommandLocal "pixiecore-host-configs" { } ''
    targetdir=$out/v1/boot
    mkdir -p $targetdir
    ${lib.strings.concatStringsSep "\n" echoJsonCommands}
  '';
in
{
  options.services.pixiecore-host-configs = {
    enable = lib.mkEnableOption "pixiecore-host-configs";
    hosts = lib.mkOption {
      type = with lib.types; attrsOf (submodule {
        options = {
          nixosSystem = lib.mkOption { type = attrs; };
          kernelParams = lib.mkOption { type = listOf str; default = [ ]; };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      configFile = pkgs.writeText "Caddyfile" ''
        http://pixie-host-configs.localhost:8080 {
          root * ${content}
          file_server
        }
      '';
    };
  };

}
