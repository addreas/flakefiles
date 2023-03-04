{ pkgs, ... }:
let
  version = "1.24.11";
  sha256 = "sha256-BsCgGRXEs2v1mjIOxGoKjy3tprXG1EmMSKLxp4O7aug=";
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
