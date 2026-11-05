{ config, pkgs, lib, ... }:
let
  helpers = import ../lib.nix { inherit config lib; };

  # Variety only where the shell is not DMS (see users/addem/desktop/plain.nix)
  plain =
    !(config.desktop.niri.dms or true)
    || ((config.desktop.sway.enable or false) && !(config.desktop.sway.dms or false));

  set-wallpaper = pkgs.writeShellScript "set_wallpaper" ''
    #!/bin/bash
    WP=$1

    # Under niri, let DMS set the wallpaper so it regenerates the palette.
    applied=0
    if command -v dms >/dev/null 2>&1; then
        for _ in 1 2 3 4 5; do
            if dms ipc call wallpaper set "$WP" >/dev/null 2>&1; then
                applied=1
                break
            fi
            sleep 1
        done
    fi

    if [[ $applied -eq 0 && -n $SWAYSOCK ]]; then
        # If swaybg is available, use it as prevents system freeze.
        # See https://github.com/swaywm/sway/issues/5606
        if command -v "swaybg" >/dev/null 2>&1; then
            # Grey background flicker is prevented by killing old swaybg process after new one.
            # See https://github.com/swaywm/swaybg/issues/17#issuecomment-851680720
            PID=`pidof swaybg`
            swaybg -i "$WP" -m fill &
            if [ ! -z "$PID" ]; then
                sleep 1
                kill $PID 2>/dev/null
            fi
        else
            swaymsg output "*" bg "$WP" fill 2> /dev/null
        fi
    fi

    cp "$(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)" $HOME/.config/variety/wallpaper/wallpaper.jpg
    exit 0
  '';
in
lib.mkIf plain {
  # replace with programs.gallery-dl and services.wpaperd?

  home.packages = [ pkgs.variety pkgs.swaybg ];

  systemd.user.services.variety = {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [ helpers.pathEnvironment ];
      ExecStart = "${pkgs.variety}/bin/variety";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.activation = {
    variety-set-wallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run cp -f $VERBOSE_ARG ${set-wallpaper} $HOME/.config/variety/scripts/set_wallpaper
    '';
  };
}
