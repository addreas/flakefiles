{ lib, ... }:
let
  duration = lib.types.str; # TODO: regex for metav1.Duration
in with lib.types; rec {
  DefaultPreemptionArgs = lib.mkOption {
    description = ''
      DefaultPreemptionArgs holds arguments used to configure the
      DefaultPreemption plugin.
      '';
    type = submodule {
      options = {
        minCandidateNodesPercentage = mkOption {
          description = ''
            MinCandidateNodesPercentage is the minimum number of candidates to
            shortlist when dry running preemption as a percentage of number of nodes.
            Must be in the range [0, 100]. Defaults to 10% of the cluster size if
            unspecified.
            '';
          type = int;
        };
        minCandidateNodesAbsolute = mkOption {
          description = ''
            MinCandidateNodesAbsolute is the absolute minimum number of candidates to
            shortlist. The likely number of candidates enumerated for dry running
            preemption is given by the formula:
            numCandidates = max(numNodes * minCandidateNodesPercentage, minCandidateNodesAbsolute)
            We say "likely" because there are other factors such as PDB violations
            that play a role in the number of candidates shortlisted. Must be at least
            0 nodes. Defaults to 100 nodes if unspecified.
            '';
          type = int;
        };
      };
    };
  };
  InterPodAffinityArgs = lib.mkOption {
    description = ''
      InterPodAffinityArgs holds arguments used to configure the InterPodAffinity plugin.
      '';
    type = submodule {
      options = {
        hardPodAffinityWeight = mkOption {
          description = ''
            HardPodAffinityWeight is the scoring weight for existing pods with a
            matching hard affinity to the incoming pod.
            '';
          type = int;
        };
      };
    };
  };
  KubeSchedulerConfiguration = lib.mkOption {
    description = ''
      KubeSchedulerConfiguration configures a scheduler
      '';
    type = submodule {
      options = {
        parallelism = mkOption {
          description = ''
            Parallelism defines the amount of parallelism in algorithms for scheduling a Pods. Must be greater than 0. Defaults to 16
            '';
          type = int;
        };
        leaderElection = mkOption {
          description = ''
            LeaderElection defines the configuration of leader election client.
            '';
          type = LeaderElectionConfiguration;
        };
        clientConnection = mkOption {
          description = ''
            ClientConnection specifies the kubeconfig file and client connection
            settings for the proxy server to use when communicating with the apiserver.
            '';
          type = ClientConnectionConfiguration;
        };
        DebuggingConfiguration = mkOption {
          description = ''
            DebuggingConfiguration holds configuration for Debugging related features
            TODO: We might wanna make this a substruct like Debugging componentbaseconfigv1alpha1.DebuggingConfiguration
            '';
          type = DebuggingConfiguration;
        };
        percentageOfNodesToScore = mkOption {
          description = ''
            PercentageOfNodesToScore is the percentage of all nodes that once found feasible
            for running a pod, the scheduler stops its search for more feasible nodes in
            the cluster. This helps improve scheduler's performance. Scheduler always tries to find
            at least "minFeasibleNodesToFind" feasible nodes no matter what the value of this flag is.
            Example: if the cluster size is 500 nodes and the value of this flag is 30,
            then scheduler stops finding further feasible nodes once it finds 150 feasible ones.
            When the value is 0, default percentage (5%--50% based on the size of the cluster) of the
            nodes will be scored. It is overridden by profile level PercentageofNodesToScore.
            '';
          type = int;
        };
        podInitialBackoffSeconds = mkOption {
          description = ''
            PodInitialBackoffSeconds is the initial backoff for unschedulable pods.
            If specified, it must be greater than 0. If this value is null, the default value (1s)
            will be used.
            '';
          type = int;
        };
        podMaxBackoffSeconds = mkOption {
          description = ''
            PodMaxBackoffSeconds is the max backoff for unschedulable pods.
            If specified, it must be greater than podInitialBackoffSeconds. If this value is null,
            the default value (10s) will be used.
            '';
          type = int;
        };
        profiles = mkOption {
          description = ''
            Profiles are scheduling profiles that kube-scheduler supports. Pods can
            choose to be scheduled under a particular profile by setting its associated
            scheduler name. Pods that don't specify any scheduler name are scheduled
            with the "default-scheduler" profile, if present here.
            '';
          type = (listOf KubeSchedulerProfile);
        };
        extenders = mkOption {
          description = ''
            Extenders are the list of scheduler extenders, each holding the values of how to communicate
            with the extender. These extenders are shared by all scheduler profiles.
            '';
          type = (listOf Extender);
        };
      };
    };
  };
  NodeAffinityArgs = lib.mkOption {
    description = ''
      NodeAffinityArgs holds arguments to configure the NodeAffinity plugin.
      '';
    type = submodule {
      options = {
        addedAffinity = mkOption {
          description = ''
            AddedAffinity is applied to all Pods additionally to the NodeAffinity
            specified in the PodSpec. That is, Nodes need to satisfy AddedAffinity
            AND .spec.NodeAffinity. AddedAffinity is empty by default (all Nodes
            match).
            When AddedAffinity is used, some Pods with affinity requirements that match
            a specific Node (such as Daemonset Pods) might remain unschedulable.
            '';
          type = NodeAffinity;
        };
      };
    };
  };
  NodeResourcesBalancedAllocationArgs = lib.mkOption {
    description = ''
      NodeResourcesBalancedAllocationArgs holds arguments used to configure NodeResourcesBalancedAllocation plugin.
      '';
    type = submodule {
      options = {
        resources = mkOption {
          description = ''
            Resources to be managed, the default is "cpu" and "memory" if not specified.
            '';
          type = (listOf ResourceSpec);
        };
      };
    };
  };
  NodeResourcesFitArgs = lib.mkOption {
    description = ''
      NodeResourcesFitArgs holds arguments used to configure the NodeResourcesFit plugin.
      '';
    type = submodule {
      options = {
        ignoredResources = mkOption {
          description = ''
            IgnoredResources is the list of resources that NodeResources fit filter
            should ignore. This doesn't apply to scoring.
            '';
          type = (listOf str);
        };
        ignoredResourceGroups = mkOption {
          description = ''
            IgnoredResourceGroups defines the list of resource groups that NodeResources fit filter should ignore.
            e.g. if group is ["example.com"], it will ignore all resource names that begin
            with "example.com", such as "example.com/aaa" and "example.com/bbb".
            A resource group name can't contain '/'. This doesn't apply to scoring.
            '';
          type = (listOf str);
        };
        scoringStrategy = mkOption {
          description = ''
            ScoringStrategy selects the node resource scoring strategy.
            The default strategy is LeastAllocated with an equal "cpu" and "memory" weight.
            '';
          type = ScoringStrategy;
        };
      };
    };
  };
  PodTopologySpreadArgs = lib.mkOption {
    description = ''
      PodTopologySpreadArgs holds arguments used to configure the PodTopologySpread plugin.
      '';
    type = submodule {
      options = {
        defaultConstraints = mkOption {
          description = ''
            DefaultConstraints defines topology spread constraints to be applied to
            Pods that don't define any in `pod.spec.topologySpreadConstraints`.
            `.defaultConstraints[*].labelSelectors` must be empty, as they are
            deduced from the Pod's membership to Services, ReplicationControllers,
            ReplicaSets or StatefulSets.
            When not empty, .defaultingType must be "List".
            '';
          type = (listOf TopologySpreadConstraint);
        };
        defaultingType = mkOption {
          description = ''
            DefaultingType determines how .defaultConstraints are deduced. Can be one
            of "System" or "List".
            
            - "System": Use kubernetes defined constraints that spread Pods among
              Nodes and Zones.
            - "List": Use constraints defined in .defaultConstraints.
            
            Defaults to "System".
            '';
          type = PodTopologySpreadConstraintsDefaulting;
        };
      };
    };
  };
  VolumeBindingArgs = lib.mkOption {
    description = ''
      VolumeBindingArgs holds arguments used to configure the VolumeBinding plugin.
      '';
    type = submodule {
      options = {
        bindTimeoutSeconds = mkOption {
          description = ''
            BindTimeoutSeconds is the timeout in seconds in volume binding operation.
            Value must be non-negative integer. The value zero indicates no waiting.
            If this value is nil, the default value (600) will be used.
            '';
          type = int;
        };
        shape = mkOption {
          description = ''
            Shape specifies the points defining the score function shape, which is
            used to score nodes based on the utilization of statically provisioned
            PVs. The utilization is calculated by dividing the total requested
            storage of the pod by the total capacity of feasible PVs on each node.
            Each point contains utilization (ranges from 0 to 100) and its
            associated score (ranges from 0 to 10). You can turn the priority by
            specifying different scores for different utilization numbers.
            The default shape points are:
            1) 0 for 0 utilization
            2) 10 for 100 utilization
            All points must be sorted in increasing order by utilization.
            '';
          type = (listOf UtilizationShapePoint);
        };
      };
    };
  };
  Extender = lib.mkOption {
    description = ''
      Extender holds the parameters used to communicate with the extender. If a verb is unspecified/empty,
      it is assumed that the extender chose not to provide that extension.
      '';
    type = submodule {
      options = {
        urlPrefix = mkOption {
          description = ''
            URLPrefix at which the extender is available
            '';
          type = str;
        };
        filterVerb = mkOption {
          description = ''
            Verb for the filter call, empty if not supported. This verb is appended to the URLPrefix when issuing the filter call to extender.
            '';
          type = str;
        };
        preemptVerb = mkOption {
          description = ''
            Verb for the preempt call, empty if not supported. This verb is appended to the URLPrefix when issuing the preempt call to extender.
            '';
          type = str;
        };
        prioritizeVerb = mkOption {
          description = ''
            Verb for the prioritize call, empty if not supported. This verb is appended to the URLPrefix when issuing the prioritize call to extender.
            '';
          type = str;
        };
        weight = mkOption {
          description = ''
            The numeric multiplier for the node scores that the prioritize call generates.
            The weight should be a positive integer
            '';
          type = int;
        };
        bindVerb = mkOption {
          description = ''
            Verb for the bind call, empty if not supported. This verb is appended to the URLPrefix when issuing the bind call to extender.
            If this method is implemented by the extender, it is the extender's responsibility to bind the pod to apiserver. Only one extender
            can implement this function.
            '';
          type = str;
        };
        enableHTTPS = mkOption {
          description = ''
            EnableHTTPS specifies whether https should be used to communicate with the extender
            '';
          type = bool;
        };
        tlsConfig = mkOption {
          description = ''
            TLSConfig specifies the transport layer security config
            '';
          type = ExtenderTLSConfig;
        };
        httpTimeout = mkOption {
          description = ''
            HTTPTimeout specifies the timeout duration for a call to the extender. Filter timeout fails the scheduling of the pod. Prioritize
            timeout is ignored, k8s/other extenders priorities are used to select the node.
            '';
          type = duration;
        };
        nodeCacheCapable = mkOption {
          description = ''
            NodeCacheCapable specifies that the extender is capable of caching node information,
            so the scheduler should only send minimal information about the eligible nodes
            assuming that the extender already cached full details of all nodes in the cluster
            '';
          type = bool;
        };
        managedResources = mkOption {
          description = ''
            ManagedResources is a list of extended resources that are managed by
            this extender.
            - A pod will be sent to the extender on the Filter, Prioritize and Bind
              (if the extender is the binder) phases iff the pod requests at least
              one of the extended resources in this list. If empty or unspecified,
              all pods will be sent to this extender.
            - If IgnoredByScheduler is set to true for a resource, kube-scheduler
              will skip checking the resource in predicates.
            '';
          type = (listOf ExtenderManagedResource);
        };
        ignorable = mkOption {
          description = ''
            Ignorable specifies if the extender is ignorable, i.e. scheduling should not
            fail when the extender returns an error or is not reachable.
            '';
          type = bool;
        };
      };
    };
  };
  ExtenderManagedResource = lib.mkOption {
    description = ''
      ExtenderManagedResource describes the arguments of extended resources
      managed by an extender.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name is the extended resource name.
            '';
          type = str;
        };
        ignoredByScheduler = mkOption {
          description = ''
            IgnoredByScheduler indicates whether kube-scheduler should ignore this
            resource when applying predicates.
            '';
          type = bool;
        };
      };
    };
  };
  ExtenderTLSConfig = lib.mkOption {
    description = ''
      ExtenderTLSConfig contains settings to enable TLS with extender
      '';
    type = submodule {
      options = {
        insecure = mkOption {
          description = ''
            Server should be accessed without verifying the TLS certificate. For testing only.
            '';
          type = bool;
        };
        serverName = mkOption {
          description = ''
            ServerName is passed to the server for SNI and is used in the client to check server
            certificates against. If ServerName is empty, the hostname used to contact the
            server is used.
            '';
          type = str;
        };
        certFile = mkOption {
          description = ''
            Server requires TLS client certificate authentication
            '';
          type = str;
        };
        keyFile = mkOption {
          description = ''
            Server requires TLS client certificate authentication
            '';
          type = str;
        };
        caFile = mkOption {
          description = ''
            Trusted root certificates for server
            '';
          type = str;
        };
        certData = mkOption {
          description = ''
            CertData holds PEM-encoded bytes (typically read from a client certificate file).
            CertData takes precedence over CertFile
            '';
          type = (listOf byte);
        };
        keyData = mkOption {
          description = ''
            KeyData holds PEM-encoded bytes (typically read from a client certificate key file).
            KeyData takes precedence over KeyFile
            '';
          type = (listOf byte);
        };
        caData = mkOption {
          description = ''
            CAData holds PEM-encoded bytes (typically read from a root certificates bundle).
            CAData takes precedence over CAFile
            '';
          type = (listOf byte);
        };
      };
    };
  };
  KubeSchedulerProfile = lib.mkOption {
    description = ''
      KubeSchedulerProfile is a scheduling profile.
      '';
    type = submodule {
      options = {
        schedulerName = mkOption {
          description = ''
            SchedulerName is the name of the scheduler associated to this profile.
            If SchedulerName matches with the pod's "spec.schedulerName", then the pod
            is scheduled with this profile.
            '';
          type = str;
        };
        percentageOfNodesToScore = mkOption {
          description = ''
            PercentageOfNodesToScore is the percentage of all nodes that once found feasible
            for running a pod, the scheduler stops its search for more feasible nodes in
            the cluster. This helps improve scheduler's performance. Scheduler always tries to find
            at least "minFeasibleNodesToFind" feasible nodes no matter what the value of this flag is.
            Example: if the cluster size is 500 nodes and the value of this flag is 30,
            then scheduler stops finding further feasible nodes once it finds 150 feasible ones.
            When the value is 0, default percentage (5%--50% based on the size of the cluster) of the
            nodes will be scored. It will override global PercentageOfNodesToScore. If it is empty,
            global PercentageOfNodesToScore will be used.
            '';
          type = int;
        };
        plugins = mkOption {
          description = ''
            Plugins specify the set of plugins that should be enabled or disabled.
            Enabled plugins are the ones that should be enabled in addition to the
            default plugins. Disabled plugins are any of the default plugins that
            should be disabled.
            When no enabled or disabled plugin is specified for an extension point,
            default plugins for that extension point will be used if there is any.
            If a QueueSort plugin is specified, the same QueueSort Plugin and
            PluginConfig must be specified for all profiles.
            '';
          type = Plugins;
        };
        pluginConfig = mkOption {
          description = ''
            PluginConfig is an optional set of custom plugin arguments for each plugin.
            Omitting config args for a plugin is equivalent to using the default config
            for that plugin.
            '';
          type = (listOf PluginConfig);
        };
      };
    };
  };
  Plugin = lib.mkOption {
    description = ''
      Plugin specifies a plugin name and its weight when applicable. Weight is used only for Score plugins.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name defines the name of plugin
            '';
          type = str;
        };
        weight = mkOption {
          description = ''
            Weight defines the weight of plugin, only used for Score plugins.
            '';
          type = int;
        };
      };
    };
  };
  PluginConfig = lib.mkOption {
    description = ''
      PluginConfig specifies arguments that should be passed to a plugin at the time of initialization.
      A plugin that is invoked at multiple extension points is initialized once. Args can have arbitrary structure.
      It is up to the plugin to process these Args.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name defines the name of plugin being configured
            '';
          type = str;
        };
        args = mkOption {
          description = ''
            Args defines the arguments passed to the plugins at the time of initialization. Args can have arbitrary structure.
            '';
          type = k8s.io/apimachinery/pkg/runtime.RawExtension;
        };
      };
    };
  };
  PluginSet = lib.mkOption {
    description = ''
      PluginSet specifies enabled and disabled plugins for an extension point.
      If an array is empty, missing, or nil, default plugins at that extension point will be used.
      '';
    type = submodule {
      options = {
        enabled = mkOption {
          description = ''
            Enabled specifies plugins that should be enabled in addition to default plugins.
            If the default plugin is also configured in the scheduler config file, the weight of plugin will
            be overridden accordingly.
            These are called after default plugins and in the same order specified here.
            '';
          type = (listOf Plugin);
        };
        disabled = mkOption {
          description = ''
            Disabled specifies default plugins that should be disabled.
            When all default plugins need to be disabled, an array containing only one "*" should be provided.
            '';
          type = (listOf Plugin);
        };
      };
    };
  };
  Plugins = lib.mkOption {
    description = ''
      Plugins include multiple extension points. When specified, the list of plugins for
      a particular extension point are the only ones enabled. If an extension point is
      omitted from the config, then the default set of plugins is used for that extension point.
      Enabled plugins are called in the order specified here, after default plugins. If they need to
      be invoked before default plugins, default plugins must be disabled and re-enabled here in desired order.
      '';
    type = submodule {
      options = {
        preEnqueue = mkOption {
          description = ''
            PreEnqueue is a list of plugins that should be invoked before adding pods to the scheduling queue.
            '';
          type = PluginSet;
        };
        queueSort = mkOption {
          description = ''
            QueueSort is a list of plugins that should be invoked when sorting pods in the scheduling queue.
            '';
          type = PluginSet;
        };
        preFilter = mkOption {
          description = ''
            PreFilter is a list of plugins that should be invoked at "PreFilter" extension point of the scheduling framework.
            '';
          type = PluginSet;
        };
        filter = mkOption {
          description = ''
            Filter is a list of plugins that should be invoked when filtering out nodes that cannot run the Pod.
            '';
          type = PluginSet;
        };
        postFilter = mkOption {
          description = ''
            PostFilter is a list of plugins that are invoked after filtering phase, but only when no feasible nodes were found for the pod.
            '';
          type = PluginSet;
        };
        preScore = mkOption {
          description = ''
            PreScore is a list of plugins that are invoked before scoring.
            '';
          type = PluginSet;
        };
        score = mkOption {
          description = ''
            Score is a list of plugins that should be invoked when ranking nodes that have passed the filtering phase.
            '';
          type = PluginSet;
        };
        reserve = mkOption {
          description = ''
            Reserve is a list of plugins invoked when reserving/unreserving resources
            after a node is assigned to run the pod.
            '';
          type = PluginSet;
        };
        permit = mkOption {
          description = ''
            Permit is a list of plugins that control binding of a Pod. These plugins can prevent or delay binding of a Pod.
            '';
          type = PluginSet;
        };
        preBind = mkOption {
          description = ''
            PreBind is a list of plugins that should be invoked before a pod is bound.
            '';
          type = PluginSet;
        };
        bind = mkOption {
          description = ''
            Bind is a list of plugins that should be invoked at "Bind" extension point of the scheduling framework.
            The scheduler call these plugins in order. Scheduler skips the rest of these plugins as soon as one returns success.
            '';
          type = PluginSet;
        };
        postBind = mkOption {
          description = ''
            PostBind is a list of plugins that should be invoked after a pod is successfully bound.
            '';
          type = PluginSet;
        };
        multiPoint = mkOption {
          description = ''
            MultiPoint is a simplified config section to enable plugins for all valid extension points.
            Plugins enabled through MultiPoint will automatically register for every individual extension
            point the plugin has implemented. Disabling a plugin through MultiPoint disables that behavior.
            The same is true for disabling "*" through MultiPoint (no default plugins will be automatically registered).
            Plugins can still be disabled through their individual extension points.
            
            In terms of precedence, plugin config follows this basic hierarchy
              1. Specific extension points
              2. Explicitly configured MultiPoint plugins
              3. The set of default plugins, as MultiPoint plugins
            This implies that a higher precedence plugin will run first and overwrite any settings within MultiPoint.
            Explicitly user-configured plugins also take a higher precedence over default plugins.
            Within this hierarchy, an Enabled setting takes precedence over Disabled. For example, if a plugin is
            set in both `multiPoint.Enabled` and `multiPoint.Disabled`, the plugin will be enabled. Similarly,
            including `multiPoint.Disabled = '*'` and `multiPoint.Enabled = pluginA` will still register that specific
            plugin through MultiPoint. This follows the same behavior as all other extension point configurations.
            '';
          type = PluginSet;
        };
      };
    };
  };
  PodTopologySpreadConstraintsDefaulting = lib.mkOption {
    description = ''
      PodTopologySpreadConstraintsDefaulting defines how to set default constraints
      for the PodTopologySpread plugin.
      '';
  };
  RequestedToCapacityRatioParam = lib.mkOption {
    description = ''
      RequestedToCapacityRatioParam define RequestedToCapacityRatio parameters
      '';
    type = submodule {
      options = {
        shape = mkOption {
          description = ''
            Shape is a list of points defining the scoring function shape.
            '';
          type = (listOf UtilizationShapePoint);
        };
      };
    };
  };
  ResourceSpec = lib.mkOption {
    description = ''
      ResourceSpec represents a single resource.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name of the resource.
            '';
          type = str;
        };
        weight = mkOption {
          description = ''
            Weight of the resource.
            '';
          type = int;
        };
      };
    };
  };
  ScoringStrategy = lib.mkOption {
    description = ''
      ScoringStrategy define ScoringStrategyType for node resource plugin
      '';
    type = submodule {
      options = {
        type = mkOption {
          description = ''
            Type selects which strategy to run.
            '';
          type = ScoringStrategyType;
        };
        resources = mkOption {
          description = ''
            Resources to consider when scoring.
            The default resource set includes "cpu" and "memory" with an equal weight.
            Allowed weights go from 1 to 100.
            Weight defaults to 1 if not specified or explicitly set to 0.
            '';
          type = (listOf ResourceSpec);
        };
        requestedToCapacityRatio = mkOption {
          description = ''
            Arguments specific to RequestedToCapacityRatio strategy.
            '';
          type = RequestedToCapacityRatioParam;
        };
      };
    };
  };
  ScoringStrategyType = lib.mkOption {
    description = ''
      ScoringStrategyType the type of scoring strategy used in NodeResourcesFit plugin.
      '';
  };
  UtilizationShapePoint = lib.mkOption {
    description = ''
      UtilizationShapePoint represents single point of priority function shape.
      '';
    type = submodule {
      options = {
        utilization = mkOption {
          description = ''
            Utilization (x axis). Valid values are 0 to 100. Fully utilized node maps to 100.
            '';
          type = int;
        };
        score = mkOption {
          description = ''
            Score assigned to given utilization (y axis). Valid values are 0 to 10.
            '';
          type = int;
        };
      };
    };
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