{ pkgs, ... }:
let
  version = "1.25.7";
  sha256 = "sha256-5rL6VwlKiwdjpNTYwqCsXEpZYTYhb6B5+0kzWjQh8ow=";
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
          WHAT = "cmd/kubeadm cmd/kubelet";
        });
    })
  ];
}
