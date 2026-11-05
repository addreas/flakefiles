{ config, lib, pkgs, ... }:
let
  plain = import ./plain-session.nix { inherit config; };
in
{
  # services.cliphist.enable = true;

  services.batsignal.enable = true; # todo: auto suspend
  services.batsignal.extraArgs = [
    "-c10" # critical level
    "-CCritical battery level. Suspending at 5%" # critical message
    "-d5" # danger level
    "-D${pkgs.systemd}/bin/systemctl suspend" # danger command
  ];
  # services.poweralertd.enable = true;
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  # DMS has its own NetworkManager/Bluetooth widgets and pairing/secret agents,
  # so the applets only run in sessions without it.
  services.network-manager-applet.enable = plain.enable;
  services.blueman-applet = {
    enable = plain.enable;
    systemdTargets = plain.targets;
  };

  systemd.user.services.network-manager-applet = lib.mkIf plain.enable {
    Unit.PartOf = lib.mkForce plain.targets;
    Install.WantedBy = lib.mkForce plain.targets;
  };

  home.packages = with pkgs; [ gcr_4 ];
}
