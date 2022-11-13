{ pkgs, ... }: {
  imports = [
    ../../packages/kube
  ];

  services.kubeadm.kubelet = {
    enable = false;
    package = pkgs.kubernetes;
  };

  environment.systemPackages = [ pkgs.kubernetes ];
}
