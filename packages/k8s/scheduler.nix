{ config, lib, options, pkgs, ... }:

with lib;

let
  top = config.services.k8s;
  cfg = config.services.k8s.scheduler;
in
{
  ###### interface
  options.services.k8s.scheduler = options.services.kubernetes.scheduler;

  ###### implementation
  config = mkIf cfg.enable {
    systemd.services.kube-scheduler = {
      description = "Kubernetes Scheduler Service";
      wantedBy = [ "kubernetes.target" ];
      after = [ "kube-apiserver.service" ];
      serviceConfig = {
        Slice = "kubernetes.slice";
        ExecStart = ''${top.package}/bin/kube-scheduler \
          --bind-address=${cfg.address} \
          ${optionalString (cfg.featureGates != [])
            "--feature-gates=${concatMapStringsSep "," (feature: "${feature}=true") cfg.featureGates}"} \
          --kubeconfig=${top.lib.mkKubeConfig "kube-scheduler" cfg.kubeconfig} \
          --leader-elect=${boolToString cfg.leaderElect} \
          --secure-port=${toString cfg.port} \
          ${optionalString (cfg.verbosity != null) "--v=${toString cfg.verbosity}"} \
          ${cfg.extraOpts}
        '';
        WorkingDirectory = top.dataDir;
        User = "kubernetes";
        Group = "kubernetes";
        Restart = "on-failure";
        RestartSec = 5;
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
    };


    services.k8s.scheduler.kubeconfig.server = mkDefault top.apiserverAddress;
  };

  meta.buildDocsInSandbox = false;

}
