{ config, pkgs, lib, modulesPath, ... }:
let
  nuke = pkgs.writeShellApplication {
      name = "nuke-nvme0n1-and-install";
      runtimeInputs = [ pkgs.parted pkgs.curl ];
      text = builtins.readFile ./nuke.sh;
    };
  cmdline = pkgs.writeScriptBin "cmdline" (
      builtins.replaceStrings
        ["/usr/bin/env python3"]
        ["${pkgs.python3}/bin/python"]
        (builtins.readFile ./cmdline.py)
    );
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
    HOSTNAME=$(${cmdline}/bin/cmdline hostname)
    if [[ "$HOSTNAME" != "" ]]; then
      hostname $HOSTNAME
      echo $HOSTNAME > /etc/hostname
    fi
  '';

  services.getty.autologinUser = lib.mkForce "root";

  environment.systemPackages = [
    nuke
    cmdline
  ];

  systemd.services.nuke-and-install = {
    description = "Nuke /dev/nvme0n1 and install nucle";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${nuke}/bin/nuke-nvme0n1-and-install";
  };
}
