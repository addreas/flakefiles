{ pkgs, ... }:
let
  # kubernetes = pkgs.kubernetes.overrideAttrs (_: rec {
  #   version = "1.24.5";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "kubernetes";
  #     repo = "kubernetes";
  #     rev = "v${version}";
  #     sha256 = "sha256-8fEn2ac6bzqRtDbMzs7ZuUKfaLaJZuPoLQ3LZ/lnmTo=";
  #   };
  # });
  kubernetes = pkgs.kubernetes;
in
{
  virtualisation.cri-o = {
    enable = true;
    storageDriver = "btrfs";
    settings.crio.network.plugins_dir = [ "${pkgs.cni-plugins}/bin" "/opt/cni/bin" ];

    # sudo mkdir /var/lib/crio
  };

  services.kubeadm.kubelet = {
    enable = false;
    package = kubernetes;
  };

  environment.systemPackages = [
    kubernetes
  ];
}
