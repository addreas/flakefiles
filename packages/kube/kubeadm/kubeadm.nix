{ pkgs, lib, config, ... }:
let
  cfg = config.services.kubeadm;

  cp_upgrade = ''
    KUBEADM_CONFIG_TARGET_VERSION=$(kubectl get cm -n kube-system kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep kubernetesVersion | cut -d" " -f2)
    KUBEADM_CLI_VERSION=$(kubeadm version -o short)
    KUBE_APISERVER_MANIFEST_VERSION=$(cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep image: | cut -d: -f3)
    if [[ "$KUBEADM_CONFIG_TARGET_VERSION" != "$KUBEADM_CLI_VERSION" ]]; then
        kubeadm upgrade plan $KUBEADM_CLI_VERSION \
        && kubeadm upgrade apply $KUBEADM_CLI_VERSION
    elif [[ "$KUBEADM_CONFIG_TARGET_VERSION" != "$KUBE_APISERVER_MANIFEST_VERSION" ]]; then
        kubeadm upgrade node $KUBEADM_CONFIG_TARGET_VERSION
    fi
    '';

  worker_upgrade = ''
    KUBEADM_CONFIG_TARGET_VERSION=$(kubectl get cm -n kube-system kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep kubernetesVersion | cut -d" " -f2)
    if [[ "$KUBEADM_CONFIG_TARGET_VERSION" != "$KUBELET_VERSION" ]]; then
      kubeadm upgrade node $KUBEADM_CONFIG_TARGET_VERSION
    fi
    '';
in
{
  options.services.kubeadm = {
    enable = lib.mkEnableOption "kubeadm";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kubernetes;
    };
    controlPlane = lib.mkEnableOption "control plane";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "br_netfilter" ];

    boot.kernel.sysctl = {
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.ipv4.ip_forward" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    systemd.tmpfiles.rules = [
      "d /opt/cni/bin 0755 root root -"
      "d /run/kubernetes 0755 kubernetes kubernetes -"
      "d /var/lib/kubernetes 0755 kubernetes kubernetes -"
    ];

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
  };
}
