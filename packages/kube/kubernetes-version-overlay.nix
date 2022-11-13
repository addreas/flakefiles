{ pkgs, ... }:
let
  version = "1.24.5";
  sha256 = "sha256-8fEn2ac6bzqRtDbMzs7ZuUKfaLaJZuPoLQ3LZ/lnmTo=";
in
{
  config.nixpkgs.overlays = [
    (self: super: {
      kubernetes = super.kubernetes.overrideAttrs
        (oldAttrs: {
          inherit version;
          src = pkgs.fetchFromGitHub {
            inherit sha256;
            owner = "kubernetes";
            repo = "kubernetes";
            rev = "v${version}";
          };
        });
    })
  ];
}
