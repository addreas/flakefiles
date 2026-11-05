{ config, lib, pkgs, ... }:
let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";
  plain = import ./plain-session.nix { inherit config; };
in
lib.mkIf plain.enable {
  services.swayidle = {
    enable = true;
    systemdTargets = plain.targets; # DMS does idle/lock in its sessions
    events.lock = "${swaylock} -f";
    events.before-sleep = "${swaylock} -f";
    timeouts = [{
      timeout = 60 * 5;
      command = "${swaylock} -f --grace 5";
    }
      {
        timeout = 60 * 10;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }];
    extraArgs = [ "idlehint" "300" ];
  };
}
