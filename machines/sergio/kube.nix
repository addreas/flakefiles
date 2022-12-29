{ pkgs, ... }: {
  imports = [
    ../../packages/kube
  ];

  services.kubeadm = {
    enable = true;
    package = pkgs.kubernetes;
    kubelet.enable = true;
    init = {
      enable = true;
      bootstrapTokenFile = "/tmp/kube-bootstrap-token";
      clusterConfig.controlPlaneEndpoint = "nucles.localdomain:6443";
    };
  };

  environment.systemPackages = [ pkgs.kubernetes ];
}
