{
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.dank-greeter.nixosModules.default
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = false; # the shell is a HM user unit (users/addem/desktop/dms.nix)
  };

  # Login screen matching the shell (theme/wallpaper come from
  # ~/.config/dms/settings.json + ~/.local/state/dms/session.json).
  programs.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = config.users.users.addem.home;
  };
}
