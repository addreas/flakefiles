{ pkgs, ... }: {
  imports = [
    ../../packages/kube
  ];

  services.kubeadm.kubelet = {
    enable = true;
    package = pkgs.kubernetes;
  };

  environment.systemPackages = [ pkgs.kubernetes ];
}
