let
  pkgs = import <nixpkgs> {};
in
(pkgs.buildFHSEnv {
  name = "python-fuckery";
  multiPkgs = pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs;
  targetPkgs = pkgs: with pkgs; [
    python312
    uv
  ];
}).env

