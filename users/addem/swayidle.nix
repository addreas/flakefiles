{ pkgs, config, ... }:
let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";
in
{
  services.swayidle = {
    enable = true;
    events = [{
      event = "lock";
      command = "${swaylock} -f";
    }
      {
        event = "before-sleep";
        command = "${swaylock} -f";
      }];
    timeouts = [{
      timeout = 1800;
      command = "${swaylock} -f --grace 5";
    }];
    extraArgs = [ "idlehint 3600" ];
  };
}
