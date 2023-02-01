{ lib, ... }:
let
  duration = lib.types.str; # TODO: regex for metav1.Duration
in with lib.types; rec {
  CredentialProviderConfig = lib.mkOption {
    description = ''
      CredentialProviderConfig is the configuration containing information about
      each exec credential provider. Kubelet reads this configuration from disk and enables
      each provider as specified by the CredentialProvider type.
      '';
    type = submodule {
      options = {
        providers = mkOption {
          description = ''
            providers is a list of credential provider plugins that will be enabled by the kubelet.
            Multiple providers may match against a single image, in which case credentials
            from all providers will be returned to the kubelet. If multiple providers are called
            for a single image, the results are combined. If providers return overlapping
            auth keys, the value from the provider earlier in this list is used.
            '';
          type = (listOf CredentialProvider);
        };
      };
    };
  };
  KubeletConfiguration = lib.mkOption {
    description = ''
      KubeletConfiguration contains the configuration for the Kubelet
      '';
    type = submodule {
      options = {
        enableServer = mkOption {
          description = ''
            enableServer enables Kubelet's secured server.
            Note: Kubelet's insecure port is controlled by the readOnlyPort option.
            Default: true
            '';
          type = bool;
        };
        staticPodPath = mkOption {
          description = ''
            staticPodPath is the path to the directory containing local (static) pods to
            run, or the path to a single static pod file.
            Default: ""
            '';
          type = str;
        };
        syncFrequency = mkOption {
          description = ''
            syncFrequency is the max period between synchronizing running
            containers and config.
            Default: "1m"
            '';
          type = duration;
        };
        fileCheckFrequency = mkOption {
          description = ''
            fileCheckFrequency is the duration between checking config files for
            new data.
            Default: "20s"
            '';
          type = duration;
        };
        httpCheckFrequency = mkOption {
          description = ''
            httpCheckFrequency is the duration between checking http for new data.
            Default: "20s"
            '';
          type = duration;
        };
        staticPodURL = mkOption {
          description = ''
            staticPodURL is the URL for accessing static pods to run.
            Default: ""
            '';
          type = str;
        };
        staticPodURLHeader = mkOption {
          description = ''
            staticPodURLHeader is a map of slices with HTTP headers to use when accessing the podURL.
            Default: nil
            '';
          type = (attrsOf (listOf str));
        };
        address = mkOption {
          description = ''
            address is the IP address for the Kubelet to serve on (set to 0.0.0.0
            for all interfaces).
            Default: "0.0.0.0"
            '';
          type = str;
        };
        port = mkOption {
          description = ''
            port is the port for the Kubelet to serve on.
            The port number must be between 1 and 65535, inclusive.
            Default: 10250
            '';
          type = int;
        };
        readOnlyPort = mkOption {
          description = ''
            readOnlyPort is the read-only port for the Kubelet to serve on with
            no authentication/authorization.
            The port number must be between 1 and 65535, inclusive.
            Setting this field to 0 disables the read-only service.
            Default: 0 (disabled)
            '';
          type = int;
        };
        tlsCertFile = mkOption {
          description = ''
            tlsCertFile is the file containing x509 Certificate for HTTPS. (CA cert,
            if any, concatenated after server cert). If tlsCertFile and
            tlsPrivateKeyFile are not provided, a self-signed certificate
            and key are generated for the public address and saved to the directory
            passed to the Kubelet's --cert-dir flag.
            Default: ""
            '';
          type = str;
        };
        tlsPrivateKeyFile = mkOption {
          description = ''
            tlsPrivateKeyFile is the file containing x509 private key matching tlsCertFile.
            Default: ""
            '';
          type = str;
        };
        tlsCipherSuites = mkOption {
          description = ''
            tlsCipherSuites is the list of allowed cipher suites for the server.
            Values are from tls package constants (https://golang.org/pkg/crypto/tls/#pkg-constants).
            Default: nil
            '';
          type = (listOf str);
        };
        tlsMinVersion = mkOption {
          description = ''
            tlsMinVersion is the minimum TLS version supported.
            Values are from tls package constants (https://golang.org/pkg/crypto/tls/#pkg-constants).
            Default: ""
            '';
          type = str;
        };
        rotateCertificates = mkOption {
          description = ''
            rotateCertificates enables client certificate rotation. The Kubelet will request a
            new certificate from the certificates.k8s.io API. This requires an approver to approve the
            certificate signing requests.
            Default: false
            '';
          type = bool;
        };
        serverTLSBootstrap = mkOption {
          description = ''
            serverTLSBootstrap enables server certificate bootstrap. Instead of self
            signing a serving certificate, the Kubelet will request a certificate from
            the 'certificates.k8s.io' API. This requires an approver to approve the
            certificate signing requests (CSR). The RotateKubeletServerCertificate feature
            must be enabled when setting this field.
            Default: false
            '';
          type = bool;
        };
        authentication = mkOption {
          description = ''
            authentication specifies how requests to the Kubelet's server are authenticated.
            Defaults:
              anonymous:
                enabled: false
              webhook:
                enabled: true
                cacheTTL: "2m"
            '';
          type = KubeletAuthentication;
        };
        authorization = mkOption {
          description = ''
            authorization specifies how requests to the Kubelet's server are authorized.
            Defaults:
              mode: Webhook
              webhook:
                cacheAuthorizedTTL: "5m"
                cacheUnauthorizedTTL: "30s"
            '';
          type = KubeletAuthorization;
        };
        registryPullQPS = mkOption {
          description = ''
            registryPullQPS is the limit of registry pulls per second.
            The value must not be a negative number.
            Setting it to 0 means no limit.
            Default: 5
            '';
          type = int;
        };
        registryBurst = mkOption {
          description = ''
            registryBurst is the maximum size of bursty pulls, temporarily allows
            pulls to burst to this number, while still not exceeding registryPullQPS.
            The value must not be a negative number.
            Only used if registryPullQPS is greater than 0.
            Default: 10
            '';
          type = int;
        };
        eventRecordQPS = mkOption {
          description = ''
            eventRecordQPS is the maximum event creations per second. If 0, there
            is no limit enforced. The value cannot be a negative number.
            Default: 5
            '';
          type = int;
        };
        eventBurst = mkOption {
          description = ''
            eventBurst is the maximum size of a burst of event creations, temporarily
            allows event creations to burst to this number, while still not exceeding
            eventRecordQPS. This field canot be a negative number and it is only used
            when eventRecordQPS > 0.
            Default: 10
            '';
          type = int;
        };
        enableDebuggingHandlers = mkOption {
          description = ''
            enableDebuggingHandlers enables server endpoints for log access
            and local running of containers and commands, including the exec,
            attach, logs, and portforward features.
            Default: true
            '';
          type = bool;
        };
        enableContentionProfiling = mkOption {
          description = ''
            enableContentionProfiling enables lock contention profiling, if enableDebuggingHandlers is true.
            Default: false
            '';
          type = bool;
        };
        healthzPort = mkOption {
          description = ''
            healthzPort is the port of the localhost healthz endpoint (set to 0 to disable).
            A valid number is between 1 and 65535.
            Default: 10248
            '';
          type = int;
        };
        healthzBindAddress = mkOption {
          description = ''
            healthzBindAddress is the IP address for the healthz server to serve on.
            Default: "127.0.0.1"
            '';
          type = str;
        };
        oomScoreAdj = mkOption {
          description = ''
            oomScoreAdj is The oom-score-adj value for kubelet process. Values
            must be within the range [-1000, 1000].
            Default: -999
            '';
          type = int;
        };
        clusterDomain = mkOption {
          description = ''
            clusterDomain is the DNS domain for this cluster. If set, kubelet will
            configure all containers to search this domain in addition to the
            host's search domains.
            Default: ""
            '';
          type = str;
        };
        clusterDNS = mkOption {
          description = ''
            clusterDNS is a list of IP addresses for the cluster DNS server. If set,
            kubelet will configure all containers to use this for DNS resolution
            instead of the host's DNS servers.
            Default: nil
            '';
          type = (listOf str);
        };
        streamingConnectionIdleTimeout = mkOption {
          description = ''
            streamingConnectionIdleTimeout is the maximum time a streaming connection
            can be idle before the connection is automatically closed.
            Default: "4h"
            '';
          type = duration;
        };
        nodeStatusUpdateFrequency = mkOption {
          description = ''
            nodeStatusUpdateFrequency is the frequency that kubelet computes node
            status. If node lease feature is not enabled, it is also the frequency that
            kubelet posts node status to master.
            Note: When node lease feature is not enabled, be cautious when changing the
            constant, it must work with nodeMonitorGracePeriod in nodecontroller.
            Default: "10s"
            '';
          type = duration;
        };
        nodeStatusReportFrequency = mkOption {
          description = ''
            nodeStatusReportFrequency is the frequency that kubelet posts node
            status to master if node status does not change. Kubelet will ignore this
            frequency and post node status immediately if any change is detected. It is
            only used when node lease feature is enabled. nodeStatusReportFrequency's
            default value is 5m. But if nodeStatusUpdateFrequency is set explicitly,
            nodeStatusReportFrequency's default value will be set to
            nodeStatusUpdateFrequency for backward compatibility.
            Default: "5m"
            '';
          type = duration;
        };
        nodeLeaseDurationSeconds = mkOption {
          description = ''
            nodeLeaseDurationSeconds is the duration the Kubelet will set on its corresponding Lease.
            NodeLease provides an indicator of node health by having the Kubelet create and
            periodically renew a lease, named after the node, in the kube-node-lease namespace.
            If the lease expires, the node can be considered unhealthy.
            The lease is currently renewed every 10s, per KEP-0009. In the future, the lease renewal
            interval may be set based on the lease duration.
            The field value must be greater than 0.
            Default: 40
            '';
          type = int;
        };
        imageMinimumGCAge = mkOption {
          description = ''
            imageMinimumGCAge is the minimum age for an unused image before it is
            garbage collected.
            Default: "2m"
            '';
          type = duration;
        };
        imageGCHighThresholdPercent = mkOption {
          description = ''
            imageGCHighThresholdPercent is the percent of disk usage after which
            image garbage collection is always run. The percent is calculated by
            dividing this field value by 100, so this field must be between 0 and
            100, inclusive. When specified, the value must be greater than
            imageGCLowThresholdPercent.
            Default: 85
            '';
          type = int;
        };
        imageGCLowThresholdPercent = mkOption {
          description = ''
            imageGCLowThresholdPercent is the percent of disk usage before which
            image garbage collection is never run. Lowest disk usage to garbage
            collect to. The percent is calculated by dividing this field value by 100,
            so the field value must be between 0 and 100, inclusive. When specified, the
            value must be less than imageGCHighThresholdPercent.
            Default: 80
            '';
          type = int;
        };
        volumeStatsAggPeriod = mkOption {
          description = ''
            volumeStatsAggPeriod is the frequency for calculating and caching volume
            disk usage for all pods.
            Default: "1m"
            '';
          type = duration;
        };
        kubeletCgroups = mkOption {
          description = ''
            kubeletCgroups is the absolute name of cgroups to isolate the kubelet in
            Default: ""
            '';
          type = str;
        };
        systemCgroups = mkOption {
          description = ''
            systemCgroups is absolute name of cgroups in which to place
            all non-kernel processes that are not already in a container. Empty
            for no container. Rolling back the flag requires a reboot.
            The cgroupRoot must be specified if this field is not empty.
            Default: ""
            '';
          type = str;
        };
        cgroupRoot = mkOption {
          description = ''
            cgroupRoot is the root cgroup to use for pods. This is handled by the
            container runtime on a best effort basis.
            '';
          type = str;
        };
        cgroupsPerQOS = mkOption {
          description = ''
            cgroupsPerQOS enable QoS based CGroup hierarchy: top level CGroups for QoS classes
            and all Burstable and BestEffort Pods are brought up under their specific top level
            QoS CGroup.
            Default: true
            '';
          type = bool;
        };
        cgroupDriver = mkOption {
          description = ''
            cgroupDriver is the driver kubelet uses to manipulate CGroups on the host (cgroupfs
            or systemd).
            Default: "cgroupfs"
            '';
          type = str;
        };
        cpuManagerPolicy = mkOption {
          description = ''
            cpuManagerPolicy is the name of the policy to use.
            Requires the CPUManager feature gate to be enabled.
            Default: "None"
            '';
          type = str;
        };
        cpuManagerPolicyOptions = mkOption {
          description = ''
            cpuManagerPolicyOptions is a set of key=value which 	allows to set extra options
            to fine tune the behaviour of the cpu manager policies.
            Requires  both the "CPUManager" and "CPUManagerPolicyOptions" feature gates to be enabled.
            Default: nil
            '';
          type = (attrsOf str);
        };
        cpuManagerReconcilePeriod = mkOption {
          description = ''
            cpuManagerReconcilePeriod is the reconciliation period for the CPU Manager.
            Requires the CPUManager feature gate to be enabled.
            Default: "10s"
            '';
          type = duration;
        };
        memoryManagerPolicy = mkOption {
          description = ''
            memoryManagerPolicy is the name of the policy to use by memory manager.
            Requires the MemoryManager feature gate to be enabled.
            Default: "none"
            '';
          type = str;
        };
        topologyManagerPolicy = mkOption {
          description = ''
            topologyManagerPolicy is the name of the topology manager policy to use.
            Valid values include:
            
            - `restricted`: kubelet only allows pods with optimal NUMA node alignment for
              requested resources;
            - `best-effort`: kubelet will favor pods with NUMA alignment of CPU and device
              resources;
            - `none`: kubelet has no knowledge of NUMA alignment of a pod's CPU and device resources.
            - `single-numa-node`: kubelet only allows pods with a single NUMA alignment
              of CPU and device resources.
            
            Policies other than "none" require the TopologyManager feature gate to be enabled.
            Default: "none"
            '';
          type = str;
        };
        topologyManagerScope = mkOption {
          description = ''
            topologyManagerScope represents the scope of topology hint generation
            that topology manager requests and hint providers generate. Valid values include:
            
            - `container`: topology policy is applied on a per-container basis.
            - `pod`: topology policy is applied on a per-pod basis.
            
            "pod" scope requires the TopologyManager feature gate to be enabled.
            Default: "container"
            '';
          type = str;
        };
        topologyManagerPolicyOptions = mkOption {
          description = ''
            TopologyManagerPolicyOptions is a set of key=value which allows to set extra options
            to fine tune the behaviour of the topology manager policies.
            Requires  both the "TopologyManager" and "TopologyManagerPolicyOptions" feature gates to be enabled.
            Default: nil
            '';
          type = (attrsOf str);
        };
        qosReserved = mkOption {
          description = ''
            qosReserved is a set of resource name to percentage pairs that specify
            the minimum percentage of a resource reserved for exclusive use by the
            guaranteed QoS tier.
            Currently supported resources: "memory"
            Requires the QOSReserved feature gate to be enabled.
            Default: nil
            '';
          type = (attrsOf str);
        };
        runtimeRequestTimeout = mkOption {
          description = ''
            runtimeRequestTimeout is the timeout for all runtime requests except long running
            requests - pull, logs, exec and attach.
            Default: "2m"
            '';
          type = duration;
        };
        hairpinMode = mkOption {
          description = ''
            hairpinMode specifies how the Kubelet should configure the container
            bridge for hairpin packets.
            Setting this flag allows endpoints in a Service to loadbalance back to
            themselves if they should try to access their own Service. Values:
            
            - "promiscuous-bridge": make the container bridge promiscuous.
            - "hairpin-veth":       set the hairpin flag on container veth interfaces.
            - "none":               do nothing.
            
            Generally, one must set `--hairpin-mode=hairpin-veth to` achieve hairpin NAT,
            because promiscuous-bridge assumes the existence of a container bridge named cbr0.
            Default: "promiscuous-bridge"
            '';
          type = str;
        };
        maxPods = mkOption {
          description = ''
            maxPods is the maximum number of Pods that can run on this Kubelet.
            The value must be a non-negative integer.
            Default: 110
            '';
          type = int;
        };
        podCIDR = mkOption {
          description = ''
            podCIDR is the CIDR to use for pod IP addresses, only used in standalone mode.
            In cluster mode, this is obtained from the control plane.
            Default: ""
            '';
          type = str;
        };
        podPidsLimit = mkOption {
          description = ''
            podPidsLimit is the maximum number of PIDs in any pod.
            Default: -1
            '';
          type = int;
        };
        resolvConf = mkOption {
          description = ''
            resolvConf is the resolver configuration file used as the basis
            for the container DNS resolution configuration.
            If set to the empty string, will override the default and effectively disable DNS lookups.
            Default: "/etc/resolv.conf"
            '';
          type = str;
        };
        runOnce = mkOption {
          description = ''
            runOnce causes the Kubelet to check the API server once for pods,
            run those in addition to the pods specified by static pod files, and exit.
            Default: false
            '';
          type = bool;
        };
        cpuCFSQuota = mkOption {
          description = ''
            cpuCFSQuota enables CPU CFS quota enforcement for containers that
            specify CPU limits.
            Default: true
            '';
          type = bool;
        };
        cpuCFSQuotaPeriod = mkOption {
          description = ''
            cpuCFSQuotaPeriod is the CPU CFS quota period value, `cpu.cfs_period_us`.
            The value must be between 1 ms and 1 second, inclusive.
            Requires the CustomCPUCFSQuotaPeriod feature gate to be enabled.
            Default: "100ms"
            '';
          type = duration;
        };
        nodeStatusMaxImages = mkOption {
          description = ''
            nodeStatusMaxImages caps the number of images reported in Node.status.images.
            The value must be greater than -2.
            Note: If -1 is specified, no cap will be applied. If 0 is specified, no image is returned.
            Default: 50
            '';
          type = int;
        };
        maxOpenFiles = mkOption {
          description = ''
            maxOpenFiles is Number of files that can be opened by Kubelet process.
            The value must be a non-negative number.
            Default: 1000000
            '';
          type = int;
        };
        contentType = mkOption {
          description = ''
            contentType is contentType of requests sent to apiserver.
            Default: "application/vnd.kubernetes.protobuf"
            '';
          type = str;
        };
        kubeAPIQPS = mkOption {
          description = ''
            kubeAPIQPS is the QPS to use while talking with kubernetes apiserver.
            Default: 5
            '';
          type = int;
        };
        kubeAPIBurst = mkOption {
          description = ''
            kubeAPIBurst is the burst to allow while talking with kubernetes API server.
            This field cannot be a negative number.
            Default: 10
            '';
          type = int;
        };
        serializeImagePulls = mkOption {
          description = ''
            serializeImagePulls when enabled, tells the Kubelet to pull images one
            at a time. We recommend *not* changing the default value on nodes that
            run docker daemon with version  < 1.9 or an Aufs storage backend.
            Issue #10959 has more details.
            Default: true
            '';
          type = bool;
        };
        evictionHard = mkOption {
          description = ''
            evictionHard is a map of signal names to quantities that defines hard eviction
            thresholds. For example: `{"memory.available": "300Mi"}`.
            To explicitly disable, pass a 0% or 100% threshold on an arbitrary resource.
            Default:
              memory.available:  "100Mi"
              nodefs.available:  "10%"
              nodefs.inodesFree: "5%"
              imagefs.available: "15%"
            '';
          type = (attrsOf str);
        };
        evictionSoft = mkOption {
          description = ''
            evictionSoft is a map of signal names to quantities that defines soft eviction thresholds.
            For example: `{"memory.available": "300Mi"}`.
            Default: nil
            '';
          type = (attrsOf str);
        };
        evictionSoftGracePeriod = mkOption {
          description = ''
            evictionSoftGracePeriod is a map of signal names to quantities that defines grace
            periods for each soft eviction signal. For example: `{"memory.available": "30s"}`.
            Default: nil
            '';
          type = (attrsOf str);
        };
        evictionPressureTransitionPeriod = mkOption {
          description = ''
            evictionPressureTransitionPeriod is the duration for which the kubelet has to wait
            before transitioning out of an eviction pressure condition.
            Default: "5m"
            '';
          type = duration;
        };
        evictionMaxPodGracePeriod = mkOption {
          description = ''
            evictionMaxPodGracePeriod is the maximum allowed grace period (in seconds) to use
            when terminating pods in response to a soft eviction threshold being met. This value
            effectively caps the Pod's terminationGracePeriodSeconds value during soft evictions.
            Note: Due to issue #64530, the behavior has a bug where this value currently just
            overrides the grace period during soft eviction, which can increase the grace
            period from what is set on the Pod. This bug will be fixed in a future release.
            Default: 0
            '';
          type = int;
        };
        evictionMinimumReclaim = mkOption {
          description = ''
            evictionMinimumReclaim is a map of signal names to quantities that defines minimum reclaims,
            which describe the minimum amount of a given resource the kubelet will reclaim when
            performing a pod eviction while that resource is under pressure.
            For example: `{"imagefs.available": "2Gi"}`.
            Default: nil
            '';
          type = (attrsOf str);
        };
        podsPerCore = mkOption {
          description = ''
            podsPerCore is the maximum number of pods per core. Cannot exceed maxPods.
            The value must be a non-negative integer.
            If 0, there is no limit on the number of Pods.
            Default: 0
            '';
          type = int;
        };
        enableControllerAttachDetach = mkOption {
          description = ''
            enableControllerAttachDetach enables the Attach/Detach controller to
            manage attachment/detachment of volumes scheduled to this node, and
            disables kubelet from executing any attach/detach operations.
            Note: attaching/detaching CSI volumes is not supported by the kubelet,
            so this option needs to be true for that use case.
            Default: true
            '';
          type = bool;
        };
        protectKernelDefaults = mkOption {
          description = ''
            protectKernelDefaults, if true, causes the Kubelet to error if kernel
            flags are not as it expects. Otherwise the Kubelet will attempt to modify
            kernel flags to match its expectation.
            Default: false
            '';
          type = bool;
        };
        makeIPTablesUtilChains = mkOption {
          description = ''
            makeIPTablesUtilChains, if true, causes the Kubelet ensures a set of iptables rules
            are present on host.
            These rules will serve as utility rules for various components, e.g. kube-proxy.
            The rules will be created based on iptablesMasqueradeBit and iptablesDropBit.
            Default: true
            '';
          type = bool;
        };
        iptablesMasqueradeBit = mkOption {
          description = ''
            iptablesMasqueradeBit is the bit of the iptables fwmark space to mark for SNAT.
            Values must be within the range [0, 31]. Must be different from other mark bits.
            Warning: Please match the value of the corresponding parameter in kube-proxy.
            TODO: clean up IPTablesMasqueradeBit in kube-proxy.
            Default: 14
            '';
          type = int;
        };
        iptablesDropBit = mkOption {
          description = ''
            iptablesDropBit is the bit of the iptables fwmark space to mark for dropping packets.
            Values must be within the range [0, 31]. Must be different from other mark bits.
            Default: 15
            '';
          type = int;
        };
        featureGates = mkOption {
          description = ''
            featureGates is a map of feature names to bools that enable or disable experimental
            features. This field modifies piecemeal the built-in default values from
            "k8s.io/kubernetes/pkg/features/kube_features.go".
            Default: nil
            '';
          type = (attrsOf bool);
        };
        failSwapOn = mkOption {
          description = ''
            failSwapOn tells the Kubelet to fail to start if swap is enabled on the node.
            Default: true
            '';
          type = bool;
        };
        memorySwap = mkOption {
          description = ''
            memorySwap configures swap memory available to container workloads.
            '';
          type = MemorySwapConfiguration;
        };
        containerLogMaxSize = mkOption {
          description = ''
            containerLogMaxSize is a quantity defining the maximum size of the container log
            file before it is rotated. For example: "5Mi" or "256Ki".
            Default: "10Mi"
            '';
          type = str;
        };
        containerLogMaxFiles = mkOption {
          description = ''
            containerLogMaxFiles specifies the maximum number of container log files that can
            be present for a container.
            Default: 5
            '';
          type = int;
        };
        configMapAndSecretChangeDetectionStrategy = mkOption {
          description = ''
            configMapAndSecretChangeDetectionStrategy is a mode in which ConfigMap and Secret
            managers are running. Valid values include:
            
            - `Get`: kubelet fetches necessary objects directly from the API server;
            - `Cache`: kubelet uses TTL cache for object fetched from the API server;
            - `Watch`: kubelet uses watches to observe changes to objects that are in its interest.
            
            Default: "Watch"
            '';
          type = ResourceChangeDetectionStrategy;
        };
        systemReserved = mkOption {
          description = ''
            systemReserved is a set of ResourceName=ResourceQuantity (e.g. cpu=200m,memory=150G)
            pairs that describe resources reserved for non-kubernetes components.
            Currently only cpu and memory are supported.
            See http://kubernetes.io/docs/user-guide/compute-resources for more detail.
            Default: nil
            '';
          type = (attrsOf str);
        };
        kubeReserved = mkOption {
          description = ''
            kubeReserved is a set of ResourceName=ResourceQuantity (e.g. cpu=200m,memory=150G) pairs
            that describe resources reserved for kubernetes system components.
            Currently cpu, memory and local storage for root file system are supported.
            See https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
            for more details.
            Default: nil
            '';
          type = (attrsOf str);
        };
        reservedSystemCPUs = mkOption {
          description = ''
            The reservedSystemCPUs option specifies the CPU list reserved for the host
            level system threads and kubernetes related threads. This provide a "static"
            CPU list rather than the "dynamic" list by systemReserved and kubeReserved.
            This option does not support systemReservedCgroup or kubeReservedCgroup.
            '';
          type = str;
        };
        showHiddenMetricsForVersion = mkOption {
          description = ''
            showHiddenMetricsForVersion is the previous version for which you want to show
            hidden metrics.
            Only the previous minor version is meaningful, other values will not be allowed.
            The format is `<major>.<minor>`, e.g.: `1.16`.
            The purpose of this format is make sure you have the opportunity to notice
            if the next release hides additional metrics, rather than being surprised
            when they are permanently removed in the release after that.
            Default: ""
            '';
          type = str;
        };
        systemReservedCgroup = mkOption {
          description = ''
            systemReservedCgroup helps the kubelet identify absolute name of top level CGroup used
            to enforce `systemReserved` compute resource reservation for OS system daemons.
            Refer to [Node Allocatable](https://git.k8s.io/community/contributors/design-proposals/node/node-allocatable.md)
            doc for more information.
            Default: ""
            '';
          type = str;
        };
        kubeReservedCgroup = mkOption {
          description = ''
            kubeReservedCgroup helps the kubelet identify absolute name of top level CGroup used
            to enforce `KubeReserved` compute resource reservation for Kubernetes node system daemons.
            Refer to [Node Allocatable](https://git.k8s.io/community/contributors/design-proposals/node/node-allocatable.md)
            doc for more information.
            Default: ""
            '';
          type = str;
        };
        enforceNodeAllocatable = mkOption {
          description = ''
            This flag specifies the various Node Allocatable enforcements that Kubelet needs to perform.
            This flag accepts a list of options. Acceptable options are `none`, `pods`,
            `system-reserved` and `kube-reserved`.
            If `none` is specified, no other options may be specified.
            When `system-reserved` is in the list, systemReservedCgroup must be specified.
            When `kube-reserved` is in the list, kubeReservedCgroup must be specified.
            This field is supported only when `cgroupsPerQOS` is set to true.
            Refer to [Node Allocatable](https://git.k8s.io/community/contributors/design-proposals/node/node-allocatable.md)
            for more information.
            Default: ["pods"]
            '';
          type = (listOf str);
        };
        allowedUnsafeSysctls = mkOption {
          description = ''
            A comma separated whitelist of unsafe sysctls or sysctl patterns (ending in `*`).
            Unsafe sysctl groups are `kernel.shm*`, `kernel.msg*`, `kernel.sem`, `fs.mqueue.*`,
            and `net.*`. For example: "`kernel.msg*,net.ipv4.route.min_pmtu`"
            Default: []
            '';
          type = (listOf str);
        };
        volumePluginDir = mkOption {
          description = ''
            volumePluginDir is the full path of the directory in which to search
            for additional third party volume plugins.
            Default: "/usr/libexec/kubernetes/kubelet-plugins/volume/exec/"
            '';
          type = str;
        };
        providerID = mkOption {
          description = ''
            providerID, if set, sets the unique ID of the instance that an external
            provider (i.e. cloudprovider) can use to identify a specific node.
            Default: ""
            '';
          type = str;
        };
        kernelMemcgNotification = mkOption {
          description = ''
            kernelMemcgNotification, if set, instructs the kubelet to integrate with the
            kernel memcg notification for determining if memory eviction thresholds are
            exceeded rather than polling.
            Default: false
            '';
          type = bool;
        };
        logging = mkOption {
          description = ''
            logging specifies the options of logging.
            Refer to [Logs Options](https://github.com/kubernetes/component-base/blob/master/logs/options.go)
            for more information.
            Default:
              Format: text
            '';
          type = LoggingConfiguration;
        };
        enableSystemLogHandler = mkOption {
          description = ''
            enableSystemLogHandler enables system logs via web interface host:port/logs/
            Default: true
            '';
          type = bool;
        };
        shutdownGracePeriod = mkOption {
          description = ''
            shutdownGracePeriod specifies the total duration that the node should delay the
            shutdown and total grace period for pod termination during a node shutdown.
            Default: "0s"
            '';
          type = duration;
        };
        shutdownGracePeriodCriticalPods = mkOption {
          description = ''
            shutdownGracePeriodCriticalPods specifies the duration used to terminate critical
            pods during a node shutdown. This should be less than shutdownGracePeriod.
            For example, if shutdownGracePeriod=30s, and shutdownGracePeriodCriticalPods=10s,
            during a node shutdown the first 20 seconds would be reserved for gracefully
            terminating normal pods, and the last 10 seconds would be reserved for terminating
            critical pods.
            Default: "0s"
            '';
          type = duration;
        };
        shutdownGracePeriodByPodPriority = mkOption {
          description = ''
            shutdownGracePeriodByPodPriority specifies the shutdown grace period for Pods based
            on their associated priority class value.
            When a shutdown request is received, the Kubelet will initiate shutdown on all pods
            running on the node with a grace period that depends on the priority of the pod,
            and then wait for all pods to exit.
            Each entry in the array represents the graceful shutdown time a pod with a priority
            class value that lies in the range of that value and the next higher entry in the
            list when the node is shutting down.
            For example, to allow critical pods 10s to shutdown, priority>=10000 pods 20s to
            shutdown, and all remaining pods 30s to shutdown.
            
            shutdownGracePeriodByPodPriority:
              - priority: 2000000000
                shutdownGracePeriodSeconds: 10
              - priority: 10000
                shutdownGracePeriodSeconds: 20
              - priority: 0
                shutdownGracePeriodSeconds: 30
            
            The time the Kubelet will wait before exiting will at most be the maximum of all
            shutdownGracePeriodSeconds for each priority class range represented on the node.
            When all pods have exited or reached their grace periods, the Kubelet will release
            the shutdown inhibit lock.
            Requires the GracefulNodeShutdown feature gate to be enabled.
            This configuration must be empty if either ShutdownGracePeriod or ShutdownGracePeriodCriticalPods is set.
            Default: nil
            '';
          type = (listOf ShutdownGracePeriodByPodPriority);
        };
        reservedMemory = mkOption {
          description = ''
            reservedMemory specifies a comma-separated list of memory reservations for NUMA nodes.
            The parameter makes sense only in the context of the memory manager feature.
            The memory manager will not allocate reserved memory for container workloads.
            For example, if you have a NUMA0 with 10Gi of memory and the reservedMemory was
            specified to reserve 1Gi of memory at NUMA0, the memory manager will assume that
            only 9Gi is available for allocation.
            You can specify a different amount of NUMA node and memory types.
            You can omit this parameter at all, but you should be aware that the amount of
            reserved memory from all NUMA nodes should be equal to the amount of memory specified
            by the [node allocatable](https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/#node-allocatable).
            If at least one node allocatable parameter has a non-zero value, you will need
            to specify at least one NUMA node.
            Also, avoid specifying:
            
            1. Duplicates, the same NUMA node, and memory type, but with a different value.
            2. zero limits for any memory type.
            3. NUMAs nodes IDs that do not exist under the machine.
            4. memory types except for memory and hugepages-<size>
            
            Default: nil
            '';
          type = (listOf MemoryReservation);
        };
        enableProfilingHandler = mkOption {
          description = ''
            enableProfilingHandler enables profiling via web interface host:port/debug/pprof/
            Default: true
            '';
          type = bool;
        };
        enableDebugFlagsHandler = mkOption {
          description = ''
            enableDebugFlagsHandler enables flags endpoint via web interface host:port/debug/flags/v
            Default: true
            '';
          type = bool;
        };
        seccompDefault = mkOption {
          description = ''
            SeccompDefault enables the use of `RuntimeDefault` as the default seccomp profile for all workloads.
            This requires the corresponding SeccompDefault feature gate to be enabled as well.
            Default: false
            '';
          type = bool;
        };
        memoryThrottlingFactor = mkOption {
          description = ''
            MemoryThrottlingFactor specifies the factor multiplied by the memory limit or node allocatable memory
            when setting the cgroupv2 memory.high value to enforce MemoryQoS.
            Decreasing this factor will set lower high limit for container cgroups and put heavier reclaim pressure
            while increasing will put less reclaim pressure.
            See https://kep.k8s.io/2570 for more details.
            Default: 0.8
            '';
          type = float;
        };
        registerWithTaints = mkOption {
          description = ''
            registerWithTaints are an array of taints to add to a node object when
            the kubelet registers itself. This only takes effect when registerNode
            is true and upon the initial registration of the node.
            Default: nil
            '';
          type = (listOf Taint);
        };
        registerNode = mkOption {
          description = ''
            registerNode enables automatic registration with the apiserver.
            Default: true
            '';
          type = bool;
        };
        tracing = mkOption {
          description = ''
            Tracing specifies the versioned configuration for OpenTelemetry tracing clients.
            See https://kep.k8s.io/2832 for more details.
            '';
          type = TracingConfiguration;
        };
        localStorageCapacityIsolation = mkOption {
          description = ''
            LocalStorageCapacityIsolation enables local ephemeral storage isolation feature. The default setting is true.
            This feature allows users to set request/limit for container's ephemeral storage and manage it in a similar way
            as cpu and memory. It also allows setting sizeLimit for emptyDir volume, which will trigger pod eviction if disk
            usage from the volume exceeds the limit.
            This feature depends on the capability of detecting correct root file system disk usage. For certain systems,
            such as kind rootless, if this capability cannot be supported, the feature LocalStorageCapacityIsolation should be
            disabled. Once disabled, user should not set request/limit for container's ephemeral storage, or sizeLimit for emptyDir.
            Default: true
            '';
          type = bool;
        };
      };
    };
  };
  SerializedNodeConfigSource = lib.mkOption {
    description = ''
      SerializedNodeConfigSource allows us to serialize v1.NodeConfigSource.
      This type is used internally by the Kubelet for tracking checkpointed dynamic configs.
      It exists in the kubeletconfig API group because it is classified as a versioned input to the Kubelet.
      '';
    type = submodule {
      options = {
        source = mkOption {
          description = ''
            source is the source that we are serializing.
            '';
          type = NodeConfigSource;
        };
      };
    };
  };
  CredentialProvider = lib.mkOption {
    description = ''
      CredentialProvider represents an exec plugin to be invoked by the kubelet. The plugin is only
      invoked when an image being pulled matches the images handled by the plugin (see matchImages).
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            name is the required name of the credential provider. It must match the name of the
            provider executable as seen by the kubelet. The executable must be in the kubelet's
            bin directory (set by the --image-credential-provider-bin-dir flag).
            '';
          type = str;
        };
        matchImages = mkOption {
          description = ''
            matchImages is a required list of strings used to match against images in order to
            determine if this provider should be invoked. If one of the strings matches the
            requested image from the kubelet, the plugin will be invoked and given a chance
            to provide credentials. Images are expected to contain the registry domain
            and URL path.
            
            Each entry in matchImages is a pattern which can optionally contain a port and a path.
            Globs can be used in the domain, but not in the port or the path. Globs are supported
            as subdomains like '*.k8s.io' or 'k8s.*.io', and top-level-domains such as 'k8s.*'.
            Matching partial subdomains like 'app*.k8s.io' is also supported. Each glob can only match
            a single subdomain segment, so *.io does not match *.k8s.io.
            
            A match exists between an image and a matchImage when all of the below are true:
            - Both contain the same number of domain parts and each part matches.
            - The URL path of an imageMatch must be a prefix of the target image URL path.
            - If the imageMatch contains a port, then the port must match in the image as well.
            
            Example values of matchImages:
              - 123456789.dkr.ecr.us-east-1.amazonaws.com
              - *.azurecr.io
              - gcr.io
              - *.*.registry.io
              - registry.io:8080/path
            '';
          type = (listOf str);
        };
        defaultCacheDuration = mkOption {
          description = ''
            defaultCacheDuration is the default duration the plugin will cache credentials in-memory
            if a cache duration is not provided in the plugin response. This field is required.
            '';
          type = duration;
        };
        apiVersion = mkOption {
          description = ''
            Required input version of the exec CredentialProviderRequest. The returned CredentialProviderResponse
            MUST use the same encoding version as the input. Current supported values are:
            - credentialprovider.kubelet.k8s.io/v1beta1
            '';
          type = str;
        };
        args = mkOption {
          description = ''
            Arguments to pass to the command when executing it.
            '';
          type = (listOf str);
        };
        env = mkOption {
          description = ''
            Env defines additional environment variables to expose to the process. These
            are unioned with the host's environment, as well as variables client-go uses
            to pass argument to the plugin.
            '';
          type = (listOf ExecEnvVar);
        };
      };
    };
  };
  ExecEnvVar = lib.mkOption {
    description = ''
      ExecEnvVar is used for setting environment variables when executing an exec-based
      credential plugin.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            
            '';
          type = str;
        };
        value = mkOption {
          description = ''
            
            '';
          type = str;
        };
      };
    };
  };
  KubeletAnonymousAuthentication = lib.mkOption {
    description = ''
      
      '';
    type = submodule {
      options = {
        enabled = mkOption {
          description = ''
            enabled allows anonymous requests to the kubelet server.
            Requests that are not rejected by another authentication method are treated as
            anonymous requests.
            Anonymous requests have a username of `system:anonymous`, and a group name of
            `system:unauthenticated`.
            '';
          type = bool;
        };
      };
    };
  };
  KubeletAuthentication = lib.mkOption {
    description = ''
      
      '';
    type = submodule {
      options = {
        x509 = mkOption {
          description = ''
            x509 contains settings related to x509 client certificate authentication.
            '';
          type = KubeletX509Authentication;
        };
        webhook = mkOption {
          description = ''
            webhook contains settings related to webhook bearer token authentication.
            '';
          type = KubeletWebhookAuthentication;
        };
        anonymous = mkOption {
          description = ''
            anonymous contains settings related to anonymous authentication.
            '';
          type = KubeletAnonymousAuthentication;
        };
      };
    };
  };
  KubeletAuthorization = lib.mkOption {
    description = ''
      
      '';
    type = submodule {
      options = {
        mode = mkOption {
          description = ''
            mode is the authorization mode to apply to requests to the kubelet server.
            Valid values are `AlwaysAllow` and `Webhook`.
            Webhook mode uses the SubjectAccessReview API to determine authorization.
            '';
          type = KubeletAuthorizationMode;
        };
        webhook = mkOption {
          description = ''
            webhook contains settings related to Webhook authorization.
            '';
          type = KubeletWebhookAuthorization;
        };
      };
    };
  };
  KubeletAuthorizationMode = lib.mkOption {
    description = ''
      
      '';
  };
  KubeletWebhookAuthentication = lib.mkOption {
    description = ''
      
      '';
    type = submodule {
      options = {
        enabled = mkOption {
          description = ''
            enabled allows bearer token authentication backed by the
            tokenreviews.authentication.k8s.io API.
            '';
          type = bool;
        };
        cacheTTL = mkOption {
          description = ''
            cacheTTL enables caching of authentication results
            '';
          type = duration;
        };
      };
    };
  };
  KubeletWebhookAuthorization = lib.mkOption {
    description = ''
      
      '';
    type = submodule {
      options = {
        cacheAuthorizedTTL = mkOption {
          description = ''
            cacheAuthorizedTTL is the duration to cache 'authorized' responses from the
            webhook authorizer.
            '';
          type = duration;
        };
        cacheUnauthorizedTTL = mkOption {
          description = ''
            cacheUnauthorizedTTL is the duration to cache 'unauthorized' responses from
            the webhook authorizer.
            '';
          type = duration;
        };
      };
    };
  };
  KubeletX509Authentication = lib.mkOption {
    description = ''
      
      '';
    type = submodule {
      options = {
        clientCAFile = mkOption {
          description = ''
            clientCAFile is the path to a PEM-encoded certificate bundle. If set, any request
            presenting a client certificate signed by one of the authorities in the bundle
            is authenticated with a username corresponding to the CommonName,
            and groups corresponding to the Organization in the client certificate.
            '';
          type = str;
        };
      };
    };
  };
  MemoryReservation = lib.mkOption {
    description = ''
      MemoryReservation specifies the memory reservation of different types for each NUMA node
      '';
    type = submodule {
      options = {
        numaNode = mkOption {
          description = ''
            
            '';
          type = int;
        };
        limits = mkOption {
          description = ''
            
            '';
          type = ResourceList;
        };
      };
    };
  };
  MemorySwapConfiguration = lib.mkOption {
    description = ''
      
      '';
    type = submodule {
      options = {
        swapBehavior = mkOption {
          description = ''
            swapBehavior configures swap memory available to container workloads. May be one of
            "", "LimitedSwap": workload combined memory and swap usage cannot exceed pod memory limit
            "UnlimitedSwap": workloads can use unlimited swap, up to the allocatable limit.
            '';
          type = str;
        };
      };
    };
  };
  ResourceChangeDetectionStrategy = lib.mkOption {
    description = ''
      ResourceChangeDetectionStrategy denotes a mode in which internal
      managers (secret, configmap) are discovering object changes.
      '';
  };
  ShutdownGracePeriodByPodPriority = lib.mkOption {
    description = ''
      ShutdownGracePeriodByPodPriority specifies the shutdown grace period for Pods based on their associated priority class value
      '';
    type = submodule {
      options = {
        priority = mkOption {
          description = ''
            priority is the priority value associated with the shutdown grace period
            '';
          type = int;
        };
        shutdownGracePeriodSeconds = mkOption {
          description = ''
            shutdownGracePeriodSeconds is the shutdown grace period in seconds
            '';
          type = int;
        };
      };
    };
  };
  FormatOptions = lib.mkOption {
    description = ''
      FormatOptions contains options for the different logging formats.
      '';
    type = submodule {
      options = {
        json = mkOption {
          description = ''
            [Alpha] JSON contains options for logging format "json".
            Only available when the LoggingAlphaOptions feature gate is enabled.
            '';
          type = JSONOptions;
        };
      };
    };
  };
  JSONOptions = lib.mkOption {
    description = ''
      JSONOptions contains options for logging format "json".
      '';
    type = submodule {
      options = {
        splitStream = mkOption {
          description = ''
            [Alpha] SplitStream redirects error messages to stderr while
            info messages go to stdout, with buffering. The default is to write
            both to stdout, without buffering. Only available when
            the LoggingAlphaOptions feature gate is enabled.
            '';
          type = bool;
        };
        infoBufferSize = mkOption {
          description = ''
            [Alpha] InfoBufferSize sets the size of the info stream when
            using split streams. The default is zero, which disables buffering.
            Only available when the LoggingAlphaOptions feature gate is enabled.
            '';
          type = k8s.io/apimachinery/pkg/api/resource.QuantityValue;
        };
      };
    };
  };
  LogFormatFactory = lib.mkOption {
    description = ''
      LogFormatFactory provides support for a certain additional,
      non-default log format.
      '';
  };
  LoggingConfiguration = lib.mkOption {
    description = ''
      LoggingConfiguration contains logging options.
      '';
    type = submodule {
      options = {
        format = mkOption {
          description = ''
            Format Flag specifies the structure of log messages.
            default value of format is `text`
            '';
          type = str;
        };
        flushFrequency = mkOption {
          description = ''
            Maximum number of nanoseconds (i.e. 1s = 1000000000) between log
            flushes. Ignored if the selected logging backend writes log
            messages without buffering.
            '';
          type = time.Duration;
        };
        verbosity = mkOption {
          description = ''
            Verbosity is the threshold that determines which log messages are
            logged. Default is zero which logs only the most important
            messages. Higher values enable additional messages. Error messages
            are always logged.
            '';
          type = VerbosityLevel;
        };
        vmodule = mkOption {
          description = ''
            VModule overrides the verbosity threshold for individual files.
            Only supported for "text" log format.
            '';
          type = VModuleConfiguration;
        };
        options = mkOption {
          description = ''
            [Alpha] Options holds additional parameters that are specific
            to the different logging formats. Only the options for the selected
            format get used, but all of them get validated.
            Only available when the LoggingAlphaOptions feature gate is enabled.
            '';
          type = FormatOptions;
        };
      };
    };
  };
  TracingConfiguration = lib.mkOption {
    description = ''
      TracingConfiguration provides versioned configuration for OpenTelemetry tracing clients.
      '';
    type = submodule {
      options = {
        endpoint = mkOption {
          description = ''
            Endpoint of the collector this component will report traces to.
            The connection is insecure, and does not currently support TLS.
            Recommended is unset, and endpoint is the otlp grpc default, localhost:4317.
            '';
          type = str;
        };
        samplingRatePerMillion = mkOption {
          description = ''
            SamplingRatePerMillion is the number of samples to collect per million spans.
            Recommended is unset. If unset, sampler respects its parent span's sampling
            rate, but otherwise never samples.
            '';
          type = int;
        };
      };
    };
  };
  VModuleConfiguration = lib.mkOption {
    description = ''
      VModuleConfiguration is a collection of individual file names or patterns
      and the corresponding verbosity threshold.
      '';
  };
  VerbosityLevel = lib.mkOption {
    description = ''
      VerbosityLevel represents a klog or logr verbosity threshold.
      '';
  };
}