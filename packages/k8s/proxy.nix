{ config, lib, options, pkgs, ... }:

with lib;

let
  top = config.services.k8s;
  cfg = config.services.k8s.proxy;
in
{
  ###### interface
  options.services.k8s.proxy = options.services.kubernetes.proxy;

  ###### implementation
  config = mkIf cfg.enable {
    systemd.services.kube-proxy = {
      description = "Kubernetes Proxy Service";
      wantedBy = [ "kubernetes.target" ];
      after = [ "kube-apiserver.service" ];
      path = with pkgs; [ iptables conntrack-tools ];
      serviceConfig = {
        Slice = "kubernetes.slice";
        ExecStart = ''${top.package}/bin/kube-proxy \
          --bind-address=${cfg.bindAddress} \
          ${optionalString (top.clusterCidr!=null)
            "--cluster-cidr=${top.clusterCidr}"} \
          ${optionalString (cfg.featureGates != [])
            "--feature-gates=${concatMapStringsSep "," (feature: "${feature}=true") cfg.featureGates}"} \
          --hostname-override=${cfg.hostname} \
          --kubeconfig=${top.lib.mkKubeConfig "kube-proxy" cfg.kubeconfig} \
          ${optionalString (cfg.verbosity != null) "--v=${toString cfg.verbosity}"} \
          ${cfg.extraOpts}
        '';
        WorkingDirectory = top.dataDir;
        Restart = "on-failure";
        RestartSec = 5;
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
    };

    services.k8s.proxy.hostname = with config.networking; mkDefault hostName;

    services.k8s.proxy.kubeconfig.server = mkDefault top.apiserverAddress;
  };

  meta.buildDocsInSandbox = false;
}
