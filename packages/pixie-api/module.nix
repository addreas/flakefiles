{ pkgs, lib, config, ... }:
let
  cfg = config.services.pixiecore-host-configs;

  mkPixiecoreConfig = host: builtins.toJSON {
    kernel = "file://${host.nixosSystem.config.system.build.kernel}/kernel";
    initrd = [ "file://${host.nixosSystem.config.system.build.netbootRamdisk}/initrd" ];
    # pixiecore appends initrd kernel args
    cmdline = builtins.concatStringsSep " " ([ "init=${host.nixosSystem.config.system.build.toplevel}/init" ] ++ host.kernelParams);
    # cmdline = "
    #   cloud-config-url={{ URL \"https://files.local/cloud-config\" }}
    #   non-proxied-url=https://files.local/something-else
    # ";
  };

  echo-json-to-dir = lib.attrsets.mapAttrsToList (mac: host: "echo '${mkPixiecoreConfig host}' > ${mac}") cfg.hosts;
  config-directory = pkgs.runCommandLocal "pixiecore-host-configs" { } ''
    targetdir=$out/v1/boot
    mkdir -p $targetdir
    cd $targetdir
    ${lib.strings.concatStringsSep "\n" echo-json-to-dir}
  '';
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

    systemd.services.pixiecore-host-configs = {
      description = "Pixiecore API mode responder";
      wantedBy = [ "pixiecore.service" ];

      serviceConfig = {
        Restart = "always";
        RestartSec = 10;

        ExecStart = ''
          ${pkgs.python310}/bin/python \
            -m http.server \
            --directory ${config-directory} \
            ${builtins.toString cfg.port}
        '';
      };
    };
  };

}
