{ pkgs, ... }:
let
  kubernetes = pkgs.kubernetes;
in
{
  imports = [
    ../../packages/kubeadm/kubelet.nix
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
