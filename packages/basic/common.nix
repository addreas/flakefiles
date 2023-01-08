{ config, pkgs, lib, ... }:
{
  nix.package = pkgs.nixVersions.stable;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    substituters = [
      "http://sergio.localdomain:${toString config.services.nix-serve.port}"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];

    # to allow nixos-rebuild test --target-host pixie-pie.localdomain --flake .#pixie-pie-host
    trusted-users = [ "root" "@wheel" ];
    secret-key-files = [ "/var/secret/local-nix-secret-key" ];
    # sudo nix-store --generate-binary-cache-key lenny-wsl-0 /var/secret/local-nix-secret-key /dev/stdout >> ./pubkeys.txt
    trusted-public-keys = builtins.filter (l: l != "") (lib.strings.splitString "\n" (builtins.readFile ./pubkeys.txt));

    max-jobs = lib.mkDefault 1;
  };


  nix.gc.automatic = true;
  nix.gc.dates = "weekly";

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


  environment.systemPackages = with pkgs; [
    zsh
    vim
    wget
    curl
    git
    cntr
  ];

  programs.command-not-found.enable = false;

  users.defaultUserShell = pkgs.zsh;
}

