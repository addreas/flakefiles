{ pkgs, lib, config, ... }:
let
  subType = description: options: lib.types.submodule { inherit options; };
  opt = type: description: lib.mkOption { inherit type description; };
  mkStrDefault = str: lib.mkOption {
    type = lib.types.str;
    default = str;
  };

  duration = lib.types.str; # TODO: regex for metav1.Duration

  Taint = with lib.types; subType {
    effect = opt str "The effect of the taint on pods that do not tolerate the taint. Valid effects are NoSchedule, PreferNoSchedule and NoExecute. Possible enum values: - `\" NoExecute \"` Evict any already-running pods that do not tolerate the taint. Currently enforced by NodeController. - `\" NoSchedule \"` Do not allow new pods to schedule onto the node unless they tolerate the taint, but allow all pods submitted to Kubelet without going through the scheduler to start, and allow all already-running pods to continue running. Enforced by the scheduler. - `\" PreferNoSchedule \"` Like TaintEffectNoSchedule, but the scheduler tries not to schedule new pods onto the node, rather than prohibiting new pods from scheduling onto the node entirely. Enforced by the scheduler.";
    key = opt str "The taint key to be applied to a node.";
    timeAdded = opt str "TimeAdded represents the time at which the taint was added. It is only written for NoExecute taints.";
    value = opt str "The taint value corresponding to the taint key";
  };
  BootstrapToken = with lib.types; subType {
    token = opt str "token is used for establishing bidirectional trust between nodes and control-planes. Used for joining nodes in the cluster.";
    description = opt str "description sets a human-friendly message why this token exists and what it's used for, so other administrators can know its purpose.";
    ttl = opt str "ttl defines the time to live for this token. Defaults to 24h. expires and ttl are mutually exclusive.";
    expires = opt str "expires specifies the timestamp when this token expires. Defaults to being set dynamically at runtime based on the ttl. expires and ttl are mutually exclusive.";
    usages = opt (listOf str) "usages describes the ways in which this token can be used. Can by default be used for establishing bidirectional trust, but that can be changed here.";
    groups = opt (listOf str) "groups specifies the extra groups that this token will authenticate as when/if used for authentication";
  };
  NodeRegistrationOptions = with lib.types; subType {
    name = opt str "name is the .metadata.name field of the Node API object that will be created in this kubeadm init or kubeadm join operation. This field is also used in the CommonName field of the kubelet's client certificate to the API server. Defaults to the hostname of the node if not provided.";
    criSocket = opt str "criSocket is used to retrieve container runtime info. This information will be annotated to the Node API object, for later re-use";
    taints = listOpt Taint "taints specifies the taints the Node API object should be registered with. If this field is unset, i.e. nil, in the kubeadm init process it will be defaulted with a control-plane taint for control-plane nodes. If you don't want to taint your control-plane node, set this field to an empty list, i.e. taints: [] in the YAML file. This field is solely used for Node registration.";
    kubeletExtraArgs = opt (attrsOf str) "kubeletExtraArgs passes through extra arguments to the kubelet. The arguments here are passed to the kubelet command line via the environment file kubeadm writes at runtime for the kubelet to source. This overrides the generic base-level configuration in the 'kubelet-config-1.X' ConfigMap. Flags have higher priority when parsing. These values are local and specific to the node kubeadm is executing on. A key in this map is the flag name as it appears on the command line except without leading dash(es).";
    imagePullPolicy = opt (enum [ "Always" "IfNotPresent" "Never" ]) "imagePullPolicy specifies the policy for image pulling during kubeadm \"init\" and \"join\" operations. The value of this field must be one of \"Always\", \"IfNotPresent\" or \"Never\". If this field is unset kubeadm will default it to \"IfNotPresent\", or pull the required images if not present on the host.";
  };
  APIEndpoint = with lib.types; subType {
    advertiseAddress = opt str "advertiseAddress sets the IP address for the API server to advertise.";
    bindPort = opt int "bindPort sets the secure port for the API Server to bind to. Defaults to 6443.";
  };
  Patches = with lib.types; subType {
    directory = opt str "directory is a path to a directory that contains files named \"target[suffix][+patchtype].extension\". For example, \"kube-apiserver0+merge.yaml\" or just \"etcd.json\". \"target\" can be one of \"kube-apiserver\", \"kube-controller-manager\", \"kube-scheduler\", \"etcd\". \"patchtype\" can be one of \"strategic\" \"merge\" or \"json\" and they match the patch formats supported by kubectl. The default \"patchtype\" is \"strategic\". \"extension\" must be either \"json\" or \"yaml\". \"suffix\" is an optional string that can be used to determine which patches are applied first alpha-numerically.";
  };
  ImageMeta = with lib.types; subType {
    imageRepository = opt str "imageRepository sets the container registry to pull images from. If not set, the imageRepository defined in ClusterConfiguration will be used instead.";
    imageTag = opt str "imageTag allows to specify a tag for the image. In case this value is set, kubeadm does not change automatically the version of the above components during upgrades.";
  };
  Etcd = with lib.types; either
    (subType { local = opt LocalEtcd "local provides configuration knobs for configuring the local etcd instance. local and external are mutually exclusive."; })
    (subType { external = opt ExternalEtcd "external describes how to connect to an external etcd cluster. local and external are mutually exclusive."; });
  LocalEtcd = with lib.types; submodule {
    imports = [ ImageMeta ];
    options = {
      dataDir = opt str "dataDir is the directory etcd will place its data. Defaults to " /var/lib/etcd ".";
      extraArgs = opt (attrsOf str) "extraArgs are extra arguments provided to the etcd binary when run inside a static Pod. A key in this map is the flag name as it appears on the command line except without leading dash(es).";
      serverCertSANs = opt (listOf str) "serverCertSANs sets extra Subject Alternative Names (SANs) for the etcd server signing certificate.";
      peerCertSANs = opt (listOf str) "peerCertSANs sets extra Subject Alternative Names (SANs) for the etcd peer signing certificate.";
    };
  };
  ExternalEtcd = with lib.types; subType {
    endpoints = opt (listOf str) "endpoints contains the list of etcd members.";
    caFile = opt str "caFile is an SSL Certificate Authority (CA) file used to secure etcd communication. Required if using a TLS connection.";
    certFile = opt str "certFile is an SSL certification file used to secure etcd communication. Required if using a TLS connection.";
    keyFile = opt str "keyFile is an SSL key file used to secure etcd communication. Required if using a TLS connection.";
  };
  Networking = with lib.types; subType {
    serviceSubnet = opt str "serviceSubnet is the subnet used by Kubernetes Services. Defaults to \"10.96.0.0/12\".";
    podSubnet = opt str "podSubnet is the subnet used by Pods.";
    dnsDomain = opt str "dnsDomain is the DNS domain used by Kubernetes Services. Defaults to \"cluster.local\".";
  };
  HostPathMount = with lib.types; subType {
    name = opt str "[Required] name is the name of the volume inside the Pod template.";
    hostPath = opt str "[Required] hostPath is the path in the host that will be mounted inside the Pod.";
    mountPath = opt str "[Required] mountPath is the path inside the Pod where hostPath will be mounted.";
    readOnly = opt bool "readOnly controls write access to the volume.";
    pathType = opt str "pathType is the type of the hostPath.";
  };
  ControlPlaneComponent = with lib.types; subType {
    extraArgs = opt (attrsOf str) "extraArgs is an extra set of flags to pass to the control plane component. A key in this map is the flag name as it appears on the command line except without leading dash(es).";
    extraVolumes = opt (listOf HostPathMount) "extraVolumes is an extra set of host volumes, mounted to the control plane component.";
  };
  APIServer = with lib.types; submodule {
    imports = [ ControlPlaneComponent ];
    options = {
      certSANs = opt (listOf str) "certSANs sets extra Subject Alternative Names (SANs) for the API Server signing certificate.";
      timeoutForControlPlane = opt str "timeoutForControlPlane controls the timeout that we wait for API server to appear.";
    };
  };
  DNS = with lib.types; submodule { imports = [ ImageMeta ]; };
in
{
  options.services.kubeadm.init = with lib; with lib.types;
    {
      enable = mkEnableOption "kubeadm init";
      bootstrapTokenFile = mkOption {
        type = path;
        description = "Should contain the output from `kubeadm token create`";
      };
      certificateKeyFile = mkOption {
        type = path;
        description = "Should contain the output from `kubeadm init phase upload-certs --upload-certs`";
      };

      initConfig = opt (subType {
        apiVersion = mkStrDefault "kubeadm.k8s.io/v1beta3";
        kind = mkStrDefault "InitConfiguration";

        bootstrapTokens = opt (listOf BootstrapToken) "bootstrapTokens is respected at kubeadm init time and describes a set of Bootstrap Tokens to create. This information IS NOT uploaded to the kubeadm cluster configmap, partly because of its sensitive nature";
        nodeRegistration = opt NodeRegistrationOptions "nodeRegistration holds fields that relate to registering the new control-plane node to the cluster.";
        localAPIEndpoint = opt APIEndpoint "localAPIEndpoint represents the endpoint of the API server instance that's deployed on this control plane node. In HA setups, this differs from ClusterConfiguration.controlPlaneEndpoint in the sense that controlPlaneEndpoint is the global endpoint for the cluster, which then load-balances the requests to each individual API server. This configuration object lets you customize what IP/DNS name and port the local API server advertises it's accessible on. By default, kubeadm tries to auto-detect the IP of the default interface and use that, but in case that process fails you may set the desired value here.";
        certificateKey = opt str "certificateKey sets the key with which certificates and keys are encrypted prior to being uploaded in a Secret in the cluster during the uploadcerts init phase.";
        skipPhases = opt (listOf str) "skipPhases is a list of phases to skip during command execution. The list of phases can be obtained with the kubeadm init --help command. The flag \"--skip-phases\" takes precedence over this field.";
        patches = opt Patches "patches contains options related to applying patches to components deployed by kubeadm during kubeadm init.";
      }) "InitConfiguration";

      clusterConfig = opt (subType {
        apiVersion = mkStrDefault "kubeadm.k8s.io/v1beta3";
        kind = mkStrDefault "ClusterConfiguration";

        etcd = opt Etcd "etcd holds the configuration for etcd.";
        networking = opt Networking "networking holds configuration for the networking topology of the cluster.";
        kubernetesVersion = opt str "kubernetesVersion is the target version of the control plane.";
        controlPlaneEndpoint = opt str ''
          controlPlaneEndpoint sets a stable IP address or DNS name for the control plane. It can be a valid IP address or a RFC-1123 DNS subdomain, both with optional TCP port. In case the controlPlaneEndpoint is not specified, the advertiseAddress + bindPort are used; in case the controlPlaneEndpoint is specified but without a TCP port, the bindPort is used. Possible usages are:

              In a cluster with more than one control plane instances, this field should be assigned the address of the external load balancer in front of the control plane instances.
              In environments with enforced node recycling, the controlPlaneEndpoint could be used for assigning a stable DNS to the control plane.
        '';
        apiServer = opt APIServer "apiServer contains extra settings for the API server.";
        controllerManager = opt ControlPlaneComponent "controllerManager contains extra settings for the controller manager.";
        scheduler = opt ControlPlaneComponent "scheduler contains extra settings for the scheduler.";
        dns = opt DNS "dns defines the options for the DNS add-on installed in the cluster.";
        certificatesDir = opt str "certificatesDir specifies where to store or look for all required certificates.";
        imageRepository = opt str "imageRepository sets the container registry to pull images from. If empty, registry.k8s.io will be used by default. In case of kubernetes version is a CI build (kubernetes version starts with ci/) gcr.io/k8s-staging-ci-images will be used as a default for control plane components and for kube-proxy, while registry.k8s.io will be used for all the other images.";
        featureGates = opt (attrsOf bool) "featureGates contains the feature gates enabled by the user.";
        clusterName = opt str "The cluster name.";
      }) "ClusterConfiguration";

      proxyConfig = opt (subType {
        apiVersion = mkStrDefault "kubeproxy.config.k8s.io/v1alpha1";
        kind = mkStrDefault "KubeProxyConfiguration";

        #  TODO: automate this ffs
      }) "KubeProxyConfiguration";

      kubeletConfig = opt (subType {
        apiVersion = mkStrDefault "kubelet.config.k8s.io/v1beta1";
        kind = mkStrDefault "KubeletConfiguration";

        enableServer = opt bool "enableServer enables Kubelet's secured server. Note: Kubelet's insecure port is controlled by the readOnlyPort option. Default: true";
        staticPodPath = opt str "staticPodPath is the path to the directory containing local (static) pods to run, or the path to a single static pod file. Default: \"\"";
        syncFrequency = opt duration "syncFrequency is the max period between synchronizing running containers and config. Default: \"1m\"";
        fileCheckFrequency = opt duration "fileCheckFrequency is the duration between checking config files for new data. Default: \"20s\""
        httpCheckFrequency = opt duration "httpCheckFrequency is the duration between checking http for new data. Default: \"20s\"";
        staticPodURL = opt str "staticPodURL is the URL for accessing static pods to run. Default: \"\"";
        staticPodURLHeader = opt (attrsOf (list str)) "staticPodURLHeader is a map of slices with HTTP headers to use when accessing the podURL. Default: nil";
        address = opt str "address is the IP address for the Kubelet to serve on (set to 0.0.0.0 for all interfaces). Default: \"0.0.0.0\"";
        port = opt int "port is the port for the Kubelet to serve on. The port number must be between 1 and 65535, inclusive. Default: 10250";
        readOnlyPort = opt int "readOnlyPort is the read-only port for the Kubelet to serve on with no authentication/authorization. The port number must be between 1 and 65535, inclusive. Setting this field to 0 disables the read-only service. Default: 0 (disabled)";
        tlsCertFile = opt str "tlsCertFile is the file containing x509 Certificate for HTTPS. (CA cert, if any, concatenated after server cert). If tlsCertFile and tlsPrivateKeyFile are not provided, a self-signed certificate and key are generated for the public address and saved to the directory passed to the Kubelet's --cert-dir flag. Default: \"\"";
        tlsPrivateKeyFile = opt str "tlsPrivateKeyFile is the file containing x509 private key matching tlsCertFile. Default: \"\"";
        tlsCipherSuites = opt (listOf str) "";
        tlsMinVersion = opt str "";
        rotateCertificates = opt bool "";
        serverTLSBootstrap = opt bool "";
        authentication = opt KubeletAuthentication "";
        authorization = opt KubeletAuthorization "";
        registryPullQPS = opt int "";
        registryBurst = opt int "";
        eventRecordQPS = opt int "";
        eventBurst = opt int "";
        enableDebuggingHandlers = opt bool "";
        enableContentionProfiling = opt bool "";
        healthzPort = opt int "";
        healthzBindAddress = opt int "";
        oomScoreAdj = opt int "";
        clusterDomain = opt str "";
        clusterDNS = opt (listOf str) "";
        streamingConnectionIdleTimout = opt duration "";
        nodeStatusUpdateFrequency = opt duration "";
        nodeStatusReportFrequency = opt duration "";
        nodeLeaseDurationSeconds = opt int "";
        imageMinimumGCAge = opt duration "";
        imageGCHighThresholdPercent = opt int "";
        imageGCLowThresholdPercent = opt int "";
        volumeStatsAggPeriod = opt duration "";
        kubeletCgroups = opt str "";
        systemCgroups = opt str "";
        cgroupRoot = opt str "";
        cgroupsPerQOS = opt bool "";
        cgroupDriver = opt str "";
        cpuManagerPolicy = opt str "";
        cpuManagerPolicyOptions = opt (attrsOf str) "";
        cpuManagerReconcilePeriod = opt duration "";
        memoryManagerPolicy = opt str "";
        topologyManagerPolicy = opt (enum ["restricted" "best-effort" "none" "single-numa-node"]) "";
        topologyManagerScope = opt (enum ["container" "pod"]) "";
        topologyManagerPolicyOptio = opt (attrsOf str) "";
        qosReserved = opt (attrsOf str) "";
        runtimeRequestTimeout = opt duration "";
        hairpinMode = opt (enum ["promiscuous-bridge" "hairpin-veth" "none"]) "";
        maxPods = opt int "";
        podCIDR = opt str "";
        podPidsLimit = opt int "";
        resolvConf = opt str "";
        runOnce = opt bool "";
        cpuCFSQuota = opt bool "";
        cpuCFSQuotaPeriod = opt duration "";
        nodeStatusMaxImages = opt int "";
        maxOpenFiles = opt int "";
        contentType = opt str "";
        kubeAPIQPS = opt int "";
        kubeAPIBurst = opt int "";
        serializeImagePulls = opt bool "";
        evictionHard = opt (attrsOf str) "";
        evictionSoft = opt (attrsOf str) "";
        evictionSoftGracePeriod = opt (attrsOf str) "";
        evictionPressureTransitionPeriod = opt duration "";
        evictionMaxPodGracePeriod = opt int "";
        evictionMinimumReclaim = opt (attrsOf str) "";
        podsPerCore = opt int "";
        enableControllerAttachDetach = opt bool "";
        protectKernelDefaults = opt bool "";
        makeIPTablesUtilChains = opt bool "";
        iptablesMasqueradeBit = opt int "";
        iptablesDropBit = opt int "";
        featureGates = opt (attrsOf bool) "";
        failSwapOn = opt bool "";
        memorySwap = opt MemorySwapConfiguration "";
        containerLogMaxSize = opt string "";
        containerLogMaxFiles = opt int "";
        configMapAndSecretChangeDetectionStrategy = opt (enum ["Get" "Cache" "Watch"]) "";
        systemReserved = opt (attrsOf str) "";
        kubeReserved = opt (attrsOf str) "";
        reservedSystemCPUs = opt str "";
        showHiddenMetricsForVersion = opt str "";
        systemReservedCgroup = opt str "";
        kubeReservedCgroup = opt str "";
        enforceNodeAllocatable = opt (listOf str) "";
        allowedUnsafeSysctls = opt (listOf str) "";
        volumePluginDir = opt str "";
        providerID = opt str "";
        kernelMemcgNotification = opt bool "";
        logging = opt LoggingConfiguration "";
        enableSystemLogHandler = opt bool "";
        shutdownGracePeriod = opt duration "";
        shutdownGracePeriodCriticalPods = opt duration "";
        shutdownGracePeriodByPodPriority = opt (listOf ShutdownGracePeriodByPodPriority) "";
        reservedMemory = opt (listOf MemoryReservation) "";
        enableProfilingHandler = opt bool "";
        enableDebugFlagsHandler = opt bool "";
        seccompDefault = opt bool "";
        memoryThrottlingFactor = opt float "";
        registerWithTaints = opt (listOf Taint) "";
        registerNode = opt bool "";
        tracing = opt TracingConfiguration "";
        localStorageCapacityIsolation = opt bool "";
      }) "KubeletConfiguration";
    };
}
