{ lib, ... }:
let
  duration = lib.types.str; # TODO: regex for metav1.Duration
in with lib.types; rec {
  KubeProxyConfiguration = lib.mkOption {
    description = ''
      KubeProxyConfiguration contains everything necessary to configure the
      Kubernetes proxy server.
      '';
    type = submodule {
      options = {
        featureGates = mkOption {
          description = ''
            featureGates is a map of feature names to bools that enable or disable alpha/experimental features.
            '';
          type = (attrsOf bool);
        };
        bindAddress = mkOption {
          description = ''
            bindAddress is the IP address for the proxy server to serve on (set to 0.0.0.0
            for all interfaces)
            '';
          type = str;
        };
        healthzBindAddress = mkOption {
          description = ''
            healthzBindAddress is the IP address and port for the health check server to serve on,
            defaulting to 0.0.0.0:10256
            '';
          type = str;
        };
        metricsBindAddress = mkOption {
          description = ''
            metricsBindAddress is the IP address and port for the metrics server to serve on,
            defaulting to 127.0.0.1:10249 (set to 0.0.0.0 for all interfaces)
            '';
          type = str;
        };
        bindAddressHardFail = mkOption {
          description = ''
            bindAddressHardFail, if true, kube-proxy will treat failure to bind to a port as fatal and exit
            '';
          type = bool;
        };
        enableProfiling = mkOption {
          description = ''
            enableProfiling enables profiling via web interface on /debug/pprof handler.
            Profiling handlers will be handled by metrics server.
            '';
          type = bool;
        };
        clusterCIDR = mkOption {
          description = ''
            clusterCIDR is the CIDR range of the pods in the cluster. It is used to
            bridge traffic coming from outside of the cluster. If not provided,
            no off-cluster bridging will be performed.
            '';
          type = str;
        };
        hostnameOverride = mkOption {
          description = ''
            hostnameOverride, if non-empty, will be used as the identity instead of the actual hostname.
            '';
          type = str;
        };
        clientConnection = mkOption {
          description = ''
            clientConnection specifies the kubeconfig file and client connection settings for the proxy
            server to use when communicating with the apiserver.
            '';
          type = ClientConnectionConfiguration;
        };
        iptables = mkOption {
          description = ''
            iptables contains iptables-related configuration options.
            '';
          type = KubeProxyIPTablesConfiguration;
        };
        ipvs = mkOption {
          description = ''
            ipvs contains ipvs-related configuration options.
            '';
          type = KubeProxyIPVSConfiguration;
        };
        oomScoreAdj = mkOption {
          description = ''
            oomScoreAdj is the oom-score-adj value for kube-proxy process. Values must be within
            the range [-1000, 1000]
            '';
          type = int;
        };
        mode = mkOption {
          description = ''
            mode specifies which proxy mode to use.
            '';
          type = ProxyMode;
        };
        portRange = mkOption {
          description = ''
            portRange is the range of host ports (beginPort-endPort, inclusive) that may be consumed
            in order to proxy service traffic. If unspecified (0-0) then ports will be randomly chosen.
            '';
          type = str;
        };
        conntrack = mkOption {
          description = ''
            conntrack contains conntrack-related configuration options.
            '';
          type = KubeProxyConntrackConfiguration;
        };
        configSyncPeriod = mkOption {
          description = ''
            configSyncPeriod is how often configuration from the apiserver is refreshed. Must be greater
            than 0.
            '';
          type = duration;
        };
        nodePortAddresses = mkOption {
          description = ''
            nodePortAddresses is the --nodeport-addresses value for kube-proxy process. Values must be valid
            IP blocks. These values are as a parameter to select the interfaces where nodeport works.
            In case someone would like to expose a service on localhost for local visit and some other interfaces for
            particular purpose, a list of IP blocks would do that.
            If set it to "127.0.0.0/8", kube-proxy will only select the loopback interface for NodePort.
            If set it to a non-zero IP block, kube-proxy will filter that down to just the IPs that applied to the node.
            An empty string slice is meant to select all network interfaces.
            '';
          type = (listOf str);
        };
        winkernel = mkOption {
          description = ''
            winkernel contains winkernel-related configuration options.
            '';
          type = KubeProxyWinkernelConfiguration;
        };
        showHiddenMetricsForVersion = mkOption {
          description = ''
            ShowHiddenMetricsForVersion is the version for which you want to show hidden metrics.
            '';
          type = str;
        };
        detectLocalMode = mkOption {
          description = ''
            DetectLocalMode determines mode to use for detecting local traffic, defaults to LocalModeClusterCIDR
            '';
          type = LocalMode;
        };
        detectLocal = mkOption {
          description = ''
            DetectLocal contains optional configuration settings related to DetectLocalMode.
            '';
          type = DetectLocalConfiguration;
        };
      };
    };
  };
  DetectLocalConfiguration = lib.mkOption {
    description = ''
      DetectLocalConfiguration contains optional settings related to DetectLocalMode option
      '';
    type = submodule {
      options = {
        bridgeInterface = mkOption {
          description = ''
            BridgeInterface is a string argument which represents a single bridge interface name.
            Kube-proxy considers traffic as local if originating from this given bridge.
            This argument should be set if DetectLocalMode is set to LocalModeBridgeInterface.
            '';
          type = str;
        };
        interfaceNamePrefix = mkOption {
          description = ''
            InterfaceNamePrefix is a string argument which represents a single interface prefix name.
            Kube-proxy considers traffic as local if originating from one or more interfaces which match
            the given prefix. This argument should be set if DetectLocalMode is set to LocalModeInterfaceNamePrefix.
            '';
          type = str;
        };
      };
    };
  };
  KubeProxyConntrackConfiguration = lib.mkOption {
    description = ''
      KubeProxyConntrackConfiguration contains conntrack settings for
      the Kubernetes proxy server.
      '';
    type = submodule {
      options = {
        maxPerCore = mkOption {
          description = ''
            maxPerCore is the maximum number of NAT connections to track
            per CPU core (0 to leave the limit as-is and ignore min).
            '';
          type = int;
        };
        min = mkOption {
          description = ''
            min is the minimum value of connect-tracking records to allocate,
            regardless of conntrackMaxPerCore (set maxPerCore=0 to leave the limit as-is).
            '';
          type = int;
        };
        tcpEstablishedTimeout = mkOption {
          description = ''
            tcpEstablishedTimeout is how long an idle TCP connection will be kept open
            (e.g. '2s').  Must be greater than 0 to set.
            '';
          type = duration;
        };
        tcpCloseWaitTimeout = mkOption {
          description = ''
            tcpCloseWaitTimeout is how long an idle conntrack entry
            in CLOSE_WAIT state will remain in the conntrack
            table. (e.g. '60s'). Must be greater than 0 to set.
            '';
          type = duration;
        };
      };
    };
  };
  KubeProxyIPTablesConfiguration = lib.mkOption {
    description = ''
      KubeProxyIPTablesConfiguration contains iptables-related configuration
      details for the Kubernetes proxy server.
      '';
    type = submodule {
      options = {
        masqueradeBit = mkOption {
          description = ''
            masqueradeBit is the bit of the iptables fwmark space to use for SNAT if using
            the pure iptables proxy mode. Values must be within the range [0, 31].
            '';
          type = int;
        };
        masqueradeAll = mkOption {
          description = ''
            masqueradeAll tells kube-proxy to SNAT everything if using the pure iptables proxy mode.
            '';
          type = bool;
        };
        localhostNodePorts = mkOption {
          description = ''
            LocalhostNodePorts tells kube-proxy to allow service NodePorts to be accessed via
            localhost (iptables mode only)
            '';
          type = bool;
        };
        syncPeriod = mkOption {
          description = ''
            syncPeriod is the period that iptables rules are refreshed (e.g. '5s', '1m',
            '2h22m').  Must be greater than 0.
            '';
          type = duration;
        };
        minSyncPeriod = mkOption {
          description = ''
            minSyncPeriod is the minimum period that iptables rules are refreshed (e.g. '5s', '1m',
            '2h22m').
            '';
          type = duration;
        };
      };
    };
  };
  KubeProxyIPVSConfiguration = lib.mkOption {
    description = ''
      KubeProxyIPVSConfiguration contains ipvs-related configuration
      details for the Kubernetes proxy server.
      '';
    type = submodule {
      options = {
        syncPeriod = mkOption {
          description = ''
            syncPeriod is the period that ipvs rules are refreshed (e.g. '5s', '1m',
            '2h22m').  Must be greater than 0.
            '';
          type = duration;
        };
        minSyncPeriod = mkOption {
          description = ''
            minSyncPeriod is the minimum period that ipvs rules are refreshed (e.g. '5s', '1m',
            '2h22m').
            '';
          type = duration;
        };
        scheduler = mkOption {
          description = ''
            ipvs scheduler
            '';
          type = str;
        };
        excludeCIDRs = mkOption {
          description = ''
            excludeCIDRs is a list of CIDR's which the ipvs proxier should not touch
            when cleaning up ipvs services.
            '';
          type = (listOf str);
        };
        strictARP = mkOption {
          description = ''
            strict ARP configure arp_ignore and arp_announce to avoid answering ARP queries
            from kube-ipvs0 interface
            '';
          type = bool;
        };
        tcpTimeout = mkOption {
          description = ''
            tcpTimeout is the timeout value used for idle IPVS TCP sessions.
            The default value is 0, which preserves the current timeout value on the system.
            '';
          type = duration;
        };
        tcpFinTimeout = mkOption {
          description = ''
            tcpFinTimeout is the timeout value used for IPVS TCP sessions after receiving a FIN.
            The default value is 0, which preserves the current timeout value on the system.
            '';
          type = duration;
        };
        udpTimeout = mkOption {
          description = ''
            udpTimeout is the timeout value used for IPVS UDP packets.
            The default value is 0, which preserves the current timeout value on the system.
            '';
          type = duration;
        };
      };
    };
  };
  KubeProxyWinkernelConfiguration = lib.mkOption {
    description = ''
      KubeProxyWinkernelConfiguration contains Windows/HNS settings for
      the Kubernetes proxy server.
      '';
    type = submodule {
      options = {
        networkName = mkOption {
          description = ''
            networkName is the name of the network kube-proxy will use
            to create endpoints and policies
            '';
          type = str;
        };
        sourceVip = mkOption {
          description = ''
            sourceVip is the IP address of the source VIP endoint used for
            NAT when loadbalancing
            '';
          type = str;
        };
        enableDSR = mkOption {
          description = ''
            enableDSR tells kube-proxy whether HNS policies should be created
            with DSR
            '';
          type = bool;
        };
        rootHnsEndpointName = mkOption {
          description = ''
            RootHnsEndpointName is the name of hnsendpoint that is attached to
            l2bridge for root network namespace
            '';
          type = str;
        };
        forwardHealthCheckVip = mkOption {
          description = ''
            ForwardHealthCheckVip forwards service VIP for health check port on
            Windows
            '';
          type = bool;
        };
      };
    };
  };
  LocalMode = lib.mkOption {
    description = ''
      LocalMode represents modes to detect local traffic from the node
      '';
  };
  ProxyMode = lib.mkOption {
    description = ''
      ProxyMode represents modes used by the Kubernetes proxy server.
      
      Currently, two modes of proxy are available on Linux platforms: 'iptables' and 'ipvs'.
      One mode of proxy is available on Windows platforms: 'kernelspace'.
      
      If the proxy mode is unspecified, the best-available proxy mode will be used (currently this
      is `iptables` on Linux and `kernelspace` on Windows). If the selected proxy mode cannot be
      used (due to lack of kernel support, missing userspace components, etc) then kube-proxy
      will exit with an error.
      '';
  };
  ClientConnectionConfiguration = lib.mkOption {
    description = ''
      ClientConnectionConfiguration contains details for constructing a client.
      '';
    type = submodule {
      options = {
        kubeconfig = mkOption {
          description = ''
            kubeconfig is the path to a KubeConfig file.
            '';
          type = str;
        };
        acceptContentTypes = mkOption {
          description = ''
            acceptContentTypes defines the Accept header sent by clients when connecting to a server, overriding the
            default value of 'application/json'. This field will control all connections to the server used by a particular
            client.
            '';
          type = str;
        };
        contentType = mkOption {
          description = ''
            contentType is the content type used when sending data to the server from this client.
            '';
          type = str;
        };
        qps = mkOption {
          description = ''
            qps controls the number of queries per second allowed for this connection.
            '';
          type = float;
        };
        burst = mkOption {
          description = ''
            burst allows extra queries to accumulate when a client is exceeding its rate.
            '';
          type = int;
        };
      };
    };
  };
  DebuggingConfiguration = lib.mkOption {
    description = ''
      DebuggingConfiguration holds configuration for Debugging related features.
      '';
    type = submodule {
      options = {
        enableProfiling = mkOption {
          description = ''
            enableProfiling enables profiling via web interface host:port/debug/pprof/
            '';
          type = bool;
        };
        enableContentionProfiling = mkOption {
          description = ''
            enableContentionProfiling enables lock contention profiling, if
            enableProfiling is true.
            '';
          type = bool;
        };
      };
    };
  };
  LeaderElectionConfiguration = lib.mkOption {
    description = ''
      LeaderElectionConfiguration defines the configuration of leader election
      clients for components that can run with leader election enabled.
      '';
    type = submodule {
      options = {
        leaderElect = mkOption {
          description = ''
            leaderElect enables a leader election client to gain leadership
            before executing the main loop. Enable this when running replicated
            components for high availability.
            '';
          type = bool;
        };
        leaseDuration = mkOption {
          description = ''
            leaseDuration is the duration that non-leader candidates will wait
            after observing a leadership renewal until attempting to acquire
            leadership of a led but unrenewed leader slot. This is effectively the
            maximum duration that a leader can be stopped before it is replaced
            by another candidate. This is only applicable if leader election is
            enabled.
            '';
          type = duration;
        };
        renewDeadline = mkOption {
          description = ''
            renewDeadline is the interval between attempts by the acting master to
            renew a leadership slot before it stops leading. This must be less
            than or equal to the lease duration. This is only applicable if leader
            election is enabled.
            '';
          type = duration;
        };
        retryPeriod = mkOption {
          description = ''
            retryPeriod is the duration the clients should wait between attempting
            acquisition and renewal of a leadership. This is only applicable if
            leader election is enabled.
            '';
          type = duration;
        };
        resourceLock = mkOption {
          description = ''
            resourceLock indicates the resource object type that will be used to lock
            during leader election cycles.
            '';
          type = str;
        };
        resourceName = mkOption {
          description = ''
            resourceName indicates the name of resource object that will be used to lock
            during leader election cycles.
            '';
          type = str;
        };
        resourceNamespace = mkOption {
          description = ''
            resourceName indicates the namespace of resource object that will be used to lock
            during leader election cycles.
            '';
          type = str;
        };
      };
    };
  };
}