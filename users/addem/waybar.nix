{ pkgs, lib, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.top = {
      spacing = 4;
      modules-left = ["sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = ["sway/scratchpad" "idle_inhibitor" "sway/language" "network" "pulseaudio" "backlight" "cpu" "memory" "temperature" "battery" "clock" "tray"];

      "sway/mode".format = "{}";
      "sway/scratchpad" = {
          format = "{icon} {count}";
          show-empty = false;
          format-icons = ["" ""];
          tooltip = true;
          tooltip-format = "{app} = {title}";
      };
      idle_inhibitor = {
          format = "{icon}";
          format-icons = {
              activated = "";
              deactivated = "";
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
          format = "{usage}% ";
          tooltip = true;
      };
      memory = {
          format = "{}% ";
      };
      temperature = {
          thermal-zone = 2;
          # hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 80;
          # format-critical = "{temperatureC}°C {icon}";
          format = "{temperatureC}°C {icon}";
          format-icons = ["" "" ""];
      };
      backlight = {
          # device = "acpi_video1";
          format = "{percent}% {icon}";
          format-icons = ["" ""];
      };
      battery = {
          states = {
              # good = 95;
              warning = 30;
              critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          # format-good = ""; # An empty format will hide the module
          # format-full = "";
          format-icons = ["" "" "" "" ""];
      };
      network = {
          format-ethernet = "";
          tooltip-format-ethernet = "  {ifname} = {ipaddr}/{cidr}";

          format-wifi = "";
          tooltip-format-wifi = "  {essid} ({signalStrength}%)";

          format-linked = " (No IP)";
          format-disconnected = "⚠ Disconnected";
      };
      pulseaudio = {
          # scroll-step = 1; # %; can be a float
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
          };
          on-click = "pavucontrol";
      };
      "sway/language" = {
          format = "{short}";
          tooltip-format = "{long}";
          on-click = "sway_xkb_next";
      };
    };
    style = builtins.readFile ./waybar.style.css;
  };
}
