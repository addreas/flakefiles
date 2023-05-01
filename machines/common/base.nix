{ config, pkgs, lib, ... }:
{
  nix.package = pkgs.nixVersions.stable;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"

      # https://github.com/NixOS/nix/pull/3600
      "auto-allocate-uids"
      "cgroups"
    ];
    system-features = [ "kvm" "big-parallel" "uid-range" ];
    auto-allocate-uids = true;
    use-cgroups = true;

    substituters =  [
      "http://sergio.localdomain:9723"
      # "s3://nix-cache?scheme=http&endpoint=sergio.localdomain:9000"
      "https://nix-community.cachix.org"
    ];

    trusted-users = [ "root" "@wheel" ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lenny-wsl-0:T6NHA2GC8JwcLTtDMKyl/osBFdk8+gt9o95poXrtmM0="
      "expessy-0:03bM28uM9sIw2pGW4aFqNWPsdVSVZXu9REOMbUnQrLw="
      "sergio-0:iLOUuTIPPeJARAemTdAhD4y0Yi+/luB52jiQhMYBwVE="
    ];
  };

  nix.gc.automatic = true;

  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  services.xserver.layout = "gb";

  # services.kmscon.enable = true;
  # systemd.services.reload-systemd-vconsole-setup.enable = false;
  # environment.etc = let cfg = config.services.xserver; in {
  #     "X11/xorg.conf.d/00-keyboard.conf".text = ''
  #       Section "InputClass"
  #         Identifier "Keyboard catchall"
  #         MatchIsKeyboard "on"
  #         Option "XkbModel" "${cfg.xkbModel}"
  #         Option "XkbLayout" "${cfg.layout}"
  #         Option "XkbOptions" "${cfg.xkbOptions}"
  #         Option "XkbVariant" "${cfg.xkbVariant}"
  #       EndSection
  #     '';
  #   }

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.command-not-found.enable = false;

  environment.systemPackages = with pkgs; [
    zsh
    vim
    helix
    curl
    git
    parted
  ];
}

