{ pkgs, lib, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.mainBar = {
      # height = 25; # Waybar height (to be removed for auto height)
      modules-left = ["sway/workspaces" "sway/mode"];
      modules-center = ["sway/window"];
      modules-right = ["sway/scratchpad" "idle_inhibitor" "sway/language" "network" "pulseaudio" "backlight" "cpu" "memory" "temperature" "battery" "clock" "tray"];
      "sway/mode" = {
          format = "{}";
      };
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
          tooltip-format = "<big>{ =%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{ =%Y-%m-%d %H =%M =%S}";
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
    style = ''
      * {
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: FontAwesome, Roboto, Helvetica, Arial, sans-serif;
          font-size: 13px;
      }

      window#waybar {
          background-color: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      window#waybar.termite {
          background-color: #3F3F3F;
      }

      window#waybar.chromium {
          background-color: #000000;
          border: none;
      }

      button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      button:hover {
          background: inherit;
          box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
      }

      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.focused {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.urgent {
          background-color: #eb4d4b;
      }

      #mode {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #language,
      #mpd {
          padding: 0 10px;
          color: #ffffff;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #clock {}

      #battery {}

      #battery.charging, #battery.plugged, #battery.full {
          color: #ffffff;
          background-color: #26A65B;
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: #000000;
          }
      }

      #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      label:focus {
          background-color: #000000;
      }

      #cpu {}

      #memory {}

      #disk {}

      #backlight {}

      #network {}

      #network.disconnected {
          background-color: #f53c3c;
      }

      #pulseaudio {}

      #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
      }


      #temperature {}

      #temperature.critical {
          background-color: #eb4d4b;
      }

      #tray {}

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }

      #idle_inhibitor {}

      #idle_inhibitor.activated {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #language {
          font-variant: small-caps;
      }

      #scratchpad {
          background: rgba(0, 0, 0, 0.2);
      }

      #scratchpad.empty {
        background-color: transparent;
      }
    '';
  };
}
