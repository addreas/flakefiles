{ pkgs, lib, config, ... }:
let
  cfg = config.services.pixiecore-host-configs;

  api-ts = pkgs.writeText "api.ts" (builtins.readFile ./api.ts);

  host-configs = pkgs.writeText "host-configs.json" (builtins.toJSON (lib.attrsets.mapAttrs mkPixiecoreConfig cfg.hosts));

  mkPixiecoreConfig = mac: host: {
    kernel = "file://${host.nixosSystem.config.system.build.kernel}/kernel";
    initrd = [ "file://${host.nixosSystem.config.system.build.netbootRamdisk}/initrd" ];
      # pixiecore appends initrd kernel args
    cmdline = builtins.concatStringsSep " " (builtins.concatLists [
          [
            "init=${host.nixosSystem.config.system.build.toplevel}/init"
            "pixie-logger={{ URL \"/v1/log-dump\" }}"
          ]
          host.kernelParams
        ]);
  };
in
{
  options.services.pixiecore-host-configs = {
    enable = lib.mkEnableOption "pixiecore-host-configs";
    port = lib.mkOption {
      default = 9813;
      type = lib.types.int;
    };
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
    services.pixiecore = {
      enable = true;
      mode = "api";
      apiServer = "http://localhost:${builtins.toString cfg.port}";
      openFirewall = true;
      dhcpNoBind = true;
    };

    networking.firewall.allowedTCPPorts = [cfg.port];

    systemd.services.pixiecore-host-configs = {
      description = "Pixiecore API mode responder";
      wantedBy = [ "pixiecore.service" ];

      serviceConfig = {
        Restart = "always";
        RestartSec = 10;

        ExecStart = lib.strings.concatStringsSep " " [
          "${pkgs.deno}/bin/deno"
          "run"
          "--log-level=debug"
          "--allow-net"
          "--allow-read=${host-configs}"
          "${api-ts}"
          "--port=${builtins.toString cfg.port}"
          "--configs=${host-configs}"
        ];
      };
    };
  };

}
