{ pkgs, lib, ... }:
{

  programs.home-manager.enable = true;

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

  home.packages = with pkgs; [
    vim
    helix
    wget
    curl
    fzf
    jq
    dig
    git
    variety
    ulauncher
    nix-index
  ];

  programs.zsh.enable = true;

  programs.oh-my-posh.enable = true;
  programs.oh-my-posh.enableZshIntegration = true;
  programs.oh-my-posh.useTheme = "bubbles";
  # programs.oh-my-posh.settings = builtins.fromJSON builtins.readFile ./bubbles.omp.json
  
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  
  programs.helix.enable = true;
  programs.helix.settings = {
    theme = "bogster";
    editor.scrolloff = 5;
    editor.file-picker.hidden = false;
    editor.whitespace.render = {
      tab = "all";
      newline = "all";
    };
    editor.lsp.display-messages = true;
  };

  services.kanshi.enable = true;
  services.kanshi.profiles = {
    internal = {
      outputs = [{
        criteria = "eDP-1";
        status = "enable";
      }];
    };

    thirty-four-inches = {
      outputs = [{
        criteria = "Dell Inc. DELL U3421WE 50F6753";
        status = "enable";
        mode = "3440x1440";
        position = "1920,0";
      }
      {
        criteria = "eDP-1";
        status = "disable";
        position =  "0,1080";
      }];
    };

    home = {
      outputs = [
        {
          criteria = "Unknown 2269WM BCPD59A000079";
          status = "enable";
          mode = "1920x1080";
          position = "0,0";
        }
        {
          criteria = "eDP-1";
          status = "enable";
          position = "1920,540";
        }
      ];
    };
  };

  # TODO: missing some env to make it worky worky
  services.swayidle = let swaylock = "${pkgs.swaylock-effects}/bin/swaylock"; in {
    enable = true; 
    events = [{ event = "lock";         command = "${swaylock} -f"; }
              { event = "before-sleep"; command = "${swaylock} -f"; }];
    timeouts = [{ timeout = 150; command = "${swaylock} -f --grace 5"; }];
    extraArgs = [ "idlehint 300" ];
  };

  programs.swaylock.settings = {
    indicator = true;
    clock = true;
    text-color = "EEEEEE";
    image = "$(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)";
    effect-blur =  "5x1";
    inside-clear-color =  "000000C0";
    text-caps-lock-color = "FA0000C0";
    text-clear-color = "E5A555FF";
    line-uses-inside = true;
  };
  
  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.config = rec {
    modifier = "Mod4";

    terminal = "kitty";
    menu = "ulauncher-toggle";

    bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];

    keybindings = lib.mkOptionDefault {
      "${modifier}+space" = null; # conflicts with win_space_toggle
      "${modifier}+Shift+f" = "floating toggle"; # use this instead

      "XF86AudioRaiseVolume" =   "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" =   "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" =          "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" =       "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      "XF86MonBrightnessDown" =  "exec brightnessctl set 5%-";
      "XF86MonBrightnessUp" =    "exec brightnessctl set +5%";
      "XF86AudioPlay" =          "exec playerctl play-pause";
      "XF86AudioNext" =          "exec playerctl next";
      "XF86AudioPrev" =          "exec playerctl previous";
    };

    floating.modifier = modifier;
    floating.border = 1;
    floating.criteria = [
      { app_id = "ulauncher"; }
      { app_id = "wdisplays"; }
      { title = "Variety.*"; }
      { title = ".+[Ss]haring (Indicator|your screen)"; }
    ];

    window.border = 1;
    window.commands = [
      # TODO: deduplicate criteria
      { criteria = {app_id="ulauncher";}; command = "border none"; }
      { criteria = {app_id="wdisplays";}; command = "border none"; }
      { criteria = {title="Variety.*";}; command = "border none"; }
      { criteria = {title=".+[Ss]haring (Indicator|your screen)";}; command = "move to scratchpad"; }
      
    ];

    focus.mouseWarping = "container";

    gaps.inner = 5;

    input = {
      "type:touchpad" = {
        tap = "on";
        dwt = "disabled";
      };
      "*" = {
        xkb_layout  = "gb,se";
        xkb_options = "grp:win_space_toggle";
      };
    };
    
    workspaceAutoBackAndForth = true;

    workspaceOutputAssign = let
      up = "\"Dell Inc. DELL U3421WE 50F6753\"";
      home = "\"Unknown 2269WM BCPD59A000079\"";
    in [
      { workspace = "1"; output = "${up} ${home} eDP-1"; }
      { workspace = "2"; output = "${up} ${home} eDP-1"; }
      { workspace = "3"; output = "${up} ${home} eDP-1"; }
      { workspace = "4"; output = "${up} eDP-1"; }
      { workspace = "10"; output = "eDP-1"; }
    ];
  };


  systemd.user.services.ulauncher = {
    Unit = {
      Description = "Linux Application Launcher";
      Documentation = "https://ulauncher.io/";
    };

    # TODO: needs some env to find desktop files?
    Service = { ExecStart = "${pkgs.ulauncher}/bin/ulauncher --hide-window"; };

    Install = { WantedBy = ["graphical-session.target"]; };
  };

  systemd.user.services.variety = {
    Unit = { Description = "Variety"; };

    # TODO: needs fix for scripts/set_wallpaper
    Service = { ExecStart = "${pkgs.variety}/bin/variety"; };

    Install = { WantedBy = ["graphical-session.target"]; };
  };

  # services.kdeconnect.enable = true;
}
