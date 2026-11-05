{ config, inputs, lib, options, pkgs, ... }:
let
  niri = config.desktop.niri.dms;
  sway = (config.desktop.sway.enable or false) && config.desktop.sway.dms;

  # only the sessions that actually run the shell
  targets =
    if niri && sway then
      [ "graphical-session.target" ]
    else if niri then
      [ "niri.service" ]
    else
      [ "sway-session.target" ];
in
{
  options.desktop.niri.dms = lib.mkEnableOption "Dux Shell on niri (else bare niri)" // {
    default = true;
  };

  options.desktop.sway.dms = lib.mkEnableOption "Dux Shell on sway (else waybar/mako/walker)";

  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  config = lib.mkIf (niri || sway) {
    programs.dank-material-shell = {
      enable = true;
      # systemd unit bound to the compositor below (Restart=on-failure,
      # notify, journal logging) instead of `spawn-at-startup`.
      systemd.enable = true;
    };

    systemd.user.services.dms = {
      Unit.PartOf = lib.mkForce targets;
      Unit.After = lib.mkForce targets;
      Install.WantedBy = lib.mkForce targets;
      Service.UnsetEnvironment = [ "SHLVL" ];
    };

    # config.kdl includes the dms/*.kdl fragments, our config moves to hm.kdl
    programs.dank-material-shell.niri = lib.mkIf niri {
      includes = {
        enable = true;
        override = false; # settings in niri.nix win over the fragments
      };
    };

    programs.niri.settings.binds = lib.mkIf (niri && options.programs ? niri) {
        "Mod+Print".action.spawn-sh = "dms screenshot region --stdout | ${lib.getExe pkgs.satty} -f -";
        "Mod+D".action.spawn = [ "dms" "ipc" "spotlight" "toggle" ];
        "Mod+N".action.spawn = [ "dms" "ipc" "notifications" "toggle" ];
        "Mod+Shift+Comma".action.spawn = [ "dms" "ipc" "settings" "toggle" ];
        "Mod+X".action.spawn = [ "dms" "ipc" "powermenu" "toggle" ];
        "Mod+Alt+V".action.spawn = [ "dms" "ipc" "clipboard" "toggle" ];
        "Super+Alt+L".action.spawn = [ "dms" "ipc" "lock" "lock" ];
    };

    wayland.windowManager.sway.config.keybindings = lib.mkIf sway {
      "Mod4+d" = "exec dms ipc spotlight toggle";
      "Mod4+n" = "exec dms ipc notifications toggle";
      "Mod4+x" = "exec dms ipc powermenu toggle";
      "Super+Alt+l" = "exec dms ipc lock lock";
    };
  };
}
