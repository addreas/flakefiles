{ lib, ... }:
let
  duration = lib.types.str; # TODO: regex for metav1.Duration
in with lib.types; rec {
  KubeControllerManagerConfiguration = lib.mkOption {
    description = ''
      KubeControllerManagerConfiguration contains elements describing kube-controller manager.
      '';
    type = submodule {
      options = {
        Generic = mkOption {
          description = ''
            Generic holds configuration for a generic controller-manager
            '';
          type = GenericControllerManagerConfiguration;
        };
        KubeCloudShared = mkOption {
          description = ''
            KubeCloudSharedConfiguration holds configuration for shared related features
            both in cloud controller manager and kube-controller manager.
            '';
          type = KubeCloudSharedConfiguration;
        };
        AttachDetachController = mkOption {
          description = ''
            AttachDetachControllerConfiguration holds configuration for
            AttachDetachController related features.
            '';
          type = AttachDetachControllerConfiguration;
        };
        CSRSigningController = mkOption {
          description = ''
            CSRSigningControllerConfiguration holds configuration for
            CSRSigningController related features.
            '';
          type = CSRSigningControllerConfiguration;
        };
        DaemonSetController = mkOption {
          description = ''
            DaemonSetControllerConfiguration holds configuration for DaemonSetController
            related features.
            '';
          type = DaemonSetControllerConfiguration;
        };
        DeploymentController = mkOption {
          description = ''
            DeploymentControllerConfiguration holds configuration for
            DeploymentController related features.
            '';
          type = DeploymentControllerConfiguration;
        };
        StatefulSetController = mkOption {
          description = ''
            StatefulSetControllerConfiguration holds configuration for
            StatefulSetController related features.
            '';
          type = StatefulSetControllerConfiguration;
        };
        DeprecatedController = mkOption {
          description = ''
            DeprecatedControllerConfiguration holds configuration for some deprecated
            features.
            '';
          type = DeprecatedControllerConfiguration;
        };
        EndpointController = mkOption {
          description = ''
            EndpointControllerConfiguration holds configuration for EndpointController
            related features.
            '';
          type = EndpointControllerConfiguration;
        };
        EndpointSliceController = mkOption {
          description = ''
            EndpointSliceControllerConfiguration holds configuration for
            EndpointSliceController related features.
            '';
          type = EndpointSliceControllerConfiguration;
        };
        EndpointSliceMirroringController = mkOption {
          description = ''
            EndpointSliceMirroringControllerConfiguration holds configuration for
            EndpointSliceMirroringController related features.
            '';
          type = EndpointSliceMirroringControllerConfiguration;
        };
        EphemeralVolumeController = mkOption {
          description = ''
            EphemeralVolumeControllerConfiguration holds configuration for EphemeralVolumeController
            related features.
            '';
          type = EphemeralVolumeControllerConfiguration;
        };
        GarbageCollectorController = mkOption {
          description = ''
            GarbageCollectorControllerConfiguration holds configuration for
            GarbageCollectorController related features.
            '';
          type = GarbageCollectorControllerConfiguration;
        };
        HPAController = mkOption {
          description = ''
            HPAControllerConfiguration holds configuration for HPAController related features.
            '';
          type = HPAControllerConfiguration;
        };
        JobController = mkOption {
          description = ''
            JobControllerConfiguration holds configuration for JobController related features.
            '';
          type = JobControllerConfiguration;
        };
        CronJobController = mkOption {
          description = ''
            CronJobControllerConfiguration holds configuration for CronJobController related features.
            '';
          type = CronJobControllerConfiguration;
        };
        NamespaceController = mkOption {
          description = ''
            NamespaceControllerConfiguration holds configuration for NamespaceController
            related features.
            NamespaceControllerConfiguration holds configuration for NamespaceController
            related features.
            '';
          type = NamespaceControllerConfiguration;
        };
        NodeIPAMController = mkOption {
          description = ''
            NodeIPAMControllerConfiguration holds configuration for NodeIPAMController
            related features.
            '';
          type = NodeIPAMControllerConfiguration;
        };
        NodeLifecycleController = mkOption {
          description = ''
            NodeLifecycleControllerConfiguration holds configuration for
            NodeLifecycleController related features.
            '';
          type = NodeLifecycleControllerConfiguration;
        };
        PersistentVolumeBinderController = mkOption {
          description = ''
            PersistentVolumeBinderControllerConfiguration holds configuration for
            PersistentVolumeBinderController related features.
            '';
          type = PersistentVolumeBinderControllerConfiguration;
        };
        PodGCController = mkOption {
          description = ''
            PodGCControllerConfiguration holds configuration for PodGCController
            related features.
            '';
          type = PodGCControllerConfiguration;
        };
        ReplicaSetController = mkOption {
          description = ''
            ReplicaSetControllerConfiguration holds configuration for ReplicaSet related features.
            '';
          type = ReplicaSetControllerConfiguration;
        };
        ReplicationController = mkOption {
          description = ''
            ReplicationControllerConfiguration holds configuration for
            ReplicationController related features.
            '';
          type = ReplicationControllerConfiguration;
        };
        ResourceQuotaController = mkOption {
          description = ''
            ResourceQuotaControllerConfiguration holds configuration for
            ResourceQuotaController related features.
            '';
          type = ResourceQuotaControllerConfiguration;
        };
        SAController = mkOption {
          description = ''
            SAControllerConfiguration holds configuration for ServiceAccountController
            related features.
            '';
          type = SAControllerConfiguration;
        };
        ServiceController = mkOption {
          description = ''
            ServiceControllerConfiguration holds configuration for ServiceController
            related features.
            '';
          type = ServiceControllerConfiguration;
        };
        TTLAfterFinishedController = mkOption {
          description = ''
            TTLAfterFinishedControllerConfiguration holds configuration for
            TTLAfterFinishedController related features.
            '';
          type = TTLAfterFinishedControllerConfiguration;
        };
      };
    };
  };
  AttachDetachControllerConfiguration = lib.mkOption {
    description = ''
      AttachDetachControllerConfiguration contains elements describing AttachDetachController.
      '';
    type = submodule {
      options = {
        DisableAttachDetachReconcilerSync = mkOption {
          description = ''
            Reconciler runs a periodic loop to reconcile the desired state of the with
            the actual state of the world by triggering attach detach operations.
            This flag enables or disables reconcile.  Is false by default, and thus enabled.
            '';
          type = bool;
        };
        ReconcilerSyncLoopPeriod = mkOption {
          description = ''
            ReconcilerSyncLoopPeriod is the amount of time the reconciler sync states loop
            wait between successive executions. Is set to 5 sec by default.
            '';
          type = duration;
        };
      };
    };
  };
  CSRSigningConfiguration = lib.mkOption {
    description = ''
      CSRSigningConfiguration holds information about a particular CSR signer
      '';
    type = submodule {
      options = {
        CertFile = mkOption {
          description = ''
            certFile is the filename containing a PEM-encoded
            X509 CA certificate used to issue certificates
            '';
          type = str;
        };
        KeyFile = mkOption {
          description = ''
            keyFile is the filename containing a PEM-encoded
            RSA or ECDSA private key used to issue certificates
            '';
          type = str;
        };
      };
    };
  };
  CSRSigningControllerConfiguration = lib.mkOption {
    description = ''
      CSRSigningControllerConfiguration contains elements describing CSRSigningController.
      '';
    type = submodule {
      options = {
        ClusterSigningCertFile = mkOption {
          description = ''
            clusterSigningCertFile is the filename containing a PEM-encoded
            X509 CA certificate used to issue cluster-scoped certificates
            '';
          type = str;
        };
        ClusterSigningKeyFile = mkOption {
          description = ''
            clusterSigningCertFile is the filename containing a PEM-encoded
            RSA or ECDSA private key used to issue cluster-scoped certificates
            '';
          type = str;
        };
        KubeletServingSignerConfiguration = mkOption {
          description = ''
            kubeletServingSignerConfiguration holds the certificate and key used to issue certificates for the kubernetes.io/kubelet-serving signer
            '';
          type = CSRSigningConfiguration;
        };
        KubeletClientSignerConfiguration = mkOption {
          description = ''
            kubeletClientSignerConfiguration holds the certificate and key used to issue certificates for the kubernetes.io/kube-apiserver-client-kubelet
            '';
          type = CSRSigningConfiguration;
        };
        KubeAPIServerClientSignerConfiguration = mkOption {
          description = ''
            kubeAPIServerClientSignerConfiguration holds the certificate and key used to issue certificates for the kubernetes.io/kube-apiserver-client
            '';
          type = CSRSigningConfiguration;
        };
        LegacyUnknownSignerConfiguration = mkOption {
          description = ''
            legacyUnknownSignerConfiguration holds the certificate and key used to issue certificates for the kubernetes.io/legacy-unknown
            '';
          type = CSRSigningConfiguration;
        };
        ClusterSigningDuration = mkOption {
          description = ''
            clusterSigningDuration is the max length of duration signed certificates will be given.
            Individual CSRs may request shorter certs by setting spec.expirationSeconds.
            '';
          type = duration;
        };
      };
    };
  };
  CronJobControllerConfiguration = lib.mkOption {
    description = ''
      CronJobControllerConfiguration contains elements describing CrongJob2Controller.
      '';
    type = submodule {
      options = {
        ConcurrentCronJobSyncs = mkOption {
          description = ''
            concurrentCronJobSyncs is the number of job objects that are
            allowed to sync concurrently. Larger number = more responsive jobs,
            but more CPU (and network) load.
            '';
          type = int;
        };
      };
    };
  };
  DaemonSetControllerConfiguration = lib.mkOption {
    description = ''
      DaemonSetControllerConfiguration contains elements describing DaemonSetController.
      '';
    type = submodule {
      options = {
        ConcurrentDaemonSetSyncs = mkOption {
          description = ''
            concurrentDaemonSetSyncs is the number of daemonset objects that are
            allowed to sync concurrently. Larger number = more responsive daemonset,
            but more CPU (and network) load.
            '';
          type = int;
        };
      };
    };
  };
  DeploymentControllerConfiguration = lib.mkOption {
    description = ''
      DeploymentControllerConfiguration contains elements describing DeploymentController.
      '';
    type = submodule {
      options = {
        ConcurrentDeploymentSyncs = mkOption {
          description = ''
            concurrentDeploymentSyncs is the number of deployment objects that are
            allowed to sync concurrently. Larger number = more responsive deployments,
            but more CPU (and network) load.
            '';
          type = int;
        };
      };
    };
  };
  DeprecatedControllerConfiguration = lib.mkOption {
    description = ''
      DeprecatedControllerConfiguration contains elements be deprecated.
      '';
  };
  EndpointControllerConfiguration = lib.mkOption {
    description = ''
      EndpointControllerConfiguration contains elements describing EndpointController.
      '';
    type = submodule {
      options = {
        ConcurrentEndpointSyncs = mkOption {
          description = ''
            concurrentEndpointSyncs is the number of endpoint syncing operations
            that will be done concurrently. Larger number = faster endpoint updating,
            but more CPU (and network) load.
            '';
          type = int;
        };
        EndpointUpdatesBatchPeriod = mkOption {
          description = ''
            EndpointUpdatesBatchPeriod describes the length of endpoint updates batching period.
            Processing of pod changes will be delayed by this duration to join them with potential
            upcoming updates and reduce the overall number of endpoints updates.
            '';
          type = duration;
        };
      };
    };
  };
  EndpointSliceControllerConfiguration = lib.mkOption {
    description = ''
      EndpointSliceControllerConfiguration contains elements describing
      EndpointSliceController.
      '';
    type = submodule {
      options = {
        ConcurrentServiceEndpointSyncs = mkOption {
          description = ''
            concurrentServiceEndpointSyncs is the number of service endpoint syncing
            operations that will be done concurrently. Larger number = faster
            endpoint slice updating, but more CPU (and network) load.
            '';
          type = int;
        };
        MaxEndpointsPerSlice = mkOption {
          description = ''
            maxEndpointsPerSlice is the maximum number of endpoints that will be
            added to an EndpointSlice. More endpoints per slice will result in fewer
            and larger endpoint slices, but larger resources.
            '';
          type = int;
        };
        EndpointUpdatesBatchPeriod = mkOption {
          description = ''
            EndpointUpdatesBatchPeriod describes the length of endpoint updates batching period.
            Processing of pod changes will be delayed by this duration to join them with potential
            upcoming updates and reduce the overall number of endpoints updates.
            '';
          type = duration;
        };
      };
    };
  };
  EndpointSliceMirroringControllerConfiguration = lib.mkOption {
    description = ''
      EndpointSliceMirroringControllerConfiguration contains elements describing
      EndpointSliceMirroringController.
      '';
    type = submodule {
      options = {
        MirroringConcurrentServiceEndpointSyncs = mkOption {
          description = ''
            mirroringConcurrentServiceEndpointSyncs is the number of service endpoint
            syncing operations that will be done concurrently. Larger number = faster
            endpoint slice updating, but more CPU (and network) load.
            '';
          type = int;
        };
        MirroringMaxEndpointsPerSubset = mkOption {
          description = ''
            mirroringMaxEndpointsPerSubset is the maximum number of endpoints that
            will be mirrored to an EndpointSlice for an EndpointSubset.
            '';
          type = int;
        };
        MirroringEndpointUpdatesBatchPeriod = mkOption {
          description = ''
            mirroringEndpointUpdatesBatchPeriod can be used to batch EndpointSlice
            updates. All updates triggered by EndpointSlice changes will be delayed
            by up to 'mirroringEndpointUpdatesBatchPeriod'. If other addresses in the
            same Endpoints resource change in that period, they will be batched to a
            single EndpointSlice update. Default 0 value means that each Endpoints
            update triggers an EndpointSlice update.
            '';
          type = duration;
        };
      };
    };
  };
  EphemeralVolumeControllerConfiguration = lib.mkOption {
    description = ''
      EphemeralVolumeControllerConfiguration contains elements describing EphemeralVolumeController.
      '';
    type = submodule {
      options = {
        ConcurrentEphemeralVolumeSyncs = mkOption {
          description = ''
            ConcurrentEphemeralVolumeSyncseSyncs is the number of ephemeral volume syncing operations
            that will be done concurrently. Larger number = faster ephemeral volume updating,
            but more CPU (and network) load.
            '';
          type = int;
        };
      };
    };
  };
  GarbageCollectorControllerConfiguration = lib.mkOption {
    description = ''
      GarbageCollectorControllerConfiguration contains elements describing GarbageCollectorController.
      '';
    type = submodule {
      options = {
        EnableGarbageCollector = mkOption {
          description = ''
            enables the generic garbage collector. MUST be synced with the
            corresponding flag of the kube-apiserver. WARNING: the generic garbage
            collector is an alpha feature.
            '';
          type = bool;
        };
        ConcurrentGCSyncs = mkOption {
          description = ''
            concurrentGCSyncs is the number of garbage collector workers that are
            allowed to sync concurrently.
            '';
          type = int;
        };
        GCIgnoredResources = mkOption {
          description = ''
            gcIgnoredResources is the list of GroupResources that garbage collection should ignore.
            '';
          type = (listOf GroupResource);
        };
      };
    };
  };
  GroupResource = lib.mkOption {
    description = ''
      GroupResource describes an group resource.
      '';
    type = submodule {
      options = {
        Group = mkOption {
          description = ''
            group is the group portion of the GroupResource.
            '';
          type = str;
        };
        Resource = mkOption {
          description = ''
            resource is the resource portion of the GroupResource.
            '';
          type = str;
        };
      };
    };
  };
  HPAControllerConfiguration = lib.mkOption {
    description = ''
      HPAControllerConfiguration contains elements describing HPAController.
      '';
    type = submodule {
      options = {
        ConcurrentHorizontalPodAutoscalerSyncs = mkOption {
          description = ''
            ConcurrentHorizontalPodAutoscalerSyncs is the number of HPA objects that are allowed to sync concurrently.
            Larger number = more responsive HPA processing, but more CPU (and network) load.
            '';
          type = int;
        };
        HorizontalPodAutoscalerSyncPeriod = mkOption {
          description = ''
            HorizontalPodAutoscalerSyncPeriod is the period for syncing the number of
            pods in horizontal pod autoscaler.
            '';
          type = duration;
        };
        HorizontalPodAutoscalerUpscaleForbiddenWindow = mkOption {
          description = ''
            HorizontalPodAutoscalerUpscaleForbiddenWindow is a period after which next upscale allowed.
            '';
          type = duration;
        };
        HorizontalPodAutoscalerDownscaleStabilizationWindow = mkOption {
          description = ''
            HorizontalPodAutoscalerDowncaleStabilizationWindow is a period for which autoscaler will look
            backwards and not scale down below any recommendation it made during that period.
            '';
          type = duration;
        };
        HorizontalPodAutoscalerDownscaleForbiddenWindow = mkOption {
          description = ''
            HorizontalPodAutoscalerDownscaleForbiddenWindow is a period after which next downscale allowed.
            '';
          type = duration;
        };
        HorizontalPodAutoscalerTolerance = mkOption {
          description = ''
            HorizontalPodAutoscalerTolerance is the tolerance for when
            resource usage suggests upscaling/downscaling
            '';
          type = float;
        };
        HorizontalPodAutoscalerCPUInitializationPeriod = mkOption {
          description = ''
            HorizontalPodAutoscalerCPUInitializationPeriod is the period after pod start when CPU samples
            might be skipped.
            '';
          type = duration;
        };
        HorizontalPodAutoscalerInitialReadinessDelay = mkOption {
          description = ''
            HorizontalPodAutoscalerInitialReadinessDelay is period after pod start during which readiness
            changes are treated as readiness being set for the first time. The only effect of this is that
            HPA will disregard CPU samples from unready pods that had last readiness change during that
            period.
            '';
          type = duration;
        };
      };
    };
  };
  JobControllerConfiguration = lib.mkOption {
    description = ''
      JobControllerConfiguration contains elements describing JobController.
      '';
    type = submodule {
      options = {
        ConcurrentJobSyncs = mkOption {
          description = ''
            concurrentJobSyncs is the number of job objects that are
            allowed to sync concurrently. Larger number = more responsive jobs,
            but more CPU (and network) load.
            '';
          type = int;
        };
      };
    };
  };
  NamespaceControllerConfiguration = lib.mkOption {
    description = ''
      NamespaceControllerConfiguration contains elements describing NamespaceController.
      '';
    type = submodule {
      options = {
        NamespaceSyncPeriod = mkOption {
          description = ''
            namespaceSyncPeriod is the period for syncing namespace life-cycle
            updates.
            '';
          type = duration;
        };
        ConcurrentNamespaceSyncs = mkOption {
          description = ''
            concurrentNamespaceSyncs is the number of namespace objects that are
            allowed to sync concurrently.
            '';
          type = int;
        };
      };
    };
  };
  NodeIPAMControllerConfiguration = lib.mkOption {
    description = ''
      NodeIPAMControllerConfiguration contains elements describing NodeIpamController.
      '';
    type = submodule {
      options = {
        ServiceCIDR = mkOption {
          description = ''
            serviceCIDR is CIDR Range for Services in cluster.
            '';
          type = str;
        };
        SecondaryServiceCIDR = mkOption {
          description = ''
            secondaryServiceCIDR is CIDR Range for Services in cluster. This is used in dual stack clusters. SecondaryServiceCIDR must be of different IP family than ServiceCIDR
            '';
          type = str;
        };
        NodeCIDRMaskSize = mkOption {
          description = ''
            NodeCIDRMaskSize is the mask size for node cidr in cluster.
            '';
          type = int;
        };
        NodeCIDRMaskSizeIPv4 = mkOption {
          description = ''
            NodeCIDRMaskSizeIPv4 is the mask size for node cidr in dual-stack cluster.
            '';
          type = int;
        };
        NodeCIDRMaskSizeIPv6 = mkOption {
          description = ''
            NodeCIDRMaskSizeIPv6 is the mask size for node cidr in dual-stack cluster.
            '';
          type = int;
        };
      };
    };
  };
  NodeLifecycleControllerConfiguration = lib.mkOption {
    description = ''
      NodeLifecycleControllerConfiguration contains elements describing NodeLifecycleController.
      '';
    type = submodule {
      options = {
        EnableTaintManager = mkOption {
          description = ''
            If set to true enables NoExecute Taints and will evict all not-tolerating
            Pod running on Nodes tainted with this kind of Taints.
            '';
          type = bool;
        };
        NodeEvictionRate = mkOption {
          description = ''
            nodeEvictionRate is the number of nodes per second on which pods are deleted in case of node failure when a zone is healthy
            '';
          type = float;
        };
        SecondaryNodeEvictionRate = mkOption {
          description = ''
            secondaryNodeEvictionRate is the number of nodes per second on which pods are deleted in case of node failure when a zone is unhealthy
            '';
          type = float;
        };
        NodeStartupGracePeriod = mkOption {
          description = ''
            nodeStartupGracePeriod is the amount of time which we allow starting a node to
            be unresponsive before marking it unhealthy.
            '';
          type = duration;
        };
        NodeMonitorGracePeriod = mkOption {
          description = ''
            nodeMontiorGracePeriod is the amount of time which we allow a running node to be
            unresponsive before marking it unhealthy. Must be N times more than kubelet's
            nodeStatusUpdateFrequency, where N means number of retries allowed for kubelet
            to post node status.
            '';
          type = duration;
        };
        PodEvictionTimeout = mkOption {
          description = ''
            podEvictionTimeout is the grace period for deleting pods on failed nodes.
            '';
          type = duration;
        };
        LargeClusterSizeThreshold = mkOption {
          description = ''
            secondaryNodeEvictionRate is implicitly overridden to 0 for clusters smaller than or equal to largeClusterSizeThreshold
            '';
          type = int;
        };
        UnhealthyZoneThreshold = mkOption {
          description = ''
            Zone is treated as unhealthy in nodeEvictionRate and secondaryNodeEvictionRate when at least
            unhealthyZoneThreshold (no less than 3) of Nodes in the zone are NotReady
            '';
          type = float;
        };
      };
    };
  };
  PersistentVolumeBinderControllerConfiguration = lib.mkOption {
    description = ''
      PersistentVolumeBinderControllerConfiguration contains elements describing
      PersistentVolumeBinderController.
      '';
    type = submodule {
      options = {
        PVClaimBinderSyncPeriod = mkOption {
          description = ''
            pvClaimBinderSyncPeriod is the period for syncing persistent volumes
            and persistent volume claims.
            '';
          type = duration;
        };
        VolumeConfiguration = mkOption {
          description = ''
            volumeConfiguration holds configuration for volume related features.
            '';
          type = VolumeConfiguration;
        };
        VolumeHostCIDRDenylist = mkOption {
          description = ''
            VolumeHostCIDRDenylist is a list of CIDRs that should not be reachable by the
            controller from plugins.
            '';
          type = (listOf str);
        };
        VolumeHostAllowLocalLoopback = mkOption {
          description = ''
            VolumeHostAllowLocalLoopback indicates if local loopback hosts (127.0.0.1, etc)
            should be allowed from plugins.
            '';
          type = bool;
        };
      };
    };
  };
  PersistentVolumeRecyclerConfiguration = lib.mkOption {
    description = ''
      PersistentVolumeRecyclerConfiguration contains elements describing persistent volume plugins.
      '';
    type = submodule {
      options = {
        MaximumRetry = mkOption {
          description = ''
            maximumRetry is number of retries the PV recycler will execute on failure to recycle
            PV.
            '';
          type = int;
        };
        MinimumTimeoutNFS = mkOption {
          description = ''
            minimumTimeoutNFS is the minimum ActiveDeadlineSeconds to use for an NFS Recycler
            pod.
            '';
          type = int;
        };
        PodTemplateFilePathNFS = mkOption {
          description = ''
            podTemplateFilePathNFS is the file path to a pod definition used as a template for
            NFS persistent volume recycling
            '';
          type = str;
        };
        IncrementTimeoutNFS = mkOption {
          description = ''
            incrementTimeoutNFS is the increment of time added per Gi to ActiveDeadlineSeconds
            for an NFS scrubber pod.
            '';
          type = int;
        };
        PodTemplateFilePathHostPath = mkOption {
          description = ''
            podTemplateFilePathHostPath is the file path to a pod definition used as a template for
            HostPath persistent volume recycling. This is for development and testing only and
            will not work in a multi-node cluster.
            '';
          type = str;
        };
        MinimumTimeoutHostPath = mkOption {
          description = ''
            minimumTimeoutHostPath is the minimum ActiveDeadlineSeconds to use for a HostPath
            Recycler pod.  This is for development and testing only and will not work in a multi-node
            cluster.
            '';
          type = int;
        };
        IncrementTimeoutHostPath = mkOption {
          description = ''
            incrementTimeoutHostPath is the increment of time added per Gi to ActiveDeadlineSeconds
            for a HostPath scrubber pod.  This is for development and testing only and will not work
            in a multi-node cluster.
            '';
          type = int;
        };
      };
    };
  };
  PodGCControllerConfiguration = lib.mkOption {
    description = ''
      PodGCControllerConfiguration contains elements describing PodGCController.
      '';
    type = submodule {
      options = {
        TerminatedPodGCThreshold = mkOption {
          description = ''
            terminatedPodGCThreshold is the number of terminated pods that can exist
            before the terminated pod garbage collector starts deleting terminated pods.
            If <= 0, the terminated pod garbage collector is disabled.
            '';
          type = int;
        };
      };
    };
  };
  ReplicaSetControllerConfiguration = lib.mkOption {
    description = ''
      ReplicaSetControllerConfiguration contains elements describing ReplicaSetController.
      '';
    type = submodule {
      options = {
        ConcurrentRSSyncs = mkOption {
          description = ''
            concurrentRSSyncs is the number of replica sets that are  allowed to sync
            concurrently. Larger number = more responsive replica  management, but more
            CPU (and network) load.
            '';
          type = int;
        };
      };
    };
  };
  ReplicationControllerConfiguration = lib.mkOption {
    description = ''
      ReplicationControllerConfiguration contains elements describing ReplicationController.
      '';
    type = submodule {
      options = {
        ConcurrentRCSyncs = mkOption {
          description = ''
            concurrentRCSyncs is the number of replication controllers that are
            allowed to sync concurrently. Larger number = more responsive replica
            management, but more CPU (and network) load.
            '';
          type = int;
        };
      };
    };
  };
  ResourceQuotaControllerConfiguration = lib.mkOption {
    description = ''
      ResourceQuotaControllerConfiguration contains elements describing ResourceQuotaController.
      '';
    type = submodule {
      options = {
        ResourceQuotaSyncPeriod = mkOption {
          description = ''
            resourceQuotaSyncPeriod is the period for syncing quota usage status
            in the system.
            '';
          type = duration;
        };
        ConcurrentResourceQuotaSyncs = mkOption {
          description = ''
            concurrentResourceQuotaSyncs is the number of resource quotas that are
            allowed to sync concurrently. Larger number = more responsive quota
            management, but more CPU (and network) load.
            '';
          type = int;
        };
      };
    };
  };
  SAControllerConfiguration = lib.mkOption {
    description = ''
      SAControllerConfiguration contains elements describing ServiceAccountController.
      '';
    type = submodule {
      options = {
        ServiceAccountKeyFile = mkOption {
          description = ''
            serviceAccountKeyFile is the filename containing a PEM-encoded private RSA key
            used to sign service account tokens.
            '';
          type = str;
        };
        ConcurrentSATokenSyncs = mkOption {
          description = ''
            concurrentSATokenSyncs is the number of service account token syncing operations
            that will be done concurrently.
            '';
          type = int;
        };
        RootCAFile = mkOption {
          description = ''
            rootCAFile is the root certificate authority will be included in service
            account's token secret. This must be a valid PEM-encoded CA bundle.
            '';
          type = str;
        };
      };
    };
  };
  StatefulSetControllerConfiguration = lib.mkOption {
    description = ''
      StatefulSetControllerConfiguration contains elements describing StatefulSetController.
      '';
    type = submodule {
      options = {
        ConcurrentStatefulSetSyncs = mkOption {
          description = ''
            concurrentStatefulSetSyncs is the number of statefulset objects that are
            allowed to sync concurrently. Larger number = more responsive statefulsets,
            but more CPU (and network) load.
            '';
          type = int;
        };
      };
    };
  };
  TTLAfterFinishedControllerConfiguration = lib.mkOption {
    description = ''
      TTLAfterFinishedControllerConfiguration contains elements describing TTLAfterFinishedController.
      '';
    type = submodule {
      options = {
        ConcurrentTTLSyncs = mkOption {
          description = ''
            concurrentTTLSyncs is the number of TTL-after-finished collector workers that are
            allowed to sync concurrently.
            '';
          type = int;
        };
      };
    };
  };
  VolumeConfiguration = lib.mkOption {
    description = ''
      VolumeConfiguration contains *all* enumerated flags meant to configure all volume
      plugins. From this config, the controller-manager binary will create many instances of
      volume.VolumeConfig, each containing only the configuration needed for that plugin which
      are then passed to the appropriate plugin. The ControllerManager binary is the only part
      of the code which knows what plugins are supported and which flags correspond to each plugin.
      '';
    type = submodule {
      options = {
        EnableHostPathProvisioning = mkOption {
          description = ''
            enableHostPathProvisioning enables HostPath PV provisioning when running without a
            cloud provider. This allows testing and development of provisioning features. HostPath
            provisioning is not supported in any way, won't work in a multi-node cluster, and
            should not be used for anything other than testing or development.
            '';
          type = bool;
        };
        EnableDynamicProvisioning = mkOption {
          description = ''
            enableDynamicProvisioning enables the provisioning of volumes when running within an environment
            that supports dynamic provisioning. Defaults to true.
            '';
          type = bool;
        };
        PersistentVolumeRecyclerConfiguration = mkOption {
          description = ''
            persistentVolumeRecyclerConfiguration holds configuration for persistent volume plugins.
            '';
          type = PersistentVolumeRecyclerConfiguration;
        };
        FlexVolumePluginDir = mkOption {
          description = ''
            volumePluginDir is the full path of the directory in which the flex
            volume plugin should search for additional third party volume plugins
            '';
          type = str;
        };
      };
    };
  };
  ServiceControllerConfiguration = lib.mkOption {
    description = ''
      ServiceControllerConfiguration contains elements describing ServiceController.
      '';
    type = submodule {
      options = {
        ConcurrentServiceSyncs = mkOption {
          description = ''
            concurrentServiceSyncs is the number of services that are
            allowed to sync concurrently. Larger number = more responsive service
            management, but more CPU (and network) load.
            '';
          type = int;
        };
      };
    };
  };
  CloudControllerManagerConfiguration = lib.mkOption {
    description = ''
      
      '';
    type = submodule {
      options = {
        Generic = mkOption {
          description = ''
            Generic holds configuration for a generic controller-manager
            '';
          type = GenericControllerManagerConfiguration;
        };
        KubeCloudShared = mkOption {
          description = ''
            KubeCloudSharedConfiguration holds configuration for shared related features
            both in cloud controller manager and kube-controller manager.
            '';
          type = KubeCloudSharedConfiguration;
        };
        ServiceController = mkOption {
          description = ''
            ServiceControllerConfiguration holds configuration for ServiceController
            related features.
            '';
          type = ServiceControllerConfiguration;
        };
        NodeStatusUpdateFrequency = mkOption {
          description = ''
            NodeStatusUpdateFrequency is the frequency at which the controller updates nodes' status
            '';
          type = duration;
        };
      };
    };
  };
  CloudProviderConfiguration = lib.mkOption {
    description = ''
      CloudProviderConfiguration contains basically elements about cloud provider.
      '';
    type = submodule {
      options = {
        Name = mkOption {
          description = ''
            Name is the provider for cloud services.
            '';
          type = str;
        };
        CloudConfigFile = mkOption {
          description = ''
            cloudConfigFile is the path to the cloud provider configuration file.
            '';
          type = str;
        };
      };
    };
  };
  KubeCloudSharedConfiguration = lib.mkOption {
    description = ''
      KubeCloudSharedConfiguration contains elements shared by both kube-controller manager
      and cloud-controller manager, but not genericconfig.
      '';
    type = submodule {
      options = {
        CloudProvider = mkOption {
          description = ''
            CloudProviderConfiguration holds configuration for CloudProvider related features.
            '';
          type = CloudProviderConfiguration;
        };
        ExternalCloudVolumePlugin = mkOption {
          description = ''
            externalCloudVolumePlugin specifies the plugin to use when cloudProvider is "external".
            It is currently used by the in repo cloud providers to handle node and volume control in the KCM.
            '';
          type = str;
        };
        UseServiceAccountCredentials = mkOption {
          description = ''
            useServiceAccountCredentials indicates whether controllers should be run with
            individual service account credentials.
            '';
          type = bool;
        };
        AllowUntaggedCloud = mkOption {
          description = ''
            run with untagged cloud instances
            '';
          type = bool;
        };
        RouteReconciliationPeriod = mkOption {
          description = ''
            routeReconciliationPeriod is the period for reconciling routes created for Nodes by cloud provider..
            '';
          type = duration;
        };
        NodeMonitorPeriod = mkOption {
          description = ''
            nodeMonitorPeriod is the period for syncing NodeStatus in NodeController.
            '';
          type = duration;
        };
        ClusterName = mkOption {
          description = ''
            clusterName is the instance prefix for the cluster.
            '';
          type = str;
        };
        ClusterCIDR = mkOption {
          description = ''
            clusterCIDR is CIDR Range for Pods in cluster.
            '';
          type = str;
        };
        AllocateNodeCIDRs = mkOption {
          description = ''
            AllocateNodeCIDRs enables CIDRs for Pods to be allocated and, if
            ConfigureCloudRoutes is true, to be set on the cloud provider.
            '';
          type = bool;
        };
        CIDRAllocatorType = mkOption {
          description = ''
            CIDRAllocatorType determines what kind of pod CIDR allocator will be used.
            '';
          type = str;
        };
        ConfigureCloudRoutes = mkOption {
          description = ''
            configureCloudRoutes enables CIDRs allocated with allocateNodeCIDRs
            to be configured on the cloud provider.
            '';
          type = bool;
        };
        NodeSyncPeriod = mkOption {
          description = ''
            nodeSyncPeriod is the period for syncing nodes from cloudprovider. Longer
            periods will result in fewer calls to cloud provider, but may delay addition
            of new nodes to cluster.
            '';
          type = duration;
        };
      };
    };
  };
  LeaderMigrationConfiguration = lib.mkOption {
    description = ''
      LeaderMigrationConfiguration provides versioned configuration for all migrating leader locks.
      '';
    type = submodule {
      options = {
        leaderName = mkOption {
          description = ''
            LeaderName is the name of the leader election resource that protects the migration
            E.g. 1-20-KCM-to-1-21-CCM
            '';
          type = str;
        };
        resourceLock = mkOption {
          description = ''
            ResourceLock indicates the resource object type that will be used to lock
            Should be "leases" or "endpoints"
            '';
          type = str;
        };
        controllerLeaders = mkOption {
          description = ''
            ControllerLeaders contains a list of migrating leader lock configurations
            '';
          type = (listOf ControllerLeaderConfiguration);
        };
      };
    };
  };
  ControllerLeaderConfiguration = lib.mkOption {
    description = ''
      ControllerLeaderConfiguration provides the configuration for a migrating leader lock.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name is the name of the controller being migrated
            E.g. service-controller, route-controller, cloud-node-controller, etc
            '';
          type = str;
        };
        component = mkOption {
          description = ''
            Component is the name of the component in which the controller should be running.
            E.g. kube-controller-manager, cloud-controller-manager, etc
            Or '*' meaning the controller can be run under any component that participates in the migration
            '';
          type = str;
        };
      };
    };
  };
  GenericControllerManagerConfiguration = lib.mkOption {
    description = ''
      GenericControllerManagerConfiguration holds configuration for a generic controller-manager.
      '';
    type = submodule {
      options = {
        Port = mkOption {
          description = ''
            port is the port that the controller-manager's http service runs on.
            '';
          type = int;
        };
        Address = mkOption {
          description = ''
            address is the IP address to serve on (set to 0.0.0.0 for all interfaces).
            '';
          type = str;
        };
        MinResyncPeriod = mkOption {
          description = ''
            minResyncPeriod is the resync period in reflectors; will be random between
            minResyncPeriod and 2*minResyncPeriod.
            '';
          type = duration;
        };
        ClientConnection = mkOption {
          description = ''
            ClientConnection specifies the kubeconfig file and client connection
            settings for the proxy server to use when communicating with the apiserver.
            '';
          type = ClientConnectionConfiguration;
        };
        ControllerStartInterval = mkOption {
          description = ''
            How long to wait between starting controller managers
            '';
          type = duration;
        };
        LeaderElection = mkOption {
          description = ''
            leaderElection defines the configuration of leader election client.
            '';
          type = LeaderElectionConfiguration;
        };
        Controllers = mkOption {
          description = ''
            Controllers is the list of controllers to enable or disable
            '*' means "all enabled by default controllers"
            'foo' means "enable 'foo'"
            '-foo' means "disable 'foo'"
            first item for a particular name wins
            '';
          type = (listOf str);
        };
        Debugging = mkOption {
          description = ''
            DebuggingConfiguration holds configuration for Debugging related features.
            '';
          type = DebuggingConfiguration;
        };
        LeaderMigrationEnabled = mkOption {
          description = ''
            LeaderMigrationEnabled indicates whether Leader Migration should be enabled for the controller manager.
            '';
          type = bool;
        };
        LeaderMigration = mkOption {
          description = ''
            LeaderMigration holds the configuration for Leader Migration.
            '';
          type = LeaderMigrationConfiguration;
        };
      };
    };
  };
}