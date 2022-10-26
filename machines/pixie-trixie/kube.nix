{ pkgs, ... }:
let
  kubernetes = pkgs.kubernetes;
in
{
  imports = [
    ../../packages/kubeadm/kubelet.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      kubernetes = super.kubernetes.overrideAttrs
        (oldAttrs: rec {
          version = "1.24.5";
          src = pkgs.fetchFromGitHub {
            owner = "kubernetes";
            repo = "kubernetes";
            rev = "v${version}";
            sha256 = "sha256-8fEn2ac6bzqRtDbMzs7ZuUKfaLaJZuPoLQ3LZ/lnmTo=";
          };

        });
    })
  ];


  virtualisation.cri-o = {
    enable = true;
    storageDriver = "btrfs";
    settings.crio.network.plugins_dir = [ "${pkgs.cni-plugins}/bin" "/opt/cni/bin" ];

    # sudo mkdir /var/lib/crio
  };

  services.kubeadm.kubelet = {
    enable = true;
    package = kubernetes;
  };

  environment.systemPackages = [
    kubernetes
  ];
}
