{ config, pkgs, lib, modulesPath, ... }:
let
  nukeAndInstall = pkgs.writeShellApplication
    {
      name = "nuke-nvme0n1-and-install";
      runtimeInputs = [ pkgs.parted ];
      text = builtins.readFile ./nuke.sh;
    };
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/installer/netboot/netboot-minimal.nix")

    ../../packages/basic/common.nix
    ../../packages/basic/services.nix
  ];

  system.stateVersion = "22.11";

  networking.hostName = ""; # these have ot be set via kernel cmdline

  system.activationScripts.cmdline-setup = ''
    function get_cmd_val() {
      cat /proc/cmdline | tr " " "\n" | grep $1 | sed 's/.*=\(.*\)/\1/'
    }

    HOSTNAME=$(get_cmd_val hostname)
    if [[ "$HOSTNAME" != "" ]]; then
      hostname $HOSTNAME
      echo $HOSTNAME > /etc/hostname
    fi
  '';

  services.getty.autologinUser = lib.mkForce "root";

  environment.systemPackages = [
    nukeAndInstall
  ];

  services.promtail.enable = true;
  services.promtail.configuration = {
    positions.filename = "/tmp/promtail-positions.yaml";
    clients = [{
      url = "http://sergio.localdomain:3100";
    }];
    scrape_configs = [{
      job_name = "journal";
      journal = {
        json = true;
        labels.nix-host = "nucle-installer";
      };
      relabel_configs = [{
        source_labels = ["__journal__systemd_unit"];
        target_label = "unit";
      }];
    }];
  };

  systemd.services.nuke-and-install = {
    description = "Nuke /dev/nvme0n1 and install nucle";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${nukeAndInstall}/nuke.sh";
  };
}

