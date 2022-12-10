{ pkgs, ... }: {
  imports = [
    ../../packages/kube
  ];

  services.kubeadm = {
    enable = false;
    package = pkgs.kubernetes;
  };

  services.kubeadm.kubelet = {
    enable = false;
  };

  environment.systemPackages = [ pkgs.kubernetes ];
}
