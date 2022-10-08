{ pkgs, lib, config, ... }:
let
  cfg = config.services.kubeadm.kubelet;
in
{
  options.services.kubeadm.kubelet = {
    enable = lib.mkEnableOption "kubelet";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kubernetes;
    };
    controlPlane = lib.mkEnableOption "control ports";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "br_netfilter" ];
    boot.kernel.sysctl = {
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.ipv4.ip_forward" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    networking.firewall.allowedTCPPorts = [
      10250
    ] ++ (if !cfg.controlPlane then [ ] else [
      6443
      2379
      2380
      # 10259
      # 10257
    ]);
    networking.firewall.allowedTCPPortRanges = [{ from = 30000; to = 32767; }];


    systemd.services.kubelet = {
      description = "Kubernetes Kubelet Service";
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [
        gitMinimal
        openssh
        docker
        utillinux
        iproute
        ethtool
        thin-provisioning-tools
        iptables
        socat
        cni
      ];

      unitConfig.StartLimitInterval = 0;
      serviceConfig = {
        StateDirectory = "kubelet";
        ConfiguratonDirectory = "kubernetes";

        EnvironmentFile = "-/var/lib/kubelet/kubeadm-flags.env";

        Restart = "always";
        RestartSec = 10;

        ExecStart = ''
          ${cfg.package}/bin/kubelet \
            --kubeconfig=/etc/kubernetes/kubelet.conf \
            --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf \
            --config=/var/lib/kubelet/config.yaml \
            $KUBELET_KUBEADM_ARGS
        '';
      };
    };
  };

}
