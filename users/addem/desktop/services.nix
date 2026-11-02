{ pkgs, ... }:
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

  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;

  home.packages = with pkgs; [ gcr_4 ];
}
