{ config, inputs, lib, pkgs, ... }:
let
  dms = config.desktop.niri.dms;
in
{
  options.desktop.niri.dms = lib.mkEnableOption "Dux Shell on niri (else bare niri)" // {
    default = true;
  };

  imports = [
    inputs.niri.homeModules.config
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  config = {

  # niri comes from the system (machines/expessy/default.nix); niri-flake only
  # generates the config. Match the package so it's validated against the
  # version we run.
  programs.niri.package = pkgs.niri;

  programs.dank-material-shell.enable = dms;

  # `dms run` at startup; config.kdl includes the dms/*.kdl fragments and our
  # config moves to hm.kdl.
  programs.dank-material-shell.niri = lib.mkIf dms {
    enableSpawn = true;
    includes = {
      enable = true;
      override = false; # settings below win over DMS's fragments
    };
  };

  programs.niri.settings = {
    input = {
      keyboard.xkb = {
        layout = "gb,se";
        options = "grp:win_space_toggle";
      };
      touchpad.tap = true;
      warp-mouse-to-focus.enable = true;
    };

    layout = {
      gaps = 5;
      focus-ring.enable = false;
      # No colors: they come from dms/colors.kdl. `enable` is needed for the
      # generated border fix (niri "border special case").
      border = {
        enable = true;
        width = 1;
      };
    };

    # niri-flake would otherwise pin the "default" cursor theme.
    cursor = {
      theme = config.home.pointerCursor.name;
      size = config.home.pointerCursor.size;
    };

    prefer-no-csd = true;

    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    window-rules = [
      {
        matches = [ { app-id = "satty"; } ];
        open-floating = true;
      }
    ];

    switch-events = {
      lid-close.action.spawn = [
        "niri"
        "msg"
        "output"
        "eDP-1"
        "off"
      ];
      lid-open.action.spawn = [
        "niri"
        "msg"
        "output"
        "eDP-1"
        "on"
      ];
    };

    binds = lib.optionalAttrs dms {
      "Mod+Print".action.spawn-sh = "dms screenshot region --stdout | ${lib.getExe pkgs.satty} -f -";
      "Mod+D".action.spawn = [ "dms" "ipc" "spotlight" "toggle" ];
      "Mod+N".action.spawn = [ "dms" "ipc" "notifications" "toggle" ];
      "Mod+Shift+Comma".action.spawn = [ "dms" "ipc" "settings" "toggle" ];
      "Mod+X".action.spawn = [ "dms" "ipc" "powermenu" "toggle" ];
      "Mod+Alt+V".action.spawn = [ "dms" "ipc" "clipboard" "toggle" ];
      "Super+Alt+L".action.spawn = [ "dms" "ipc" "lock" "lock" ];
    }
    // lib.optionalAttrs (!dms) {
      "Mod+Print".action.spawn-sh =
        "${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" - | ${lib.getExe pkgs.satty} -f -";
      "Super+Alt+L".action.spawn = [ "swaylock" "-f" ];
    }
    // {
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

      "Mod+Return".action.spawn = "alacritty";

      "Mod+Q" = {
        repeat = false;
        action.close-window = [ ];
      };
      "Mod+Shift+E".action.quit = [ ];

      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+J".action.focus-window-down = [ ];
      "Mod+K".action.focus-window-up = [ ];
      "Mod+L".action.focus-column-right = [ ];

      "Mod+Shift+Left".action.move-column-left = [ ];
      "Mod+Shift+Down".action.move-window-down = [ ];
      "Mod+Shift+Up".action.move-window-up = [ ];
      "Mod+Shift+Right".action.move-column-right = [ ];
      "Mod+Shift+H".action.move-column-left = [ ];
      "Mod+Shift+J".action.move-window-down = [ ];
      "Mod+Shift+K".action.move-window-up = [ ];
      "Mod+Shift+L".action.move-column-right = [ ];

      "Mod+Home".action.focus-column-first = [ ];
      "Mod+End".action.focus-column-last = [ ];
      "Mod+Ctrl+Home".action.move-column-to-first = [ ];
      "Mod+Ctrl+End".action.move-column-to-last = [ ];

      "Mod+Ctrl+Left".action.focus-monitor-left = [ ];
      "Mod+Ctrl+Down".action.focus-monitor-down = [ ];
      "Mod+Ctrl+Up".action.focus-monitor-up = [ ];
      "Mod+Ctrl+Right".action.focus-monitor-right = [ ];
      "Mod+Ctrl+H".action.focus-monitor-left = [ ];
      "Mod+Ctrl+J".action.focus-monitor-down = [ ];
      "Mod+Ctrl+K".action.focus-monitor-up = [ ];
      "Mod+Ctrl+L".action.focus-monitor-right = [ ];

      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];

      "Mod+Page_Down".action.focus-workspace-down = [ ];
      "Mod+Page_Up".action.focus-workspace-up = [ ];
      "Mod+U".action.focus-workspace-down = [ ];
      "Mod+I".action.focus-workspace-up = [ ];
      "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
      "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];

      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+Ctrl+1".action.move-column-to-workspace = 1;
      "Mod+Ctrl+2".action.move-column-to-workspace = 2;
      "Mod+Ctrl+3".action.move-column-to-workspace = 3;
      "Mod+Ctrl+4".action.move-column-to-workspace = 4;
      "Mod+Ctrl+5".action.move-column-to-workspace = 5;
      "Mod+Ctrl+6".action.move-column-to-workspace = 6;
      "Mod+Ctrl+7".action.move-column-to-workspace = 7;
      "Mod+Ctrl+8".action.move-column-to-workspace = 8;
      "Mod+Ctrl+9".action.move-column-to-workspace = 9;

      "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
      "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
      "Mod+Comma".action.consume-window-into-column = [ ];
      "Mod+Period".action.expel-window-from-column = [ ];

      "Mod+R".action.switch-preset-column-width = [ ];
      "Mod+Shift+R".action.switch-preset-column-width-back = [ ];
      "Mod+Ctrl+Shift+R".action.switch-preset-window-height = [ ];
      "Mod+Ctrl+R".action.reset-window-height = [ ];

      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      "Mod+M".action.maximize-window-to-edges = [ ];
      "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
      "Mod+C".action.center-column = [ ];
      "Mod+Ctrl+C".action.center-visible-columns = [ ];

      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      "Mod+V".action.toggle-window-floating = [ ];
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];
      "Mod+W".action.toggle-column-tabbed-display = [ ];

      "Print".action.screenshot = [ ];
      "Ctrl+Print".action.screenshot-screen = [ ];
      "Alt+Print".action.screenshot-window = [ ];

      "Mod+Escape" = {
        allow-inhibiting = false;
        action.toggle-keyboard-shortcuts-inhibit = [ ];
      };
      "Mod+Shift+P".action.power-off-monitors = [ ];

      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "pactl"
          "set-sink-volume"
          "@DEFAULT_SINK@"
          "+5%"
        ];
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "pactl"
          "set-sink-volume"
          "@DEFAULT_SINK@"
          "-5%"
        ];
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn = [
          "pactl"
          "set-sink-mute"
          "@DEFAULT_SINK@"
          "toggle"
        ];
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action.spawn = [
          "pactl"
          "set-source-mute"
          "@DEFAULT_SOURCE@"
          "toggle"
        ];
      };
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action.spawn = [
          "playerctl"
          "play-pause"
        ];
      };
      "XF86AudioPause" = {
        allow-when-locked = true;
        action.spawn = [
          "playerctl"
          "play-pause"
        ];
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action.spawn = [
          "playerctl"
          "next"
        ];
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action.spawn = [
          "playerctl"
          "previous"
        ];
      };
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "set"
          "+5%"
        ];
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "set"
          "5%-"
        ];
      };
      "XF86TouchpadToggle" = {
        repeat = false;
        action.spawn = [
          "niri"
          "msg"
          "action"
          "toggle-touchpad"
        ];
      };
    };
  };
  };
}
