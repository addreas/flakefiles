{ config, lib, options, pkgs, ... }:

with lib;

let
  top = config.services.k8s;
  cfg = config.services.k8s.apiserver;

  apiserverServiceIP = (concatStringsSep "."
    (
      take 3 (splitString "." cfg.serviceClusterIpRange
      )
    ) + ".1");
in
{

  ###### interface
  options.services.k8s.apiserver = removeAttrs options.services.kubernetes.apiserver [ "extraSANs" ];

  ###### implementation
  config = mkMerge [

    (mkIf cfg.enable {
      systemd.services.kube-apiserver = {
        description = "Kubernetes APIServer Service";
        wantedBy = [ "kubernetes.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Slice = "kubernetes.slice";
          ExecStart = ''${top.package}/bin/kube-apiserver \
              --allow-privileged=${boolToString cfg.allowPrivileged} \
              --authorization-mode=${concatStringsSep "," cfg.authorizationMode} \
                ${optionalString (elem "ABAC" cfg.authorizationMode)
                  "--authorization-policy-file=${
                    pkgs.writeText "kube-auth-policy.jsonl"
                    (concatMapStringsSep "\n" (l: builtins.toJSON l) cfg.authorizationPolicy)
                  }"
                } \
                ${optionalString (elem "Webhook" cfg.authorizationMode)
                  "--authorization-webhook-config-file=${cfg.webhookConfig}"
                } \
              --bind-address=${cfg.bindAddress} \
              ${optionalString (cfg.advertiseAddress != null)
                "--advertise-address=${cfg.advertiseAddress}"} \
              ${optionalString (cfg.clientCaFile != null)
                "--client-ca-file=${cfg.clientCaFile}"} \
              --disable-admission-plugins=${concatStringsSep "," cfg.disableAdmissionPlugins} \
              --enable-admission-plugins=${concatStringsSep "," cfg.enableAdmissionPlugins} \
              --etcd-servers=${concatStringsSep "," cfg.etcd.servers} \
              ${optionalString (cfg.etcd.caFile != null)
                "--etcd-cafile=${cfg.etcd.caFile}"} \
              ${optionalString (cfg.etcd.certFile != null)
                "--etcd-certfile=${cfg.etcd.certFile}"} \
              ${optionalString (cfg.etcd.keyFile != null)
                "--etcd-keyfile=${cfg.etcd.keyFile}"} \
              ${optionalString (cfg.featureGates != [])
                "--feature-gates=${concatMapStringsSep "," (feature: "${feature}=true") cfg.featureGates}"} \
              ${optionalString (cfg.basicAuthFile != null)
                "--basic-auth-file=${cfg.basicAuthFile}"} \
              ${optionalString (cfg.kubeletClientCaFile != null)
                "--kubelet-certificate-authority=${cfg.kubeletClientCaFile}"} \
              ${optionalString (cfg.kubeletClientCertFile != null)
                "--kubelet-client-certificate=${cfg.kubeletClientCertFile}"} \
              ${optionalString (cfg.kubeletClientKeyFile != null)
                "--kubelet-client-key=${cfg.kubeletClientKeyFile}"} \
              ${optionalString (cfg.preferredAddressTypes != null)
                "--kubelet-preferred-address-types=${cfg.preferredAddressTypes}"} \
              ${optionalString (cfg.proxyClientCertFile != null)
                "--proxy-client-cert-file=${cfg.proxyClientCertFile}"} \
              ${optionalString (cfg.proxyClientKeyFile != null)
                "--proxy-client-key-file=${cfg.proxyClientKeyFile}"} \
              --insecure-bind-address=${cfg.insecureBindAddress} \
              --insecure-port=${toString cfg.insecurePort} \
              ${optionalString (cfg.runtimeConfig != "")
                "--runtime-config=${cfg.runtimeConfig}"} \
              --secure-port=${toString cfg.securePort} \
              --api-audiences=${toString cfg.apiAudiences} \
              --service-account-issuer=${toString cfg.serviceAccountIssuer} \
              --service-account-signing-key-file=${cfg.serviceAccountSigningKeyFile} \
              --service-account-key-file=${cfg.serviceAccountKeyFile} \
              --service-cluster-ip-range=${cfg.serviceClusterIpRange} \
              --storage-backend=${cfg.storageBackend} \
              ${optionalString (cfg.tlsCertFile != null)
                "--tls-cert-file=${cfg.tlsCertFile}"} \
              ${optionalString (cfg.tlsKeyFile != null)
                "--tls-private-key-file=${cfg.tlsKeyFile}"} \
              ${optionalString (cfg.tokenAuthFile != null)
                "--token-auth-file=${cfg.tokenAuthFile}"} \
              ${optionalString (cfg.verbosity != null) "--v=${toString cfg.verbosity}"} \
              ${cfg.extraOpts}
            '';
          WorkingDirectory = top.dataDir;
          User = "kubernetes";
          Group = "kubernetes";
          AmbientCapabilities = "cap_net_bind_service";
          Restart = "on-failure";
          RestartSec = 5;
        };

        unitConfig = {
          StartLimitIntervalSec = 0;
        };
      };

      services.etcd = {
        clientCertAuth = mkDefault true;
        peerClientCertAuth = mkDefault true;
        listenClientUrls = mkDefault [ "https://0.0.0.0:2379" ];
        listenPeerUrls = mkDefault [ "https://0.0.0.0:2380" ];
        advertiseClientUrls = mkDefault [ "https://${top.masterAddress}:2379" ];
        initialCluster = mkDefault [ "${top.masterAddress}=https://${top.masterAddress}:2380" ];
        name = mkDefault top.masterAddress;
        initialAdvertisePeerUrls = mkDefault [ "https://${top.masterAddress}:2380" ];
      };
    })

  ];

  meta.buildDocsInSandbox = false;
}
