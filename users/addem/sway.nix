{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    pulseaudio
    brightnessctl
    playerctl
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = null; # defer to system config

    config = rec {
      modifier = "Mod4";

      terminal = "kitty";
      menu = "ulauncher-toggle";

      bars = [ ];

      keybindings = lib.mkOptionDefault {
        "${modifier}+space" = null; # conflicts with win_space_toggle
        "${modifier}+Shift+f" = "floating toggle"; # use this instead

        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";
      };

      floating.modifier = modifier;
      floating.border = 1;
      floating.criteria = [
        { app_id = "ulauncher"; }
        { app_id = "wdisplays"; }
        { app_id = "variety"; }
        { title = ".+[Ss]haring (Indicator|your screen)"; }

        { app_id = "lutris"; }
        { instance = "Steam"; }
        { instance = "eadesktop.exe"; }
      ];

      window.border = 1;
      window.commands = [
        # TODO: deduplicate criteria
        { criteria = { app_id = "ulauncher"; }; command = "border none"; }
        { criteria = { app_id = "wdisplays"; }; command = "border none"; }
        { criteria = { app_id = "variety"; }; command = "border none"; }
        { criteria = { title = ".+[Ss]haring (Indicator|your screen)"; }; command = "move to scratchpad"; }
        { criteria = { instance = "explorer.exe"; title = "Wine System Tray"; }; command = "move to scratchpad"; }

      ];

      focus.mouseWarping = "container";

      gaps.inner = 5;

      input = {
        "type:touchpad" = {
          tap = "on";
          dwt = "disabled";
        };
        "*" = {
          xkb_layout = "gb,se";
          xkb_options = "grp:win_space_toggle";
        };
      };

      workspaceAutoBackAndForth = true;

      workspaceOutputAssign =
        let
          up = "\"Dell Inc. DELL U3421WE 50F6753\"";
          home = "\"Samsung Electric Company LS27A800U HNMTA00128\"";
        in
        [
          { workspace = "1"; output = "${up} ${home} eDP-1"; }
          { workspace = "2"; output = "${up} ${home} eDP-1"; }
          { workspace = "3"; output = "${up} ${home} eDP-1"; }
          { workspace = "4"; output = "${up} eDP-1"; }
          { workspace = "10"; output = "eDP-1"; }
        ];
    };
    extraConfig = ''
      bindswitch --reload --locked lid:on output eDP-1 disable
      bindswitch --reload --locked lid:off output eDP-1 enable
      '';
  };
}
