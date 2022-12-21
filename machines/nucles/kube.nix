{ pkgs, ... }: {
  imports = [
    ../../packages/kube
  ];

  services.kubeadm = {
    enable = true;
    package = pkgs.kubernetes;
    kubelet.enable = true;
  };

  environment.systemPackages = [ pkgs.kubernetes ];
}
