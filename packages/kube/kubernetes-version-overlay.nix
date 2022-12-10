{ pkgs, ... }:
let
  version = "1.24.9";
  sha256 = "sha256-/RFCNjbDM+kNPm7sbJjtZGBO9RD3F61Un3gjPZqzH9s=";
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
