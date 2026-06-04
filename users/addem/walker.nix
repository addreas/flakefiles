{ config, pkgs, lib, ... }:
{
  services.elephant.enable = true;

  # TODO: replacements for
  # https://github.com/fsevenm/ulauncher-uuid
  # https://github.com/brpaz/ulauncher-encoder
  # https://github.com/friday/ulauncher-hash2
  # https://github.com/brpaz/ulauncher-timestamp

  services.walker = {
    enable = true;
    systemd.enable = true;

    settings = {
      close_when_open = true;
      force_keyboard_focus = true;
    };
  };
}
