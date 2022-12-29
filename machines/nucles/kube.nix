{ pkgs, ... }: {
  imports = [
    ../../packages/kube
  ];

  services.kubeadm = {
    enable = true;
    package = pkgs.kubernetes;
    kubelet.enable = true;

    init.initConfig = {
      clusterName = "nucles";
      controlPlaneEndpoint = "nucles.localdomain:6443";
      apiServer = {
        certSANs = [
          "nucles.localdomain"
          "sergio.localdomain"
          "nucle1.localdomain"
          "nucle2.localdomain"
          "nucle3.localdomain"
        ];
        extraArgs.feature-gates = "MixedProtocolLBService=true";
      };
    };
    init.kubeletConfig = {
      allowedUnsafeSysctls = [
        "net.ipv4.conf.all.src_valid_mark"
      ];
    };
  };

  environment.systemPackages = [ pkgs.kubernetes ];
}
