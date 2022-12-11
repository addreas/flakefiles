{ ... }:
{
  services.smartd.enable = true;
  services.smartd.notifications.mail.enable = true;
  services.prometheus.exporters.smartctl.enable = true;
  services.prometheus.exporters.smartctl.openFirewall = true;
  systemd.services."prometheus-smartctl-exporter".serviceConfig.DeviceAllow =
    [ "block-blkext rw" "block-sd rw" "char-nvme rw" ];

  power.ups.enable = true;
  power.ups.mode = "netserver";
  power.ups.ups.ups = {
    port = "auto";
    driver = "usbhid-ups";
  };

  environment.etc = {
    "nut/upsd.conf".text = "LISTEN 0.0.0.0";
    "nut/upsd.users".text = ''
      [monuser]
      upsmon master
      password = "monuser"
    '';
    "nut/upsmon.conf".text = ''
      MONITOR ups@localhost 1 monuser "monuser" master
    '';
  };

  system.activationScripts.var-lib-nut = "mkdir -p /var/lib/nut; chmod o-r /var/lib/nut";

  #services.apcupsd.enable = true;
  #services.prometheus.exporters.apcupsd.enable = true;
  # power.ups.ups.ups = {
  #   port = "localhost";
  #   driver = "apcupsd-ups";
  # };

  services.prometheus.exporters.node.enable = true;
  services.prometheus.exporters.node.openFirewall = true;


  networking.firewall.allowedTCPPorts = [
    3493 # nut/upsd
    3100 # loki
  ];

  services.loki.enable = true;
  services.loki.config = {
    auth_enabled = false;

    server.http_listen_port = 3100;

    ingester = {
      lifecycler = {
        address = "0.0.0.0";
        ring.kvstore.store = "inmemory";
        ring.replication_factor = 1;
        final_sleep = "0s";
      };
      chunk_idle_period = "5m";
      chunk_retain_period = "30s";
    };

    schema_config.configs = [{
        from = "2020-05-15";
        store = "boltdb";
        object_store = "filesystem";
        schema = "v11";
        index.prefix = "index_";
        index.period = "168h";
    }];

    storage_config = {
      boltdb.directory = "/tmp/loki/index";
      filesystem.directory = "/tmp/loki/chunks";
    }

    limits_config = {
      enforce_metric_name = false;
      reject_old_samples = true;
      reject_old_samples_max_age = "168h";
    };
  };
}
