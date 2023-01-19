{ pkgs, config, ... }: {
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

  services.avahi.reflector = true;
  services.openiscsi.enable = true;
  services.openiscsi.name = "iqn.2023-01.se.addem.nucles:${config.networking.hostName}";
}
