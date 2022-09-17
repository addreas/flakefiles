{ config, lib, options, pkgs, ... }:

with lib;

let
  top = config.services.k8s;
  cfg = config.services.k8s.controllerManager;

in
{

  ###### interface
  options.services.k8s.controllerManager = options.services.kubernetes.controllerManager;

  ###### implementation
  config = mkIf cfg.enable {
    systemd.services.kube-controller-manager = {
      description = "Kubernetes Controller Manager Service";
      wantedBy = [ "kubernetes.target" ];
      after = [ "kube-apiserver.service" ];
      serviceConfig = {
        RestartSec = "30s";
        Restart = "on-failure";
        Slice = "kubernetes.slice";
        ExecStart = ''${top.package}/bin/kube-controller-manager \
          --allocate-node-cidrs=${boolToString cfg.allocateNodeCIDRs} \
          --bind-address=${cfg.bindAddress} \
          ${optionalString (cfg.clusterCidr!=null)
            "--cluster-cidr=${cfg.clusterCidr}"} \
          ${optionalString (cfg.featureGates != [])
            "--feature-gates=${concatMapStringsSep "," (feature: "${feature}=true") cfg.featureGates}"} \
          --kubeconfig=${top.lib.mkKubeConfig "kube-controller-manager" cfg.kubeconfig} \
          --leader-elect=${boolToString cfg.leaderElect} \
          ${optionalString (cfg.rootCaFile!=null)
            "--root-ca-file=${cfg.rootCaFile}"} \
          --port=${toString cfg.insecurePort} \
          --secure-port=${toString cfg.securePort} \
          ${optionalString (cfg.serviceAccountKeyFile!=null)
            "--service-account-private-key-file=${cfg.serviceAccountKeyFile}"} \
          ${optionalString (cfg.tlsCertFile!=null)
            "--tls-cert-file=${cfg.tlsCertFile}"} \
          ${optionalString (cfg.tlsKeyFile!=null)
            "--tls-private-key-file=${cfg.tlsKeyFile}"} \
          ${optionalString (elem "RBAC" top.apiserver.authorizationMode)
            "--use-service-account-credentials"} \
          ${optionalString (cfg.verbosity != null) "--v=${toString cfg.verbosity}"} \
          ${cfg.extraOpts}
        '';
        WorkingDirectory = top.dataDir;
        User = "kubernetes";
        Group = "kubernetes";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      path = top.path;
    };

    services.k8s.controllerManager.kubeconfig.server = mkDefault top.apiserverAddress;
  };

  meta.buildDocsInSandbox = false;

}
