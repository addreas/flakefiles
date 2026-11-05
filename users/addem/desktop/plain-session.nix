{ config }:
let
  niriPlain = !config.desktop.niri.dms;
  swayPlain = !config.desktop.sway.dms;
in
{
  inherit niriPlain swayPlain;
  enable = niriPlain || swayPlain;
  # sway-session.target only exists in sway, so plain niri uses niri.service
  # (or graphical-session.target when both sessions are plain).
  targets =
    if niriPlain && swayPlain then
      [ "graphical-session.target" ]
    else if swayPlain then
      [ "sway-session.target" ]
    else
      [ "niri.service" ];
}
