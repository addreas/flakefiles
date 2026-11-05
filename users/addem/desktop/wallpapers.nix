{ config, lib, pkgs, ... }:
let
  dir = "${config.home.homeDirectory}/Pictures/Wallpapers";

  dms =
    (config.desktop.niri.dms or false)
    || ((config.desktop.sway.enable or false) && (config.desktop.sway.dms or false));
  tools = [ pkgs.curl pkgs.jq pkgs.coreutils ];

  fetch-bing = pkgs.writeShellApplication {
    name = "wallpapers-fetch-bing";
    runtimeInputs = tools;
    text = ''
      out="${dir}/Bing"
      mkdir -p "$out"
      curl -fsSL 'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=8&mkt=en-US' \
        | jq -r '.images[] | select(.wp)
            | [("https://www.bing.com" + .urlbase + "_UHD.jpg"),
               (.url | capture("id=(?<n>[^&]+)").n)] | @tsv' \
        | while IFS=$'\t' read -r url name; do
            [ -s "$out/$name" ] || curl -fsSL --retry 3 -o "$out/$name" "$url"
          done
    '';
  };

  fetch-earthview = pkgs.writeShellApplication {
    name = "wallpapers-fetch-earthview";
    runtimeInputs = tools;
    text = ''
      api='https://new-images-preview-dot-earth-viewer.appspot.com/_api'
      out="${dir}/Earth View"
      mkdir -p "$out"
      for slug in $(curl -fsSL "$api/photos.json" | jq -r '.[].slug' | shuf -n 5); do
        meta=$(curl -fsSL "$api/$slug.json")
        id=$(jq -r '.id' <<<"$meta")
        url=$(jq -r '.photoUrl' <<<"$meta")
        [ -s "$out/$id.jpg" ] && continue
        if ls "$out"/*"ID-$id"*.jpg >/dev/null 2>&1; then continue; fi
        curl -fsSL --retry 3 -o "$out/$id.jpg" "$url"
        sleep 1
      done
    '';
  };

  fetch-unsplash = pkgs.writeShellApplication {
    name = "wallpapers-fetch-unsplash";
    runtimeInputs = tools;
    text = ''
      out="${dir}/Unsplash"
      mkdir -p "$out"
      curl -fsSL 'https://api.unsplash.com/photos/random?count=30&orientation=landscape&client_id=072e5048dfcb73a8d9ad59fcf402471518ff8df725df462b0c4fa665f466515a' \
        | jq -r '.[] | [.id, (.urls.full + "&w=2560&q=90")] | @tsv' \
        | while IFS=$'\t' read -r id url; do
            [ -s "$out/$id.jpg" ] || curl -fsSL --retry 3 -o "$out/$id.jpg" "$url"
          done
    '';
  };
in
lib.mkIf dms {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "wallpaper-trash";
      runtimeInputs = [ pkgs.coreutils ];
      text = ''
        wp=$(dms ipc call wallpaper get) || exit 1
        rm -f "$wp"
        dms ipc call wallpaper next >/dev/null
      '';
    })
  ];

  programs.gallery-dl = {
    enable = true;
    settings = {
      extractor = {
        base-directory = dir;
        archive = "${dir}/.gallery-dl.sqlite3";
        wallhaven = {
          directory = [ "wallhaven" ];
          filename = "wallhaven-{id}.{extension}";
        };
      };
    };
  };

  systemd.user.services.wallpapers-fetch = {
    Unit = { Description = "Fetch wallpapers"; };
    Service = {
      Type = "oneshot";
      ExecStart = [
        "-${pkgs.gallery-dl}/bin/gallery-dl --range 1-24 'https://wallhaven.cc/search?q=nature+landscape&categories=111&purity=100&ratios=landscape&atleast=1920x1080&sorting=random'"
        "-${fetch-bing}/bin/wallpapers-fetch-bing"
        "-${fetch-earthview}/bin/wallpapers-fetch-earthview"
        "-${fetch-unsplash}/bin/wallpapers-fetch-unsplash"
      ];
    };
  };

  systemd.user.timers.wallpapers-fetch = {
    Unit = { Description = "Periodic wallpaper fetch"; };
    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "6h";
      RandomizedDelaySec = "10min";
      Persistent = true;
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}
