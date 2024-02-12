{ pkgs, lib, ... }:
let
  set-wallpaper = pkgs.writeShellScript "set_wallpaper" ''
    #!/bin/bash
    WP=$1
    if [[ -n $SWAYSOCK ]]; then
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
{
  # replace with programs.gallery-dl and services.wpaperd?

  home.packages = [ pkgs.variety ];

  systemd.user.services.variety = {
    Unit = { Description = "Variety"; };
    Service = {
      Environment = [
        "PATH=${lib.strings.makeBinPath [
        pkgs.bash
        "/run/current-system/sw"
      ]}"
      ];
      ExecStart = "${pkgs.variety}/bin/variety";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  home.activation = {
    variety-set-wallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run cp -f $VERBOSE_ARG ${set-wallpaper} $HOME/.config/variety/scripts/set_wallpaper
    '';
  };
}
