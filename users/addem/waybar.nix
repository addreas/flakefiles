{ config, pkgs, lib, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.top = {
      spacing = 4;
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "sway/scratchpad" "idle_inhibitor" "sway/language" "network" "pulseaudio" "backlight" "cpu" "memory" "temperature" "battery" "clock" "tray" ];

      "sway/mode".format = "{}";
      "sway/scratchpad" = {
        format = "{icon} {count}";
        show-empty = false;
        format-icons = [ "" "" ]; # nf-fa-window_restore
        tooltip = true;
        tooltip-format = "{app} = {title}";
      };
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
      "sway/language" = {
        format = "{short}";
        tooltip-format = "{long}";
        on-click = "swaymsg input type:keyboard xkb_switch_layout next";
      };
    };
    style = builtins.readFile ./waybar.style.css;
  };

  systemd.user.services.waybar.Service.Environment =
    let
      paths = [
        "${config.home.homeDirectory}/.nix-profile"
        "/etc/profiles/per-user/${config.home.username}"
        "${config.xdg.stateHome}/nix/profile"
        "/run/current-system/sw"
      ];
    in
    [ "PATH=${lib.strings.makeBinPath paths}" ];


    # programs.eww?
}
