{ config, lib, options, pkgs, ... }:

with lib;

let
  cfg = config.services.k8s;

  apiEndpoint = "nucles.localdomain";
  secretDir = "/var/lib/kubernetes/secret";
  pkiDir = "${secretDir}/pki";
  certEncryptionKey = "cert-encryption-key";

  masterSetup = ''
    kubeadm init phase certs all --cert-dir ${pkiDir} --control-plane-endpoint ${apiEndpoint} --apiserver-cert-extra-sans `hostname`.localdomain
    kubeadm init phase kubeconfig all --cert-dir ${pkiDir} --kubeconfig-dir ${secretDir} --control-plane-endpoint ${apiEndpoint}

    kubeadm init phase upload-certs --upload-certs --certificate-key ${certEncryptionKey} --cert-dir ${pkiDir} --kubeconfig ${secretDir}/admin.conf
    kubeadm init phase bootstrap-token
  '';

  controlPlaneJoin = ''
    kubeadm join phase control-plane-prepare download-certs --control-plane
    kubeadm join phase control-plane-prepare certs --control-plane
  '';

  workerJoin = ''
    kubeadm join phase preflight
  '';

in
{
  ###### interface
  options.services.k8s = (removeAttrs options.services.kubernetes [
    "roles"
    "easyCerts"
    "scheduler"
    "proxy"
    "controllerManager"
    "apiserver"
    "kubelet"
  ]) // {
    enable = mkEnableOption "kubernetes";
  };


  ###### implementation
  config = mkIf cfg.enable {
    systemd.targets.kubernetes = {
      description = "Kubernetes";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d /opt/cni/bin 0755 root root -"
      "d /run/kubernetes 0755 kubernetes kubernetes -"
      "d /var/lib/kubernetes 0755 kubernetes kubernetes -"
    ];

    users.users.kubernetes = {
      uid = config.ids.uids.kubernetes;
      description = "Kubernetes user";
      group = "kubernetes";
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.kubernetes.gid = config.ids.gids.kubernetes;

    services.k8s.apiserverAddress = mkDefault (
      "https://${if cfg.apiserver.advertiseAddress != null
            then cfg.apiserver.advertiseAddress
            else "${cfg.masterAddress}:${toString cfg.apiserver.securePort}"}"
    );

  };

  meta.buildDocsInSandbox = false;
}
