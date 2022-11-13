{ pkgs, lib, config, ... }:
let
  cfg = config.services.kubeadm;
in
{
  config = lib.mkIf cfg.enable {
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
        Slice = "kubernetes.slice";
        CPUAccounting = true;
        MemoryAccounting = true;

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
