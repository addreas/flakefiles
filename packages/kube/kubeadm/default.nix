{ pkgs, lib, config, ... }:
let
  cfg = config.services.kubeadm;

  kubeadmConfig = pkgs.writeText "kubeadm.yaml" (
      lib.strings.concatMapStringsSep
      "---"
      lib.generators.toYAML
      [
        cfg.init.initConfig
        cfg.init.clusterConfig
        cfg.init.kubeletConfig
        cfg.init.proxyConfig
      ]
    );
in
{
  imports = [
    ./config.nix
    ./kubelet.nix
  ];

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
      # idk why i have these 
      # "net.bridge.bridge-nf-call-iptables" = 1;
      # "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    # systemd.tmpfiles.rules = [
    #   "d /opt/cni/bin 0755 root root -"
    #   "d /run/kubernetes 0755 kubernetes kubernetes -"
    #   "d /var/lib/kubernetes 0755 kubernetes kubernetes -"
    # ];

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

    systemd.services.kubeadm-init = lib.mkIf (cfg.init.enable && cfg.controlPlane) {
      description = "kubeadm init";

      path = with pkgs; [
        gitMinimal
        openssh
        docker
        utillinux
        iproute
        ethtool
        thin-provisioning-tools
        iptables
        nftables
        socat
        cni
        cri-tools
        conntrack-tools
        cfg.package
      ];

      serviceConfig.Type = "oneshot";
      unitConfig.ConditionPathExists = "!/etc/kubernetes";

      script = ''
        if ! ${pkgs.curl}/bin/curl --insecure https://${cfg.init.clusterConfig.controlPlaneEndpoint}; then
          ${cfg.package}/bin/kubeadm init --config ${kubeadmConfig}
        end
      '';

      wantedBy = [ "kubelet.service" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.services.kubeadm-join = lib.mkIf (cfg.init.enable) {
      description = "kubeadm join";

      path = with pkgs; [
        gitMinimal
        openssh
        docker
        utillinux
        iproute
        ethtool
        thin-provisioning-tools
        iptables
        nftables
        socat
        cni
        cri-tools
        conntrack-tools
        cfg.package
      ];

      serviceConfig.Type = "oneshot";
      unitConfig.ConditionPathExists = "!/etc/kubernetes";

      script = ''
        ${cfg.package}/bin/kubeadm join ${cfg.init.clusterConfig.controlPlaneEndpoint} \
          --v=5 \
          --token $(cat ${cfg.init.bootstrapTokenFile}) \
          --discovery-token-unsafe-skip-ca-verification \
          ${lib.strings.optionalString (cfg.controlPlane && cfg.init.certificateKeyFile) ''
            --control-plane \
            --certificate-key $(cat ${cfg.init.certificateKeyFile})
            ''}
      '';

      wantedBy = [ "kubelet.service" ];
      after = [ "network-online.target" ] ++ (lib.lists.optionals cfg.controlPlane ["kubeadm-init.service"]);
      wants = [ "network-online.target" ];
    };


    systemd.services.kubeadm-upgrade = {
      description = "kubeadm upgrade";

      path = with pkgs; [
        gitMinimal
        openssh
        docker
        utillinux
        iproute
        ethtool
        thin-provisioning-tools
        iptables
        nftables
        socat
        cni
        cri-tools
        conntrack-tools
        cfg.package
      ];

      serviceConfig.Type = "oneshot";
      unitConfig.ConditionPathExists = "/etc/kubernetes";

      script = let
        kubeadm = "${cfg.package}/bin/kubeadm";
        kubectl = "${cfg.package}/bin/kubectl";
        jd = "${pkgs.jd-diff-patch}/bin/jd";
      in
      if cfg.controlPlane
      then ''
        KUBEADM_CONFIG_TARGET_VERSION=$(${kubectl} get cm -n kube-system kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep kubernetesVersion | cut -d" " -f2)
        KUBEADM_CLI_VERSION=$(${kubeadm} version -o short)
        KUBE_APISERVER_MANIFEST_VERSION=$(cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep image: | cut -d: -f3)
        if [[ "$KUBEADM_CONFIG_TARGET_VERSION" != "$KUBEADM_CLI_VERSION" ]]; then
            ${kubeadm} upgrade plan $KUBEADM_CLI_VERSION --config ${kubeadmConfig} \
            && ${kubeadm} upgrade apply $KUBEADM_CLI_VERSION --config ${kubeadmConfig} --yes
        elif [[ "$KUBEADM_CONFIG_TARGET_VERSION" != "$KUBE_APISERVER_MANIFEST_VERSION" ]]; then
            ${kubeadm} upgrade node $KUBEADM_CONFIG_TARGET_VERSION
        fi
        ''
      else ''
        KUBEADM_CONFIG_TARGET_VERSION=$(${kubectl} get cm -n kube-system kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep kubernetesVersion | cut -d" " -f2)
        ${kubeadm} upgrade node $KUBEADM_CONFIG_TARGET_VERSION
        '';

      wantedBy = [ "kubelet.service" ];
      after = [ "network-online.target" "kubelet.service" ] ++ (lib.lists.optionals cfg.init (["kubeadm-join.service"] ++ (lib.lists.optionals cfg.controlPlane ["kubeadm-init.service"]));
      wants = [ "network-online.target" ];
    };

  };
}
