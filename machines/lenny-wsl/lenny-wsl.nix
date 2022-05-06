{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  defaultUser = "addem";
  syschdemd = import ./wsl/syschdemd.nix { inherit lib pkgs config defaultUser; };
  zshFastHighlight = (pkgs.zsh-fast-syntax-highlighting.overrideAttrs (_: {
    installPhase = ''
      plugindir="$out/share/zsh/plugins/fast-syntax-highlighting"
      mkdir -p "$plugindir"
      cp -r -- {,_,-,.}fast-* *chroma themes "$plugindir"/
    '';
  })
  );
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    "./wsl/module.nix"
    #"/home/addem/cockpit/module.nix"
    #"/home/addem/pcp/module.nix"
  ];


  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nix_2_7
    extraOptions = ''
      experimental-features = nix-command flakes

      extra-sandbox-paths = /nix/var/cache/ccache
    '';
  };

  users.defaultUserShell = pkgs.zsh;

  users.users.${defaultUser} = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    fzf-zsh
    zshFastHighlight
  ];

  programs.zsh.enable = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.theme = "arrow";
  programs.zsh.ohMyZsh.customPkgs = [ zshFastHighlight ];
  programs.zsh.ohMyZsh.plugins = [
    "git"
    "command-not-found"
    "colored-man-pages"
    "fzf"
  ];

  #services.cockpit.enable = true;
  #services.pcp.enable = true;
}
