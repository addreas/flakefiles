{ pkgs, config, ... }:
let
  # swaylock = "${config.programs.swaylock.package}/bin/swaylock";
  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
in
{
  # TODO: how to make it worky worky?
  # forky fork swaylock-effects?
  services.swayidle =  {
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
      timeout = 150;
      command = "${swaylock} -f --grace 5";
    }];
    extraArgs = [ "idlehint 300" ];
  };
}