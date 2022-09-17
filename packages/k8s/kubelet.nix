{ config, lib, options, pkgs, ... }:

with lib;

let
  top = config.services.k8s;
  cfg = config.services.k8s.kubelet;

  kubeletconfig = pkgs.writeText "kubelet-config"
    (builtins.toJSON
      ({
        kind = "KubeletConfiguration";
        apiVersion = "kubelet.config.k8s.io/v1beta1";
        authentication = {
          anonymous.enabled = false;
          webhook.cacheTTL = "10s";
          webhook.enabled = true;
          x509.clientCAFile = cfg.clientCaFile;
        };
        authorization = {
          mode = "Webhook";
          webhook.cacheAuthorizedTTL = "0s";
          webhook.cacheUnauthorizedTTL = "0s";
        };
        cgroupDriver = "systemd";
        clusterDNS = [ cfg.clusterDns ];
        clusterDomain = cfg.clusterDomain;
        healthzBindAddress = cfg.healthz.bind;
        healthzPort = cfg.healthz.port;
        logging = {
          flushFrequency = 0;
          options.json = {
            splitStream = true;
            infoBufferSize = "0";
          };
          verbosity = cfg.verbosity;
        };
        rotateCertificates = true;
        staticPodPath = "/etc/${manifestPath}";

        registerNode = cfg.registerNode;
        registerWithTaints = cfg.taints;

        tlsCertFile = cfg.tlsCertFile;
        tlsKeyFile = cfg.tlsKeyFile;

        port = cfg.port;
        address = cfg.address;

        hairpinMode = "hairpin-veth";

        featureGates = listToAttrs (map (x: { name = x; value = true; }) cfg.featureGates);
      } // cfg.extraConfig));

  manifestPath = "kubernetes/manifests";
in
{

  ###### interface
  options.services.k8s.kubelet = with lib.types; options.services.kubernetes.kubelet // {
    cni = {
      configDir = mkOption {
        description = lib.mdDoc "Path to Kubernetes CNI configuration directory.";
        type = nullOr path;
        default = null;
      };
    };
    enable = mkEnableOption (lib.mdDoc "Kubernetes kubelet.");
    extraConfig = mkOption {
      description = lib.mdDoc "Kubernetes kubelet extra kubelet config.";
      default = { };
      type = attrs;
    };
    kubeconfig = mkOption {
      description = lib.mdDoc "Path to kubeconfig for the kubelet";
      type = path;
      default = "${top.secretsPath}/kubelet.conf";
    };

  };

  ###### implementation
  config = mkMerge [
    (mkIf cfg.enable {
      boot.kernel.sysctl = {
        "net.bridge.bridge-nf-call-iptables" = 1;
        "net.ipv4.ip_forward" = 1;
        "net.bridge.bridge-nf-call-ip6tables" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };

      systemd.services.kubelet = {
        description = "Kubernetes Kubelet Service";
        wantedBy = [ "kubernetes.target" ];
        after = [ "cri-o.service" "network.target" "kube-apiserver.service" ];
        path = with pkgs; [
          gitMinimal
          openssh
          util-linux
          iproute2
          ethtool
          thin-provisioning-tools
          iptables
          socat
        ] ++ lib.optional config.boot.zfs.enabled config.boot.zfs.package ++ top.path;
        serviceConfig = {
          Slice = "kubernetes.slice";
          CPUAccounting = true;
          MemoryAccounting = true;
          Restart = "on-failure";
          RestartSec = "1000ms";
          ExecStart = ''${top.package}/bin/kubelet \
            --kubeconfig=${cfg.kubeconfig} \
            --config=${kubeletconfig} \
            --hostname-override=${cfg.hostname} \
            --root-dir=${top.dataDir} \
            --pod-infra-container-image=pause \
            --container-runtime=${cfg.containerRuntime} \
            --container-runtime-endpoint=${cfg.containerRuntimeEndpoint} \
            ${optionalString (cfg.nodeIp != null)
              "--node-ip=${cfg.nodeIp}"} \
            ${optionalString (cfg.verbosity != null) "--v=${toString cfg.verbosity}"} \
            ${cfg.extraOpts}
          '';
          WorkingDirectory = top.dataDir;
        };
        unitConfig.StartLimitIntervalSec = 0;
      };

      boot.kernelModules = [ "br_netfilter" "overlay" ];

      services.k8s.kubelet.hostname = with config.networking;
        mkDefault (hostName + optionalString (domain != null) ".${domain}");

      services.k8s.kubelet.kubeconfig.server = mkDefault top.apiserverAddress;
    })

    (mkIf (cfg.enable && cfg.manifests != { }) {
      environment.etc = mapAttrs'
        (name: manifest:
          nameValuePair "${manifestPath}/${name}.json" {
            text = builtins.toJSON manifest;
            mode = "0755";
          }
        )
        cfg.manifests;
    })

    (mkIf (cfg.unschedulable && cfg.enable) {
      services.k8s.kubelet.taints.unschedulable = {
        value = "true";
        effect = "NoSchedule";
      };
    })

  ];

  meta.buildDocsInSandbox = false;
}
