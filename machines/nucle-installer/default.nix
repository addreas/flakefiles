{ config, pkgs, lib, modulesPath, ... }:
let
  cmdline = pkgs.writeScriptBin "cmdline" (
      builtins.replaceStrings
        ["/usr/bin/env python3"]
        ["${pkgs.python3}/bin/python"]
        (builtins.readFile ./cmdline.py)
    );
  nuke = pkgs.writeShellApplication {
      name = "nuke-nvme0n1-and-install";
      runtimeInputs = [ pkgs.parted pkgs.curl cmdline ];
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

  networking.hostName = ""; # these have to be set via kernel cmdline

  system.activationScripts.cmdline-setup = ''
    HOSTNAME=$(${cmdline}/bin/cmdline hostname)
    if [[ "$HOSTNAME" != "" ]]; then
      hostname $HOSTNAME
      echo $HOSTNAME > /etc/hostname
    fi

    echo $(${cmdline}/bin/cmdline pixie-logger)

    JOURNALD_UPLOAD_URL=$(${cmdline}/bin/cmdline journald)
    echo $JOURNALD_UPLOAD_URL

    mkdir -p /run/systemd/journal-upload.conf.d
    echo "URL=$JOURNALD_UPLOAD_URL" > /run/systemd/journal-upload.conf.d/url.conf
    systemctl reload systemd-journal-upload
  '';

  systemd.additionalUpstreamSystemUnits = ["systemd-journal-upload.service"];
  systemd.services.systemd-journal-upload.enable = true;


  services.getty.autologinUser = lib.mkForce "root";
  services.kmscon.autologinUser = lib.mkForce "root";

  environment.systemPackages = [
    nuke
    cmdline
  ];

  # systemd.services.nuke-and-install = {
  #   description = "Nuke /dev/nvme0n1 and install nucle";
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig.ExecStart = "${nuke}/bin/nuke-nvme0n1-and-install";
  # };
}
