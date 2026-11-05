{ config, lib, pkgs, ... }:
let
  helpers = import ../lib.nix { inherit config lib; };

  niriPlain = !(config.desktop.niri.dms or true);
  swayPlain = (config.desktop.sway.enable or false) && !(config.desktop.sway.dms or false);
  enabled = niriPlain || swayPlain;

  # sway-session.target only exists in sway, niri.service only in niri;
  # graphical-session.target covers both.
  targets =
    if niriPlain && swayPlain then
      [ "graphical-session.target" ]
    else if swayPlain then
      [ "sway-session.target" ]
    else
      [ "niri.service" ];

  swaylock = "${config.programs.swaylock.package}/bin/swaylock";

  regionArea = ''-g "$(${lib.getExe pkgs.slurp})" -'';
  fullArea = "-";
  screenshot = grimArgs: pipeTo:
    "${lib.getExe pkgs.wayfreeze} --after-freeze-cmd '${lib.getExe pkgs.grim} ${grimArgs} | ${pipeTo}; killall wayfreeze'";

  workspaces = if niriPlain then "niri/workspaces" else "sway/workspaces";
  window = if niriPlain then "niri/window" else "sway/window";
  language = if niriPlain then "niri/language" else "sway/language";
in
lib.mkIf enabled {
  wayland.windowManager.sway.config.menu = "walker";
  services.network-manager-applet.enable = true;
  services.blueman-applet = {
    enable = true;
    systemdTargets = targets;
  };

  systemd.user.services.network-manager-applet = {
    Unit.PartOf = lib.mkForce targets;
    Install.WantedBy = lib.mkForce targets;
  };

  services.mako.enable = true;
  services.mako.settings.default-timeout = 30 * 1000;

  services.elephant.enable = true;

  services.elephant.settings = { };

  xdg.configFile."elephant/menus/screenshots.toml" = {
    source = (pkgs.formats.toml { }).generate "elephant-menus-screenshots" {
      name = "screenshots";
      name_pretty = "Screenshots";
      icon = "camera-photo";

      entries = [
        {
          text = "Screenshot Region";
          actions = { region = screenshot regionArea "${lib.getExe pkgs.satty} -f -"; };
        }
        {
          text = "Screenshot Window";
          actions = { window = screenshot fullArea "${lib.getExe pkgs.satty} -f -"; };
        }
        {
          text = "Screenshot OCR";
          actions = { ocr = screenshot regionArea "${lib.getExe pkgs.tesseract} stdin stdout -l swe+eng | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"; };
        }
      ];
    };
  };

  # TODO: replacements for
  # https://github.com/fsevenm/ulauncher-uuid
  # https://github.com/brpaz/ulauncher-encoder
  # https://github.com/friday/ulauncher-hash2
  # https://github.com/brpaz/ulauncher-timestamp

  xdg.configFile."elephant/menus/power.toml" = {
    source = (pkgs.formats.toml { }).generate "elephant-menus-power" {
      name = "power";
      name_pretty = "Power";
      icon = "system-shutdown";

      entries = [
        {
          text = "Lock";
          keywords = [ "lock" ];
          actions = { suspend = "${lib.getExe' pkgs.systemd "loginctl"} lock-session"; };
        }
        {
          text = "Sleep";
          keywords = [ "suspend" "sleep" ];
          actions = { suspend = "${lib.getExe' pkgs.systemd "systemctl"} suspend"; };
        }
        {
          text = "Shutdown";
          keywords = [ "shutdown" "poweroff" ];
          actions = { shutdown = "${lib.getExe' pkgs.systemd "systemctl"} poweroff"; };
        }
      ];
    };
  };

  # sway only: niri uses the DMS launcher
  systemd.user.services.elephant = {
    Unit.After = lib.mkForce targets;
    Unit.PartOf = lib.mkForce targets;
    Install.WantedBy = lib.mkForce targets;
  };

  systemd.user.services.walker = {
    Unit.After = lib.mkForce (targets ++ [ "elephant.service" ]);
    Install.WantedBy = lib.mkForce targets;
  };

  services.walker = {
    enable = true;
    systemd.enable = true;

    settings = {
      close_when_open = true;
      force_keyboard_focus = true;
      providers = {
        default = [
          "desktopapplications"
          "menus:screenshots"
          "menus:power"
          "calc"
          "actions"
          # "symbols"
          # "unicode"
          # "websearch"
        ];
      };
    };
  };

  services.swayidle = {
    enable = true;
    systemdTargets = targets; # DMS does idle/lock in its sessions
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

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      inherit targets;
    };
    settings.top = {
      spacing = 4;
      modules-left = [ workspaces ] ++ lib.optional (!niriPlain) "sway/mode";
      modules-center = [ window ];
      modules-right = [ "idle_inhibitor" language "network" "pulseaudio" "backlight" "cpu" "memory" "temperature" "battery" "clock" "tray" ];

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = ""; #nf-fa-eye
          deactivated = ""; #nf-fa-eye_slash
        };
        tooltip = false;
        timeout = 30;
      };
      tray = {
        icon-size = 16;
        spacing = 8;
      };
      clock = {
        interval = 1;
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format = "{:%Y-%m-%d %H:%M:%S}";
      };
      cpu = {
        format = "{usage}% "; # nf-fa-microchip
        tooltip = true;
      };
      memory = {
        format = "{}% "; # nf-fa-bars
      };
      temperature = {
        #  thermal-zone = 1;
        # hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
        critical-threshold = 80;
        # format-critical = "{temperatureC}°C {icon}";
        format = "{temperatureC}°C {icon}";
        format-icons = [ "" "" "" ]; # nf-fa-thermometer_(empty|half|full)
      };
      backlight = {
        # device = "acpi_video1";
        format = "{percent}% {icon}";
        format-icons = [ "" "" ]; #nf-fa-sun nf-fa-circle
      };
      battery = {
        states = {
          full = 100;
          ninety = 90;
          eighty = 80;
          seventy = 70;
          sixty = 60;
          fifty = 50;
          fourty = 40;
          warning = 30;
          twenty = 20;
          critical = 10;
        };
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% 󰂄"; #nf-md-battery_charging
        format-plugged = "{capacity}% 󱐥"; #nf-md-power_plug_outline
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ]; #nf-md-battery_xx..., nf-md-battery
      };
      network = {
        format-ethernet = "󰈀"; # nf-md-ethernet
        tooltip-format-ethernet = "󰈀 {ifname} = {ipaddr}/{cidr}"; # nf-md-ethernet

        format-wifi = ""; # nf-fa-wifi
        tooltip-format-wifi = "  {essid} ({signalStrength}%)";

        format-linked = "󰈀 (No IP)"; # nf-md-ethernet
        format-disconnected = "⚠ Disconnected"; # warning emoji
      };
      pulseaudio = {
        # scroll-step = 1; # %; can be a float
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}"; #nf-fa-bluetooth_b
        format-bluetooth-muted = "󰝟 {icon} {format_source}"; # nf-md-volume_mute 412nf-fa-bluetooth_b
        format-muted = "󰝟 {format_source}"; #nf-md-volume_mute
        format-source = "{volume}% "; #nf-fa-microphone
        format-source-muted = ""; #nf-fa-microphone_slash
        format-icons = {
          headphone = ""; #nf-fa-headphones
          hands-free = "󰋎"; #nf-md-headset
          headset = "󰋎"; #nf-md-headset
          phone = ""; #nf-fa-phone
          portable = ""; #nf-fa-phone
          car = ""; #nf-fa-car
          default = [ "󰕿" "󰖀" "󰕾" ]; # nf-md-volume_(low|medium|high)
        };
        on-click = "pavucontrol";
      };
      ${language} = {
        format = "{short}";
        tooltip-format = "{long}";
      } // lib.optionalAttrs (!niriPlain) {
        on-click = "swaymsg input type:keyboard xkb_switch_layout next";
      };
    }
    // lib.optionalAttrs (!niriPlain) {
      "sway/mode".format = "{}";
      "sway/scratchpad" = {
        format = "{icon} {count}";
        show-empty = false;
        format-icons = [ "" "" ]; # nf-fa-window_restore
        tooltip = true;
        tooltip-format = "{app} = {title}";
      };
    };
    style = builtins.readFile ./waybar.style.css;
  };

  systemd.user.services.waybar = {
    Unit.PartOf = lib.mkForce targets;
    Install.WantedBy = lib.mkForce targets;
    Service.Environment = [ helpers.pathEnvironment ];
  };


  # programs.eww?
}
