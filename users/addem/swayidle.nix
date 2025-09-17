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
