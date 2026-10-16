{ config, pkgs, lib, ... }:

let
  regionArea = ''-g "$(${lib.getExe pkgs.slurp})" -'';
  fullArea   = "-";

  screenshot = grimArgs: pipeTo:
    "${lib.getExe pkgs.wayfreeze} --after-freeze-cmd '${lib.getExe pkgs.grim} ${grimArgs} | ${pipeTo}; killall wayfreeze'";
in
{
  services.elephant.enable = true;

  services.elephant.settings = {
  };

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
}
