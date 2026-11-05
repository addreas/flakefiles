{ config, lib, ... }:
let
  plain = import ./plain-session.nix { inherit config; };
in
lib.mkIf plain.enable {
  services.mako.enable = true;
  services.mako.settings.default-timeout = 30 * 1000;
}
