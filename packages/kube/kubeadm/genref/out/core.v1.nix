{ lib, ... }:
let
  duration = lib.types.str; # TODO: regex for metav1.Duration
in with lib.types; rec {
  ComponentStatus = lib.mkOption {
    description = ''
      ComponentStatus (and ComponentStatusList) holds the cluster validation info.
      Deprecated: This API is deprecated in v1.19+
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        conditions = mkOption {
          description = ''
            List of component conditions observed
            '';
          type = (listOf ComponentCondition);
        };
      };
    };
  };
  ConfigMap = lib.mkOption {
    description = ''
      ConfigMap holds configuration data for pods to consume.
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        immutable = mkOption {
          description = ''
            Immutable, if set to true, ensures that data stored in the ConfigMap cannot
            be updated (only object metadata can be modified).
            If not set to true, the field can be modified at any time.
            Defaulted to nil.
            '';
          type = bool;
        };
        data = mkOption {
          description = ''
            Data contains the configuration data.
            Each key must consist of alphanumeric characters, '-', '_' or '.'.
            Values with non-UTF-8 byte sequences must use the BinaryData field.
            The keys stored in Data must not overlap with the keys in
            the BinaryData field, this is enforced during validation process.
            '';
          type = (attrsOf str);
        };
        binaryData = mkOption {
          description = ''
            BinaryData contains the binary data.
            Each key must consist of alphanumeric characters, '-', '_' or '.'.
            BinaryData can contain byte sequences that are not in the UTF-8 range.
            The keys stored in BinaryData must not overlap with the ones in
            the Data field, this is enforced during validation process.
            Using this field will require 1.10+ apiserver and
            kubelet.
            '';
          type = (attrsOf (listOf byte));
        };
      };
    };
  };
  Endpoints = lib.mkOption {
    description = ''
      Endpoints is a collection of endpoints that implement the actual service. Example:
      
      	 Name: "mysvc",
      	 Subsets: [
      	   {
      	     Addresses: [{"ip": "10.10.1.1"}, {"ip": "10.10.2.2"}],
      	     Ports: [{"name": "a", "port": 8675}, {"name": "b", "port": 309}]
      	   },
      	   {
      	     Addresses: [{"ip": "10.10.3.3"}],
      	     Ports: [{"name": "a", "port": 93}, {"name": "b", "port": 76}]
      	   },
      	]
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        subsets = mkOption {
          description = ''
            The set of all endpoints is the union of all subsets. Addresses are placed into
            subsets according to the IPs they share. A single address with multiple ports,
            some of which are ready and some of which are not (because they come from
            different containers) will result in the address being displayed in different
            subsets for the different ports. No address will appear in both Addresses and
            NotReadyAddresses in the same subset.
            Sets of addresses and ports that comprise a service.
            '';
          type = (listOf EndpointSubset);
        };
      };
    };
  };
  Event = lib.mkOption {
    description = ''
      Event is a report of an event somewhere in the cluster.  Events
      have a limited retention time and triggers and messages may evolve
      with time.  Event consumers should not rely on the timing of an event
      with a given Reason reflecting a consistent underlying trigger, or the
      continued existence of events with that Reason.  Events should be
      treated as informative, best-effort, supplemental data.
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        involvedObject = mkOption {
          description = ''
            The object that this event is about.
            '';
          type = ObjectReference;
        };
        reason = mkOption {
          description = ''
            This should be a short, machine understandable string that gives the reason
            for the transition into the object's current status.
            TODO: provide exact specification for format.
            '';
          type = str;
        };
        message = mkOption {
          description = ''
            A human-readable description of the status of this operation.
            TODO: decide on maximum length.
            '';
          type = str;
        };
        source = mkOption {
          description = ''
            The component reporting this event. Should be a short machine understandable string.
            '';
          type = EventSource;
        };
        firstTimestamp = mkOption {
          description = ''
            The time at which the event was first recorded. (Time of server receipt is in TypeMeta.)
            '';
          type = meta/v1.Time;
        };
        lastTimestamp = mkOption {
          description = ''
            The time at which the most recent occurrence of this event was recorded.
            '';
          type = meta/v1.Time;
        };
        count = mkOption {
          description = ''
            The number of times this event has occurred.
            '';
          type = int;
        };
        type = mkOption {
          description = ''
            Type of this event (Normal, Warning), new types could be added in the future
            '';
          type = str;
        };
        eventTime = mkOption {
          description = ''
            Time when this Event was first observed.
            '';
          type = meta/v1.MicroTime;
        };
        series = mkOption {
          description = ''
            Data about the Event series this event represents or nil if it's a singleton Event.
            '';
          type = EventSeries;
        };
        action = mkOption {
          description = ''
            What action was taken/failed regarding to the Regarding object.
            '';
          type = str;
        };
        related = mkOption {
          description = ''
            Optional secondary object for more complex actions.
            '';
          type = ObjectReference;
        };
        reportingComponent = mkOption {
          description = ''
            Name of the controller that emitted this Event, e.g. `kubernetes.io/kubelet`.
            '';
          type = str;
        };
        reportingInstance = mkOption {
          description = ''
            ID of the controller instance, e.g. `kubelet-xyzf`.
            '';
          type = str;
        };
      };
    };
  };
  LimitRange = lib.mkOption {
    description = ''
      LimitRange sets resource usage limits for each kind of resource in a Namespace.
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        spec = mkOption {
          description = ''
            Spec defines the limits enforced.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = LimitRangeSpec;
        };
      };
    };
  };
  Namespace = lib.mkOption {
    description = ''
      Namespace provides a scope for Names.
      Use of multiple namespaces is optional.
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        spec = mkOption {
          description = ''
            Spec defines the behavior of the Namespace.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = NamespaceSpec;
        };
        status = mkOption {
          description = ''
            Status describes the current status of a Namespace.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = NamespaceStatus;
        };
      };
    };
  };
  Node = lib.mkOption {
    description = ''
      Node is a worker node in Kubernetes.
      Each node will have a unique identifier in the cache (i.e. in etcd).
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        spec = mkOption {
          description = ''
            Spec defines the behavior of a node.
            https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = NodeSpec;
        };
        status = mkOption {
          description = ''
            Most recently observed status of the node.
            Populated by the system.
            Read-only.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = NodeStatus;
        };
      };
    };
  };
  ObjectReference = lib.mkOption {
    description = ''
      ObjectReference contains enough information to let you inspect or modify the referred object.
      ---
      New uses of this type are discouraged because of difficulty describing its usage when embedded in APIs.
       1. Ignored fields.  It includes many fields which are not generally honored.  For instance, ResourceVersion and FieldPath are both very rarely valid in actual usage.
       2. Invalid usage help.  It is impossible to add specific help for individual usage.  In most embedded usages, there are particular
          restrictions like, "must refer only to types A and B" or "UID not honored" or "name must be restricted".
          Those cannot be well described when embedded.
       3. Inconsistent validation.  Because the usages are different, the validation rules are different by usage, which makes it hard for users to predict what will happen.
       4. The fields are both imprecise and overly precise.  Kind is not a precise mapping to a URL. This can produce ambiguity
          during interpretation and require a REST mapping.  In most cases, the dependency is on the group,resource tuple
          and the version of the actual struct is irrelevant.
       5. We cannot easily change it.  Because this type is embedded in many locations, updates to this type
          will affect numerous schemas.  Don't make new APIs embed an underspecified API type they do not control.
      
      Instead of using this type, create a locally provided and used type that is well-focused on your reference.
      For example, ServiceReferences for admission registration: https://github.com/kubernetes/api/blob/release-1.17/admissionregistration/v1/types.go#L533 .
      '';
    type = submodule {
      options = {
        kind = mkOption {
          description = ''
            Kind of the referent.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
            '';
          type = str;
        };
        namespace = mkOption {
          description = ''
            Namespace of the referent.
            More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
            '';
          type = str;
        };
        name = mkOption {
          description = ''
            Name of the referent.
            More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
            '';
          type = str;
        };
        uid = mkOption {
          description = ''
            UID of the referent.
            More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#uids
            '';
          type = k8s.io/apimachinery/pkg/types.UID;
        };
        apiVersion = mkOption {
          description = ''
            API version of the referent.
            '';
          type = str;
        };
        resourceVersion = mkOption {
          description = ''
            Specific resourceVersion to which this reference is made, if any.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#concurrency-control-and-consistency
            '';
          type = str;
        };
        fieldPath = mkOption {
          description = ''
            If referring to a piece of an object instead of an entire object, this string
            should contain a valid JSON/Go field access statement, such as desiredState.manifest.containers[2].
            For example, if the object reference is to a container within a pod, this would take on a value like:
            "spec.containers{name}" (where "name" refers to the name of the container that triggered
            the event) or if no container name is specified "spec.containers[2]" (container with
            index 2 in this pod). This syntax is chosen only to have some well-defined way of
            referencing a part of an object.
            TODO: this design is not final and this field is subject to change in the future.
            '';
          type = str;
        };
      };
    };
  };
  PersistentVolume = lib.mkOption {
    description = ''
      PersistentVolume (PV) is a storage resource provisioned by an administrator.
      It is analogous to a node.
      More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        spec = mkOption {
          description = ''
            spec defines a specification of a persistent volume owned by the cluster.
            Provisioned by an administrator.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistent-volumes
            '';
          type = PersistentVolumeSpec;
        };
        status = mkOption {
          description = ''
            status represents the current information/status for the persistent volume.
            Populated by the system.
            Read-only.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistent-volumes
            '';
          type = PersistentVolumeStatus;
        };
      };
    };
  };
  PersistentVolumeClaim = lib.mkOption {
    description = ''
      PersistentVolumeClaim is a user's request for and claim to a persistent volume
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        spec = mkOption {
          description = ''
            spec defines the desired characteristics of a volume requested by a pod author.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
            '';
          type = PersistentVolumeClaimSpec;
        };
        status = mkOption {
          description = ''
            status represents the current information/status of a persistent volume claim.
            Read-only.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
            '';
          type = PersistentVolumeClaimStatus;
        };
      };
    };
  };
  Pod = lib.mkOption {
    description = ''
      Pod is a collection of containers that can run on a host. This resource is created
      by clients and scheduled onto hosts.
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        spec = mkOption {
          description = ''
            Specification of the desired behavior of the pod.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = PodSpec;
        };
        status = mkOption {
          description = ''
            Most recently observed status of the pod.
            This data may not be up to date.
            Populated by the system.
            Read-only.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = PodStatus;
        };
      };
    };
  };
  PodTemplate = lib.mkOption {
    description = ''
      PodTemplate describes a template for creating copies of a predefined pod.
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        template = mkOption {
          description = ''
            Template defines the pods that will be created from this pod template.
            https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = PodTemplateSpec;
        };
      };
    };
  };
  ReplicationController = lib.mkOption {
    description = ''
      ReplicationController represents the configuration of a replication controller.
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            If the Labels of a ReplicationController are empty, they are defaulted to
            be the same as the Pod(s) that the replication controller manages.
            Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        spec = mkOption {
          description = ''
            Spec defines the specification of the desired behavior of the replication controller.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = ReplicationControllerSpec;
        };
        status = mkOption {
          description = ''
            Status is the most recently observed status of the replication controller.
            This data may be out of date by some window of time.
            Populated by the system.
            Read-only.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = ReplicationControllerStatus;
        };
      };
    };
  };
  ResourceQuota = lib.mkOption {
    description = ''
      ResourceQuota sets aggregate quota restrictions enforced per namespace
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        spec = mkOption {
          description = ''
            Spec defines the desired quota.
            https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = ResourceQuotaSpec;
        };
        status = mkOption {
          description = ''
            Status defines the actual enforced quota and its current usage.
            https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = ResourceQuotaStatus;
        };
      };
    };
  };
  Secret = lib.mkOption {
    description = ''
      Secret holds secret data of a certain type. The total bytes of the values in
      the Data field must be less than MaxSecretSize bytes.
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        immutable = mkOption {
          description = ''
            Immutable, if set to true, ensures that data stored in the Secret cannot
            be updated (only object metadata can be modified).
            If not set to true, the field can be modified at any time.
            Defaulted to nil.
            '';
          type = bool;
        };
        data = mkOption {
          description = ''
            Data contains the secret data. Each key must consist of alphanumeric
            characters, '-', '_' or '.'. The serialized form of the secret data is a
            base64 encoded string, representing the arbitrary (possibly non-string)
            data value here. Described in https://tools.ietf.org/html/rfc4648#section-4
            '';
          type = (attrsOf (listOf byte));
        };
        stringData = mkOption {
          description = ''
            stringData allows specifying non-binary secret data in string form.
            It is provided as a write-only input field for convenience.
            All keys and values are merged into the data field on write, overwriting any existing values.
            The stringData field is never output when reading from the API.
            '';
          type = (attrsOf str);
        };
        type = mkOption {
          description = ''
            Used to facilitate programmatic handling of secret data.
            More info: https://kubernetes.io/docs/concepts/configuration/secret/#secret-types
            '';
          type = SecretType;
        };
      };
    };
  };
  Service = lib.mkOption {
    description = ''
      Service is a named abstraction of software service (for example, mysql) consisting of local port
      (for example 3306) that the proxy listens on, and the selector that determines which pods
      will answer requests sent through the proxy.
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        spec = mkOption {
          description = ''
            Spec defines the behavior of a service.
            https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = ServiceSpec;
        };
        status = mkOption {
          description = ''
            Most recently observed status of the service.
            Populated by the system.
            Read-only.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = ServiceStatus;
        };
      };
    };
  };
  ServiceAccount = lib.mkOption {
    description = ''
      ServiceAccount binds together:
      * a name, understood by users, and perhaps by peripheral systems, for an identity
      * a principal that can be authenticated and authorized
      * a set of secrets
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        secrets = mkOption {
          description = ''
            Secrets is a list of the secrets in the same namespace that pods running using this ServiceAccount are allowed to use.
            Pods are only limited to this list if this service account has a "kubernetes.io/enforce-mountable-secrets" annotation set to "true".
            This field should not be used to find auto-generated service account token secrets for use outside of pods.
            Instead, tokens can be requested directly using the TokenRequest API, or service account token secrets can be manually created.
            More info: https://kubernetes.io/docs/concepts/configuration/secret
            '';
          type = (listOf ObjectReference);
        };
        imagePullSecrets = mkOption {
          description = ''
            ImagePullSecrets is a list of references to secrets in the same namespace to use for pulling any images
            in pods that reference this ServiceAccount. ImagePullSecrets are distinct from Secrets because Secrets
            can be mounted in the pod, but ImagePullSecrets are only accessed by the kubelet.
            More info: https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod
            '';
          type = (listOf LocalObjectReference);
        };
        automountServiceAccountToken = mkOption {
          description = ''
            AutomountServiceAccountToken indicates whether pods running as this service account should have an API token automatically mounted.
            Can be overridden at the pod level.
            '';
          type = bool;
        };
      };
    };
  };
  AWSElasticBlockStoreVolumeSource = lib.mkOption {
    description = ''
      Represents a Persistent Disk resource in AWS.
      
      An AWS EBS disk must exist before mounting to a container. The disk
      must also be in the same AWS zone as the kubelet. An AWS EBS disk
      can only be mounted as read/write once. AWS EBS volumes support
      ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        volumeID = mkOption {
          description = ''
            volumeID is unique ID of the persistent disk resource in AWS (Amazon EBS volume).
            More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type of the volume that you want to mount.
            Tip: Ensure that the filesystem type is supported by the host operating system.
            Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
            TODO: how do we prevent errors in the filesystem from compromising the machine
            '';
          type = str;
        };
        partition = mkOption {
          description = ''
            partition is the partition in the volume that you want to mount.
            If omitted, the default is to mount by volume name.
            Examples: For volume /dev/sda1, you specify the partition as "1".
            Similarly, the volume partition for /dev/sda is "0" (or you can leave the property empty).
            '';
          type = int;
        };
        readOnly = mkOption {
          description = ''
            readOnly value true will force the readOnly setting in VolumeMounts.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
            '';
          type = bool;
        };
      };
    };
  };
  Affinity = lib.mkOption {
    description = ''
      Affinity is a group of affinity scheduling rules.
      '';
    type = submodule {
      options = {
        nodeAffinity = mkOption {
          description = ''
            Describes node affinity scheduling rules for the pod.
            '';
          type = NodeAffinity;
        };
        podAffinity = mkOption {
          description = ''
            Describes pod affinity scheduling rules (e.g. co-locate this pod in the same node, zone, etc. as some other pod(s)).
            '';
          type = PodAffinity;
        };
        podAntiAffinity = mkOption {
          description = ''
            Describes pod anti-affinity scheduling rules (e.g. avoid putting this pod in the same node, zone, etc. as some other pod(s)).
            '';
          type = PodAntiAffinity;
        };
      };
    };
  };
  AttachedVolume = lib.mkOption {
    description = ''
      AttachedVolume describes a volume attached to a node
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name of the attached volume
            '';
          type = UniqueVolumeName;
        };
        devicePath = mkOption {
          description = ''
            DevicePath represents the device path where the volume should be available
            '';
          type = str;
        };
      };
    };
  };
  AzureDataDiskCachingMode = lib.mkOption {
    description = ''

      '';
  };
  AzureDataDiskKind = lib.mkOption {
    description = ''

      '';
  };
  AzureDiskVolumeSource = lib.mkOption {
    description = ''
      AzureDisk represents an Azure Data Disk mount on the host and bind mount to the pod.
      '';
    type = submodule {
      options = {
        diskName = mkOption {
          description = ''
            diskName is the Name of the data disk in the blob storage
            '';
          type = str;
        };
        diskURI = mkOption {
          description = ''
            diskURI is the URI of data disk in the blob storage
            '';
          type = str;
        };
        cachingMode = mkOption {
          description = ''
            cachingMode is the Host Caching mode: None, Read Only, Read Write.
            '';
          type = AzureDataDiskCachingMode;
        };
        fsType = mkOption {
          description = ''
            fsType is Filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly Defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            '';
          type = bool;
        };
        kind = mkOption {
          description = ''
            kind expected values are Shared: multiple blob disks per storage account  Dedicated: single blob disk per storage account  Managed: azure managed data disk (only in managed availability set). defaults to shared
            '';
          type = AzureDataDiskKind;
        };
      };
    };
  };
  AzureFilePersistentVolumeSource = lib.mkOption {
    description = ''
      AzureFile represents an Azure File Service mount on the host and bind mount to the pod.
      '';
    type = submodule {
      options = {
        secretName = mkOption {
          description = ''
            secretName is the name of secret that contains Azure Storage Account Name and Key
            '';
          type = str;
        };
        shareName = mkOption {
          description = ''
            shareName is the azure Share Name
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            '';
          type = bool;
        };
        secretNamespace = mkOption {
          description = ''
            secretNamespace is the namespace of the secret that contains Azure Storage Account Name and Key
            default is the same as the Pod
            '';
          type = str;
        };
      };
    };
  };
  AzureFileVolumeSource = lib.mkOption {
    description = ''
      AzureFile represents an Azure File Service mount on the host and bind mount to the pod.
      '';
    type = submodule {
      options = {
        secretName = mkOption {
          description = ''
            secretName is the  name of secret that contains Azure Storage Account Name and Key
            '';
          type = str;
        };
        shareName = mkOption {
          description = ''
            shareName is the azure share Name
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            '';
          type = bool;
        };
      };
    };
  };
  CSIPersistentVolumeSource = lib.mkOption {
    description = ''
      Represents storage that is managed by an external CSI volume driver (Beta feature)
      '';
    type = submodule {
      options = {
        driver = mkOption {
          description = ''
            driver is the name of the driver to use for this volume.
            Required.
            '';
          type = str;
        };
        volumeHandle = mkOption {
          description = ''
            volumeHandle is the unique volume name returned by the CSI volume
            plugin’s CreateVolume to refer to the volume on all subsequent calls.
            Required.
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly value to pass to ControllerPublishVolumeRequest.
            Defaults to false (read/write).
            '';
          type = bool;
        };
        fsType = mkOption {
          description = ''
            fsType to mount. Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs".
            '';
          type = str;
        };
        volumeAttributes = mkOption {
          description = ''
            volumeAttributes of the volume to publish.
            '';
          type = (attrsOf str);
        };
        controllerPublishSecretRef = mkOption {
          description = ''
            controllerPublishSecretRef is a reference to the secret object containing
            sensitive information to pass to the CSI driver to complete the CSI
            ControllerPublishVolume and ControllerUnpublishVolume calls.
            This field is optional, and may be empty if no secret is required. If the
            secret object contains more than one secret, all secrets are passed.
            '';
          type = SecretReference;
        };
        nodeStageSecretRef = mkOption {
          description = ''
            nodeStageSecretRef is a reference to the secret object containing sensitive
            information to pass to the CSI driver to complete the CSI NodeStageVolume
            and NodeStageVolume and NodeUnstageVolume calls.
            This field is optional, and may be empty if no secret is required. If the
            secret object contains more than one secret, all secrets are passed.
            '';
          type = SecretReference;
        };
        nodePublishSecretRef = mkOption {
          description = ''
            nodePublishSecretRef is a reference to the secret object containing
            sensitive information to pass to the CSI driver to complete the CSI
            NodePublishVolume and NodeUnpublishVolume calls.
            This field is optional, and may be empty if no secret is required. If the
            secret object contains more than one secret, all secrets are passed.
            '';
          type = SecretReference;
        };
        controllerExpandSecretRef = mkOption {
          description = ''
            controllerExpandSecretRef is a reference to the secret object containing
            sensitive information to pass to the CSI driver to complete the CSI
            ControllerExpandVolume call.
            This is an beta field and requires enabling ExpandCSIVolumes feature gate.
            This field is optional, and may be empty if no secret is required. If the
            secret object contains more than one secret, all secrets are passed.
            '';
          type = SecretReference;
        };
        nodeExpandSecretRef = mkOption {
          description = ''
            nodeExpandSecretRef is a reference to the secret object containing
            sensitive information to pass to the CSI driver to complete the CSI
            NodeExpandVolume call.
            This is an alpha field and requires enabling CSINodeExpandSecret feature gate.
            This field is optional, may be omitted if no secret is required. If the
            secret object contains more than one secret, all secrets are passed.
            '';
          type = SecretReference;
        };
      };
    };
  };
  CSIVolumeSource = lib.mkOption {
    description = ''
      Represents a source location of a volume to mount, managed by an external CSI driver
      '';
    type = submodule {
      options = {
        driver = mkOption {
          description = ''
            driver is the name of the CSI driver that handles this volume.
            Consult with your admin for the correct name as registered in the cluster.
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly specifies a read-only configuration for the volume.
            Defaults to false (read/write).
            '';
          type = bool;
        };
        fsType = mkOption {
          description = ''
            fsType to mount. Ex. "ext4", "xfs", "ntfs".
            If not provided, the empty value is passed to the associated CSI driver
            which will determine the default filesystem to apply.
            '';
          type = str;
        };
        volumeAttributes = mkOption {
          description = ''
            volumeAttributes stores driver-specific properties that are passed to the CSI
            driver. Consult your driver's documentation for supported values.
            '';
          type = (attrsOf str);
        };
        nodePublishSecretRef = mkOption {
          description = ''
            nodePublishSecretRef is a reference to the secret object containing
            sensitive information to pass to the CSI driver to complete the CSI
            NodePublishVolume and NodeUnpublishVolume calls.
            This field is optional, and  may be empty if no secret is required. If the
            secret object contains more than one secret, all secret references are passed.
            '';
          type = LocalObjectReference;
        };
      };
    };
  };
  Capabilities = lib.mkOption {
    description = ''
      Adds and removes POSIX capabilities from running containers.
      '';
    type = submodule {
      options = {
        add = mkOption {
          description = ''
            Added capabilities
            '';
          type = (listOf Capability);
        };
        drop = mkOption {
          description = ''
            Removed capabilities
            '';
          type = (listOf Capability);
        };
      };
    };
  };
  Capability = lib.mkOption {
    description = ''
      Capability represent POSIX capabilities type
      '';
  };
  CephFSPersistentVolumeSource = lib.mkOption {
    description = ''
      Represents a Ceph Filesystem mount that lasts the lifetime of a pod
      Cephfs volumes do not support ownership management or SELinux relabeling.
      '';
    type = submodule {
      options = {
        monitors = mkOption {
          description = ''
            monitors is Required: Monitors is a collection of Ceph monitors
            More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
            '';
          type = (listOf str);
        };
        path = mkOption {
          description = ''
            path is Optional: Used as the mounted root, rather than the full Ceph tree, default is /
            '';
          type = str;
        };
        user = mkOption {
          description = ''
            user is Optional: User is the rados user name, default is admin
            More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
            '';
          type = str;
        };
        secretFile = mkOption {
          description = ''
            secretFile is Optional: SecretFile is the path to key ring for User, default is /etc/ceph/user.secret
            More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
            '';
          type = str;
        };
        secretRef = mkOption {
          description = ''
            secretRef is Optional: SecretRef is reference to the authentication secret for User, default is empty.
            More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
            '';
          type = SecretReference;
        };
        readOnly = mkOption {
          description = ''
            readOnly is Optional: Defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
            '';
          type = bool;
        };
      };
    };
  };
  CephFSVolumeSource = lib.mkOption {
    description = ''
      Represents a Ceph Filesystem mount that lasts the lifetime of a pod
      Cephfs volumes do not support ownership management or SELinux relabeling.
      '';
    type = submodule {
      options = {
        monitors = mkOption {
          description = ''
            monitors is Required: Monitors is a collection of Ceph monitors
            More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
            '';
          type = (listOf str);
        };
        path = mkOption {
          description = ''
            path is Optional: Used as the mounted root, rather than the full Ceph tree, default is /
            '';
          type = str;
        };
        user = mkOption {
          description = ''
            user is optional: User is the rados user name, default is admin
            More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
            '';
          type = str;
        };
        secretFile = mkOption {
          description = ''
            secretFile is Optional: SecretFile is the path to key ring for User, default is /etc/ceph/user.secret
            More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
            '';
          type = str;
        };
        secretRef = mkOption {
          description = ''
            secretRef is Optional: SecretRef is reference to the authentication secret for User, default is empty.
            More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
            '';
          type = LocalObjectReference;
        };
        readOnly = mkOption {
          description = ''
            readOnly is Optional: Defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
            '';
          type = bool;
        };
      };
    };
  };
  CinderPersistentVolumeSource = lib.mkOption {
    description = ''
      Represents a cinder volume resource in Openstack.
      A Cinder volume must exist before mounting to a container.
      The volume must also be in the same region as the kubelet.
      Cinder volumes support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        volumeID = mkOption {
          description = ''
            volumeID used to identify the volume in cinder.
            More info: https://examples.k8s.io/mysql-cinder-pd/README.md
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType Filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            More info: https://examples.k8s.io/mysql-cinder-pd/README.md
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly is Optional: Defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            More info: https://examples.k8s.io/mysql-cinder-pd/README.md
            '';
          type = bool;
        };
        secretRef = mkOption {
          description = ''
            secretRef is Optional: points to a secret object containing parameters used to connect
            to OpenStack.
            '';
          type = SecretReference;
        };
      };
    };
  };
  CinderVolumeSource = lib.mkOption {
    description = ''
      Represents a cinder volume resource in Openstack.
      A Cinder volume must exist before mounting to a container.
      The volume must also be in the same region as the kubelet.
      Cinder volumes support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        volumeID = mkOption {
          description = ''
            volumeID used to identify the volume in cinder.
            More info: https://examples.k8s.io/mysql-cinder-pd/README.md
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            More info: https://examples.k8s.io/mysql-cinder-pd/README.md
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            More info: https://examples.k8s.io/mysql-cinder-pd/README.md
            '';
          type = bool;
        };
        secretRef = mkOption {
          description = ''
            secretRef is optional: points to a secret object containing parameters used to connect
            to OpenStack.
            '';
          type = LocalObjectReference;
        };
      };
    };
  };
  ClaimSource = lib.mkOption {
    description = ''
      ClaimSource describes a reference to a ResourceClaim.
      
      Exactly one of these fields should be set.  Consumers of this type must
      treat an empty object as if it has an unknown value.
      '';
    type = submodule {
      options = {
        resourceClaimName = mkOption {
          description = ''
            ResourceClaimName is the name of a ResourceClaim object in the same
            namespace as this pod.
            '';
          type = str;
        };
        resourceClaimTemplateName = mkOption {
          description = ''
            ResourceClaimTemplateName is the name of a ResourceClaimTemplate
            object in the same namespace as this pod.
            
            The template will be used to create a new ResourceClaim, which will
            be bound to this pod. When this pod is deleted, the ResourceClaim
            will also be deleted. The name of the ResourceClaim will be <pod
            name>-<resource name>, where <resource name> is the
            PodResourceClaim.Name. Pod validation will reject the pod if the
            concatenated name is not valid for a ResourceClaim (e.g. too long).
            
            An existing ResourceClaim with that name that is not owned by the
            pod will not be used for the pod to avoid using an unrelated
            resource by mistake. Scheduling and pod startup are then blocked
            until the unrelated ResourceClaim is removed.
            
            This field is immutable and no changes will be made to the
            corresponding ResourceClaim by the control plane after creating the
            ResourceClaim.
            '';
          type = str;
        };
      };
    };
  };
  ClientIPConfig = lib.mkOption {
    description = ''
      ClientIPConfig represents the configurations of Client IP based session affinity.
      '';
    type = submodule {
      options = {
        timeoutSeconds = mkOption {
          description = ''
            timeoutSeconds specifies the seconds of ClientIP type session sticky time.
            The value must be >0 && <=86400(for 1 day) if ServiceAffinity == "ClientIP".
            Default value is 10800(for 3 hours).
            '';
          type = int;
        };
      };
    };
  };
  ComponentCondition = lib.mkOption {
    description = ''
      Information about the condition of a component.
      '';
    type = submodule {
      options = {
        type = mkOption {
          description = ''
            Type of condition for a component.
            Valid value: "Healthy"
            '';
          type = ComponentConditionType;
        };
        status = mkOption {
          description = ''
            Status of the condition for a component.
            Valid values for "Healthy": "True", "False", or "Unknown".
            '';
          type = ConditionStatus;
        };
        message = mkOption {
          description = ''
            Message about the condition for a component.
            For example, information about a health check.
            '';
          type = str;
        };
        error = mkOption {
          description = ''
            Condition error code for a component.
            For example, a health check error code.
            '';
          type = str;
        };
      };
    };
  };
  ComponentConditionType = lib.mkOption {
    description = ''
      Type and constants for component health validation.
      '';
  };
  ConditionStatus = lib.mkOption {
    description = ''
      
      '';
  };
  ConfigMapEnvSource = lib.mkOption {
    description = ''
      ConfigMapEnvSource selects a ConfigMap to populate the environment
      variables with.
      
      The contents of the target ConfigMap's Data field will represent the
      key-value pairs as environment variables.
      '';
    type = submodule {
      options = {
        LocalObjectReference = mkOption {
          description = ''
            The ConfigMap to select from.
            '';
          type = LocalObjectReference;
        };
        optional = mkOption {
          description = ''
            Specify whether the ConfigMap must be defined
            '';
          type = bool;
        };
      };
    };
  };
  ConfigMapKeySelector = lib.mkOption {
    description = ''
      Selects a key from a ConfigMap.
      '';
    type = submodule {
      options = {
        LocalObjectReference = mkOption {
          description = ''
            The ConfigMap to select from.
            '';
          type = LocalObjectReference;
        };
        key = mkOption {
          description = ''
            The key to select.
            '';
          type = str;
        };
        optional = mkOption {
          description = ''
            Specify whether the ConfigMap or its key must be defined
            '';
          type = bool;
        };
      };
    };
  };
  ConfigMapNodeConfigSource = lib.mkOption {
    description = ''
      ConfigMapNodeConfigSource contains the information to reference a ConfigMap as a config source for the Node.
      This API is deprecated since 1.22: https://git.k8s.io/enhancements/keps/sig-node/281-dynamic-kubelet-configuration
      '';
    type = submodule {
      options = {
        namespace = mkOption {
          description = ''
            Namespace is the metadata.namespace of the referenced ConfigMap.
            This field is required in all cases.
            '';
          type = str;
        };
        name = mkOption {
          description = ''
            Name is the metadata.name of the referenced ConfigMap.
            This field is required in all cases.
            '';
          type = str;
        };
        uid = mkOption {
          description = ''
            UID is the metadata.UID of the referenced ConfigMap.
            This field is forbidden in Node.Spec, and required in Node.Status.
            '';
          type = k8s.io/apimachinery/pkg/types.UID;
        };
        resourceVersion = mkOption {
          description = ''
            ResourceVersion is the metadata.ResourceVersion of the referenced ConfigMap.
            This field is forbidden in Node.Spec, and required in Node.Status.
            '';
          type = str;
        };
        kubeletConfigKey = mkOption {
          description = ''
            KubeletConfigKey declares which key of the referenced ConfigMap corresponds to the KubeletConfiguration structure
            This field is required in all cases.
            '';
          type = str;
        };
      };
    };
  };
  ConfigMapProjection = lib.mkOption {
    description = ''
      Adapts a ConfigMap into a projected volume.
      
      The contents of the target ConfigMap's Data field will be presented in a
      projected volume as files using the keys in the Data field as the file names,
      unless the items element is populated with specific mappings of keys to paths.
      Note that this is identical to a configmap volume source without the default
      mode.
      '';
    type = submodule {
      options = {
        LocalObjectReference = mkOption {
          description = ''
            
            '';
          type = LocalObjectReference;
        };
        items = mkOption {
          description = ''
            items if unspecified, each key-value pair in the Data field of the referenced
            ConfigMap will be projected into the volume as a file whose name is the
            key and content is the value. If specified, the listed keys will be
            projected into the specified paths, and unlisted keys will not be
            present. If a key is specified which is not present in the ConfigMap,
            the volume setup will error unless it is marked optional. Paths must be
            relative and may not contain the '..' path or start with '..'.
            '';
          type = (listOf KeyToPath);
        };
        optional = mkOption {
          description = ''
            optional specify whether the ConfigMap or its keys must be defined
            '';
          type = bool;
        };
      };
    };
  };
  ConfigMapVolumeSource = lib.mkOption {
    description = ''
      Adapts a ConfigMap into a volume.
      
      The contents of the target ConfigMap's Data field will be presented in a
      volume as files using the keys in the Data field as the file names, unless
      the items element is populated with specific mappings of keys to paths.
      ConfigMap volumes support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        LocalObjectReference = mkOption {
          description = ''
            
            '';
          type = LocalObjectReference;
        };
        items = mkOption {
          description = ''
            items if unspecified, each key-value pair in the Data field of the referenced
            ConfigMap will be projected into the volume as a file whose name is the
            key and content is the value. If specified, the listed keys will be
            projected into the specified paths, and unlisted keys will not be
            present. If a key is specified which is not present in the ConfigMap,
            the volume setup will error unless it is marked optional. Paths must be
            relative and may not contain the '..' path or start with '..'.
            '';
          type = (listOf KeyToPath);
        };
        defaultMode = mkOption {
          description = ''
            defaultMode is optional: mode bits used to set permissions on created files by default.
            Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
            YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
            Defaults to 0644.
            Directories within the path are not affected by this setting.
            This might be in conflict with other options that affect the file
            mode, like fsGroup, and the result can be other mode bits set.
            '';
          type = int;
        };
        optional = mkOption {
          description = ''
            optional specify whether the ConfigMap or its keys must be defined
            '';
          type = bool;
        };
      };
    };
  };
  Container = lib.mkOption {
    description = ''
      A single application container that you want to run within a pod.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name of the container specified as a DNS_LABEL.
            Each container in a pod must have a unique name (DNS_LABEL).
            Cannot be updated.
            '';
          type = str;
        };
        image = mkOption {
          description = ''
            Container image name.
            More info: https://kubernetes.io/docs/concepts/containers/images
            This field is optional to allow higher level config management to default or override
            container images in workload controllers like Deployments and StatefulSets.
            '';
          type = str;
        };
        command = mkOption {
          description = ''
            Entrypoint array. Not executed within a shell.
            The container image's ENTRYPOINT is used if this is not provided.
            Variable references $(VAR_NAME) are expanded using the container's environment. If a variable
            cannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced
            to a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. "$$(VAR_NAME)" will
            produce the string literal "$(VAR_NAME)". Escaped references will never be expanded, regardless
            of whether the variable exists or not. Cannot be updated.
            More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
            '';
          type = (listOf str);
        };
        args = mkOption {
          description = ''
            Arguments to the entrypoint.
            The container image's CMD is used if this is not provided.
            Variable references $(VAR_NAME) are expanded using the container's environment. If a variable
            cannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced
            to a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. "$$(VAR_NAME)" will
            produce the string literal "$(VAR_NAME)". Escaped references will never be expanded, regardless
            of whether the variable exists or not. Cannot be updated.
            More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
            '';
          type = (listOf str);
        };
        workingDir = mkOption {
          description = ''
            Container's working directory.
            If not specified, the container runtime's default will be used, which
            might be configured in the container image.
            Cannot be updated.
            '';
          type = str;
        };
        ports = mkOption {
          description = ''
            List of ports to expose from the container. Not specifying a port here
            DOES NOT prevent that port from being exposed. Any port which is
            listening on the default "0.0.0.0" address inside a container will be
            accessible from the network.
            Modifying this array with strategic merge patch may corrupt the data.
            For more information See https://github.com/kubernetes/kubernetes/issues/108255.
            Cannot be updated.
            '';
          type = (listOf ContainerPort);
        };
        envFrom = mkOption {
          description = ''
            List of sources to populate environment variables in the container.
            The keys defined within a source must be a C_IDENTIFIER. All invalid keys
            will be reported as an event when the container is starting. When a key exists in multiple
            sources, the value associated with the last source will take precedence.
            Values defined by an Env with a duplicate key will take precedence.
            Cannot be updated.
            '';
          type = (listOf EnvFromSource);
        };
        env = mkOption {
          description = ''
            List of environment variables to set in the container.
            Cannot be updated.
            '';
          type = (listOf EnvVar);
        };
        resources = mkOption {
          description = ''
            Compute Resources required by this container.
            Cannot be updated.
            More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
            '';
          type = ResourceRequirements;
        };
        volumeMounts = mkOption {
          description = ''
            Pod volumes to mount into the container's filesystem.
            Cannot be updated.
            '';
          type = (listOf VolumeMount);
        };
        volumeDevices = mkOption {
          description = ''
            volumeDevices is the list of block devices to be used by the container.
            '';
          type = (listOf VolumeDevice);
        };
        livenessProbe = mkOption {
          description = ''
            Periodic probe of container liveness.
            Container will be restarted if the probe fails.
            Cannot be updated.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
            '';
          type = Probe;
        };
        readinessProbe = mkOption {
          description = ''
            Periodic probe of container service readiness.
            Container will be removed from service endpoints if the probe fails.
            Cannot be updated.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
            '';
          type = Probe;
        };
        startupProbe = mkOption {
          description = ''
            StartupProbe indicates that the Pod has successfully initialized.
            If specified, no other probes are executed until this completes successfully.
            If this probe fails, the Pod will be restarted, just as if the livenessProbe failed.
            This can be used to provide different probe parameters at the beginning of a Pod's lifecycle,
            when it might take a long time to load data or warm a cache, than during steady-state operation.
            This cannot be updated.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
            '';
          type = Probe;
        };
        lifecycle = mkOption {
          description = ''
            Actions that the management system should take in response to container lifecycle events.
            Cannot be updated.
            '';
          type = Lifecycle;
        };
        terminationMessagePath = mkOption {
          description = ''
            Optional: Path at which the file to which the container's termination message
            will be written is mounted into the container's filesystem.
            Message written is intended to be brief final status, such as an assertion failure message.
            Will be truncated by the node if greater than 4096 bytes. The total message length across
            all containers will be limited to 12kb.
            Defaults to /dev/termination-log.
            Cannot be updated.
            '';
          type = str;
        };
        terminationMessagePolicy = mkOption {
          description = ''
            Indicate how the termination message should be populated. File will use the contents of
            terminationMessagePath to populate the container status message on both success and failure.
            FallbackToLogsOnError will use the last chunk of container log output if the termination
            message file is empty and the container exited with an error.
            The log output is limited to 2048 bytes or 80 lines, whichever is smaller.
            Defaults to File.
            Cannot be updated.
            '';
          type = TerminationMessagePolicy;
        };
        imagePullPolicy = mkOption {
          description = ''
            Image pull policy.
            One of Always, Never, IfNotPresent.
            Defaults to Always if :latest tag is specified, or IfNotPresent otherwise.
            Cannot be updated.
            More info: https://kubernetes.io/docs/concepts/containers/images#updating-images
            '';
          type = PullPolicy;
        };
        securityContext = mkOption {
          description = ''
            SecurityContext defines the security options the container should be run with.
            If set, the fields of SecurityContext override the equivalent fields of PodSecurityContext.
            More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
            '';
          type = SecurityContext;
        };
        stdin = mkOption {
          description = ''
            Whether this container should allocate a buffer for stdin in the container runtime. If this
            is not set, reads from stdin in the container will always result in EOF.
            Default is false.
            '';
          type = bool;
        };
        stdinOnce = mkOption {
          description = ''
            Whether the container runtime should close the stdin channel after it has been opened by
            a single attach. When stdin is true the stdin stream will remain open across multiple attach
            sessions. If stdinOnce is set to true, stdin is opened on container start, is empty until the
            first client attaches to stdin, and then remains open and accepts data until the client disconnects,
            at which time stdin is closed and remains closed until the container is restarted. If this
            flag is false, a container processes that reads from stdin will never receive an EOF.
            Default is false
            '';
          type = bool;
        };
        tty = mkOption {
          description = ''
            Whether this container should allocate a TTY for itself, also requires 'stdin' to be true.
            Default is false.
            '';
          type = bool;
        };
      };
    };
  };
  ContainerImage = lib.mkOption {
    description = ''
      Describe a container image
      '';
    type = submodule {
      options = {
        names = mkOption {
          description = ''
            Names by which this image is known.
            e.g. ["kubernetes.example/hyperkube:v1.0.7", "cloud-vendor.registry.example/cloud-vendor/hyperkube:v1.0.7"]
            '';
          type = (listOf str);
        };
        sizeBytes = mkOption {
          description = ''
            The size of the image in bytes.
            '';
          type = int;
        };
      };
    };
  };
  ContainerPort = lib.mkOption {
    description = ''
      ContainerPort represents a network port in a single container.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            If specified, this must be an IANA_SVC_NAME and unique within the pod. Each
            named port in a pod must have a unique name. Name for the port that can be
            referred to by services.
            '';
          type = str;
        };
        hostPort = mkOption {
          description = ''
            Number of port to expose on the host.
            If specified, this must be a valid port number, 0 < x < 65536.
            If HostNetwork is specified, this must match ContainerPort.
            Most containers do not need this.
            '';
          type = int;
        };
        containerPort = mkOption {
          description = ''
            Number of port to expose on the pod's IP address.
            This must be a valid port number, 0 < x < 65536.
            '';
          type = int;
        };
        protocol = mkOption {
          description = ''
            Protocol for port. Must be UDP, TCP, or SCTP.
            Defaults to "TCP".
            '';
          type = Protocol;
        };
        hostIP = mkOption {
          description = ''
            What host IP to bind the external port to.
            '';
          type = str;
        };
      };
    };
  };
  ContainerState = lib.mkOption {
    description = ''
      ContainerState holds a possible state of container.
      Only one of its members may be specified.
      If none of them is specified, the default one is ContainerStateWaiting.
      '';
    type = submodule {
      options = {
        waiting = mkOption {
          description = ''
            Details about a waiting container
            '';
          type = ContainerStateWaiting;
        };
        running = mkOption {
          description = ''
            Details about a running container
            '';
          type = ContainerStateRunning;
        };
        terminated = mkOption {
          description = ''
            Details about a terminated container
            '';
          type = ContainerStateTerminated;
        };
      };
    };
  };
  ContainerStateRunning = lib.mkOption {
    description = ''
      ContainerStateRunning is a running state of a container.
      '';
    type = submodule {
      options = {
        startedAt = mkOption {
          description = ''
            Time at which the container was last (re-)started
            '';
          type = meta/v1.Time;
        };
      };
    };
  };
  ContainerStateTerminated = lib.mkOption {
    description = ''
      ContainerStateTerminated is a terminated state of a container.
      '';
    type = submodule {
      options = {
        exitCode = mkOption {
          description = ''
            Exit status from the last termination of the container
            '';
          type = int;
        };
        signal = mkOption {
          description = ''
            Signal from the last termination of the container
            '';
          type = int;
        };
        reason = mkOption {
          description = ''
            (brief) reason from the last termination of the container
            '';
          type = str;
        };
        message = mkOption {
          description = ''
            Message regarding the last termination of the container
            '';
          type = str;
        };
        startedAt = mkOption {
          description = ''
            Time at which previous execution of the container started
            '';
          type = meta/v1.Time;
        };
        finishedAt = mkOption {
          description = ''
            Time at which the container last terminated
            '';
          type = meta/v1.Time;
        };
        containerID = mkOption {
          description = ''
            Container's ID in the format '<type>://<container_id>'
            '';
          type = str;
        };
      };
    };
  };
  ContainerStateWaiting = lib.mkOption {
    description = ''
      ContainerStateWaiting is a waiting state of a container.
      '';
    type = submodule {
      options = {
        reason = mkOption {
          description = ''
            (brief) reason the container is not yet running.
            '';
          type = str;
        };
        message = mkOption {
          description = ''
            Message regarding why the container is not yet running.
            '';
          type = str;
        };
      };
    };
  };
  ContainerStatus = lib.mkOption {
    description = ''
      ContainerStatus contains details for the current status of this container.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            This must be a DNS_LABEL. Each container in a pod must have a unique name.
            Cannot be updated.
            '';
          type = str;
        };
        state = mkOption {
          description = ''
            Details about the container's current condition.
            '';
          type = ContainerState;
        };
        lastState = mkOption {
          description = ''
            Details about the container's last termination condition.
            '';
          type = ContainerState;
        };
        ready = mkOption {
          description = ''
            Specifies whether the container has passed its readiness probe.
            '';
          type = bool;
        };
        restartCount = mkOption {
          description = ''
            The number of times the container has been restarted.
            '';
          type = int;
        };
        image = mkOption {
          description = ''
            The image the container is running.
            More info: https://kubernetes.io/docs/concepts/containers/images.
            '';
          type = str;
        };
        imageID = mkOption {
          description = ''
            ImageID of the container's image.
            '';
          type = str;
        };
        containerID = mkOption {
          description = ''
            Container's ID in the format '<type>://<container_id>'.
            '';
          type = str;
        };
        started = mkOption {
          description = ''
            Specifies whether the container has passed its startup probe.
            Initialized as false, becomes true after startupProbe is considered successful.
            Resets to false when the container is restarted, or if kubelet loses state temporarily.
            Is always true when no startupProbe is defined.
            '';
          type = bool;
        };
      };
    };
  };
  DNSPolicy = lib.mkOption {
    description = ''
      DNSPolicy defines how a pod's DNS will be configured.
      '';
  };
  DaemonEndpoint = lib.mkOption {
    description = ''
      DaemonEndpoint contains information about a single Daemon endpoint.
      '';
    type = submodule {
      options = {
        Port = mkOption {
          description = ''
            Port number of the given endpoint.
            '';
          type = int;
        };
      };
    };
  };
  DownwardAPIProjection = lib.mkOption {
    description = ''
      Represents downward API info for projecting into a projected volume.
      Note that this is identical to a downwardAPI volume source without the default
      mode.
      '';
    type = submodule {
      options = {
        items = mkOption {
          description = ''
            Items is a list of DownwardAPIVolume file
            '';
          type = (listOf DownwardAPIVolumeFile);
        };
      };
    };
  };
  DownwardAPIVolumeFile = lib.mkOption {
    description = ''
      DownwardAPIVolumeFile represents information to create the file containing the pod field
      '';
    type = submodule {
      options = {
        path = mkOption {
          description = ''
            Required: Path is  the relative path name of the file to be created. Must not be absolute or contain the '..' path. Must be utf-8 encoded. The first item of the relative path must not start with '..'
            '';
          type = str;
        };
        fieldRef = mkOption {
          description = ''
            Required: Selects a field of the pod: only annotations, labels, name and namespace are supported.
            '';
          type = ObjectFieldSelector;
        };
        resourceFieldRef = mkOption {
          description = ''
            Selects a resource of the container: only resources limits and requests
            (limits.cpu, limits.memory, requests.cpu and requests.memory) are currently supported.
            '';
          type = ResourceFieldSelector;
        };
        mode = mkOption {
          description = ''
            Optional: mode bits used to set permissions on this file, must be an octal value
            between 0000 and 0777 or a decimal value between 0 and 511.
            YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
            If not specified, the volume defaultMode will be used.
            This might be in conflict with other options that affect the file
            mode, like fsGroup, and the result can be other mode bits set.
            '';
          type = int;
        };
      };
    };
  };
  DownwardAPIVolumeSource = lib.mkOption {
    description = ''
      DownwardAPIVolumeSource represents a volume containing downward API info.
      Downward API volumes support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        items = mkOption {
          description = ''
            Items is a list of downward API volume file
            '';
          type = (listOf DownwardAPIVolumeFile);
        };
        defaultMode = mkOption {
          description = ''
            Optional: mode bits to use on created files by default. Must be a
            Optional: mode bits used to set permissions on created files by default.
            Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
            YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
            Defaults to 0644.
            Directories within the path are not affected by this setting.
            This might be in conflict with other options that affect the file
            mode, like fsGroup, and the result can be other mode bits set.
            '';
          type = int;
        };
      };
    };
  };
  EmptyDirVolumeSource = lib.mkOption {
    description = ''
      Represents an empty directory for a pod.
      Empty directory volumes support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        medium = mkOption {
          description = ''
            medium represents what type of storage medium should back this directory.
            The default is "" which means to use the node's default medium.
            Must be an empty string (default) or Memory.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir
            '';
          type = StorageMedium;
        };
        sizeLimit = mkOption {
          description = ''
            sizeLimit is the total amount of local storage required for this EmptyDir volume.
            The size limit is also applicable for memory medium.
            The maximum usage on memory medium EmptyDir would be the minimum value between
            the SizeLimit specified here and the sum of memory limits of all containers in a pod.
            The default is nil which means that the limit is undefined.
            More info: http://kubernetes.io/docs/user-guide/volumes#emptydir
            '';
          type = k8s.io/apimachinery/pkg/api/resource.Quantity;
        };
      };
    };
  };
  EndpointAddress = lib.mkOption {
    description = ''
      EndpointAddress is a tuple that describes single IP address.
      '';
    type = submodule {
      options = {
        ip = mkOption {
          description = ''
            The IP of this endpoint.
            May not be loopback (127.0.0.0/8), link-local (169.254.0.0/16),
            or link-local multicast ((224.0.0.0/24).
            IPv6 is also accepted but not fully supported on all platforms. Also, certain
            kubernetes components, like kube-proxy, are not IPv6 ready.
            TODO: This should allow hostname or IP, See #4447.
            '';
          type = str;
        };
        hostname = mkOption {
          description = ''
            The Hostname of this endpoint
            '';
          type = str;
        };
        nodeName = mkOption {
          description = ''
            Optional: Node hosting this endpoint. This can be used to determine endpoints local to a node.
            '';
          type = str;
        };
        targetRef = mkOption {
          description = ''
            Reference to object providing the endpoint.
            '';
          type = ObjectReference;
        };
      };
    };
  };
  EndpointPort = lib.mkOption {
    description = ''
      EndpointPort is a tuple that describes a single port.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            The name of this port.  This must match the 'name' field in the
            corresponding ServicePort.
            Must be a DNS_LABEL.
            Optional only if one port is defined.
            '';
          type = str;
        };
        port = mkOption {
          description = ''
            The port number of the endpoint.
            '';
          type = int;
        };
        protocol = mkOption {
          description = ''
            The IP protocol for this port.
            Must be UDP, TCP, or SCTP.
            Default is TCP.
            '';
          type = Protocol;
        };
        appProtocol = mkOption {
          description = ''
            The application protocol for this port.
            This field follows standard Kubernetes label syntax.
            Un-prefixed names are reserved for IANA standard service names (as per
            RFC-6335 and https://www.iana.org/assignments/service-names).
            Non-standard protocols should use prefixed names such as
            mycompany.com/my-custom-protocol.
            '';
          type = str;
        };
      };
    };
  };
  EndpointSubset = lib.mkOption {
    description = ''
      EndpointSubset is a group of addresses with a common set of ports. The
      expanded set of endpoints is the Cartesian product of Addresses x Ports.
      For example, given:
      
      	{
      	  Addresses: [{"ip": "10.10.1.1"}, {"ip": "10.10.2.2"}],
      	  Ports:     [{"name": "a", "port": 8675}, {"name": "b", "port": 309}]
      	}
      
      The resulting set of endpoints can be viewed as:
      
      	a: [ 10.10.1.1:8675, 10.10.2.2:8675 ],
      	b: [ 10.10.1.1:309, 10.10.2.2:309 ]
      '';
    type = submodule {
      options = {
        addresses = mkOption {
          description = ''
            IP addresses which offer the related ports that are marked as ready. These endpoints
            should be considered safe for load balancers and clients to utilize.
            '';
          type = (listOf EndpointAddress);
        };
        notReadyAddresses = mkOption {
          description = ''
            IP addresses which offer the related ports but are not currently marked as ready
            because they have not yet finished starting, have recently failed a readiness check,
            or have recently failed a liveness check.
            '';
          type = (listOf EndpointAddress);
        };
        ports = mkOption {
          description = ''
            Port numbers available on the related IP addresses.
            '';
          type = (listOf EndpointPort);
        };
      };
    };
  };
  EnvFromSource = lib.mkOption {
    description = ''
      EnvFromSource represents the source of a set of ConfigMaps
      '';
    type = submodule {
      options = {
        prefix = mkOption {
          description = ''
            An optional identifier to prepend to each key in the ConfigMap. Must be a C_IDENTIFIER.
            '';
          type = str;
        };
        configMapRef = mkOption {
          description = ''
            The ConfigMap to select from
            '';
          type = ConfigMapEnvSource;
        };
        secretRef = mkOption {
          description = ''
            The Secret to select from
            '';
          type = SecretEnvSource;
        };
      };
    };
  };
  EnvVar = lib.mkOption {
    description = ''
      EnvVar represents an environment variable present in a Container.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name of the environment variable. Must be a C_IDENTIFIER.
            '';
          type = str;
        };
        value = mkOption {
          description = ''
            Variable references $(VAR_NAME) are expanded
            using the previously defined environment variables in the container and
            any service environment variables. If a variable cannot be resolved,
            the reference in the input string will be unchanged. Double $$ are reduced
            to a single $, which allows for escaping the $(VAR_NAME) syntax: i.e.
            "$$(VAR_NAME)" will produce the string literal "$(VAR_NAME)".
            Escaped references will never be expanded, regardless of whether the variable
            exists or not.
            Defaults to "".
            '';
          type = str;
        };
        valueFrom = mkOption {
          description = ''
            Source for the environment variable's value. Cannot be used if value is not empty.
            '';
          type = EnvVarSource;
        };
      };
    };
  };
  EnvVarSource = lib.mkOption {
    description = ''
      EnvVarSource represents a source for the value of an EnvVar.
      '';
    type = submodule {
      options = {
        fieldRef = mkOption {
          description = ''
            Selects a field of the pod: supports metadata.name, metadata.namespace, `metadata.labels['<KEY>']`, `metadata.annotations['<KEY>']`,
            spec.nodeName, spec.serviceAccountName, status.hostIP, status.podIP, status.podIPs.
            '';
          type = ObjectFieldSelector;
        };
        resourceFieldRef = mkOption {
          description = ''
            Selects a resource of the container: only resources limits and requests
            (limits.cpu, limits.memory, limits.ephemeral-storage, requests.cpu, requests.memory and requests.ephemeral-storage) are currently supported.
            '';
          type = ResourceFieldSelector;
        };
        configMapKeyRef = mkOption {
          description = ''
            Selects a key of a ConfigMap.
            '';
          type = ConfigMapKeySelector;
        };
        secretKeyRef = mkOption {
          description = ''
            Selects a key of a secret in the pod's namespace
            '';
          type = SecretKeySelector;
        };
      };
    };
  };
  EphemeralContainer = lib.mkOption {
    description = ''
      An EphemeralContainer is a temporary container that you may add to an existing Pod for
      user-initiated activities such as debugging. Ephemeral containers have no resource or
      scheduling guarantees, and they will not be restarted when they exit or when a Pod is
      removed or restarted. The kubelet may evict a Pod if an ephemeral container causes the
      Pod to exceed its resource allocation.
      
      To add an ephemeral container, use the ephemeralcontainers subresource of an existing
      Pod. Ephemeral containers may not be removed or restarted.
      '';
    type = submodule {
      options = {
        EphemeralContainerCommon = mkOption {
          description = ''
            Ephemeral containers have all of the fields of Container, plus additional fields
            specific to ephemeral containers. Fields in common with Container are in the
            following inlined struct so than an EphemeralContainer may easily be converted
            to a Container.
            '';
          type = EphemeralContainerCommon;
        };
        targetContainerName = mkOption {
          description = ''
            If set, the name of the container from PodSpec that this ephemeral container targets.
            The ephemeral container will be run in the namespaces (IPC, PID, etc) of this container.
            If not set then the ephemeral container uses the namespaces configured in the Pod spec.
            
            The container runtime must implement support for this feature. If the runtime does not
            support namespace targeting then the result of setting this field is undefined.
            '';
          type = str;
        };
      };
    };
  };
  EphemeralContainerCommon = lib.mkOption {
    description = ''
      EphemeralContainerCommon is a copy of all fields in Container to be inlined in
      EphemeralContainer. This separate type allows easy conversion from EphemeralContainer
      to Container and allows separate documentation for the fields of EphemeralContainer.
      When a new field is added to Container it must be added here as well.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name of the ephemeral container specified as a DNS_LABEL.
            This name must be unique among all containers, init containers and ephemeral containers.
            '';
          type = str;
        };
        image = mkOption {
          description = ''
            Container image name.
            More info: https://kubernetes.io/docs/concepts/containers/images
            '';
          type = str;
        };
        command = mkOption {
          description = ''
            Entrypoint array. Not executed within a shell.
            The image's ENTRYPOINT is used if this is not provided.
            Variable references $(VAR_NAME) are expanded using the container's environment. If a variable
            cannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced
            to a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. "$$(VAR_NAME)" will
            produce the string literal "$(VAR_NAME)". Escaped references will never be expanded, regardless
            of whether the variable exists or not. Cannot be updated.
            More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
            '';
          type = (listOf str);
        };
        args = mkOption {
          description = ''
            Arguments to the entrypoint.
            The image's CMD is used if this is not provided.
            Variable references $(VAR_NAME) are expanded using the container's environment. If a variable
            cannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced
            to a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. "$$(VAR_NAME)" will
            produce the string literal "$(VAR_NAME)". Escaped references will never be expanded, regardless
            of whether the variable exists or not. Cannot be updated.
            More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
            '';
          type = (listOf str);
        };
        workingDir = mkOption {
          description = ''
            Container's working directory.
            If not specified, the container runtime's default will be used, which
            might be configured in the container image.
            Cannot be updated.
            '';
          type = str;
        };
        ports = mkOption {
          description = ''
            Ports are not allowed for ephemeral containers.
            '';
          type = (listOf ContainerPort);
        };
        envFrom = mkOption {
          description = ''
            List of sources to populate environment variables in the container.
            The keys defined within a source must be a C_IDENTIFIER. All invalid keys
            will be reported as an event when the container is starting. When a key exists in multiple
            sources, the value associated with the last source will take precedence.
            Values defined by an Env with a duplicate key will take precedence.
            Cannot be updated.
            '';
          type = (listOf EnvFromSource);
        };
        env = mkOption {
          description = ''
            List of environment variables to set in the container.
            Cannot be updated.
            '';
          type = (listOf EnvVar);
        };
        resources = mkOption {
          description = ''
            Resources are not allowed for ephemeral containers. Ephemeral containers use spare resources
            already allocated to the pod.
            '';
          type = ResourceRequirements;
        };
        volumeMounts = mkOption {
          description = ''
            Pod volumes to mount into the container's filesystem. Subpath mounts are not allowed for ephemeral containers.
            Cannot be updated.
            '';
          type = (listOf VolumeMount);
        };
        volumeDevices = mkOption {
          description = ''
            volumeDevices is the list of block devices to be used by the container.
            '';
          type = (listOf VolumeDevice);
        };
        livenessProbe = mkOption {
          description = ''
            Probes are not allowed for ephemeral containers.
            '';
          type = Probe;
        };
        readinessProbe = mkOption {
          description = ''
            Probes are not allowed for ephemeral containers.
            '';
          type = Probe;
        };
        startupProbe = mkOption {
          description = ''
            Probes are not allowed for ephemeral containers.
            '';
          type = Probe;
        };
        lifecycle = mkOption {
          description = ''
            Lifecycle is not allowed for ephemeral containers.
            '';
          type = Lifecycle;
        };
        terminationMessagePath = mkOption {
          description = ''
            Optional: Path at which the file to which the container's termination message
            will be written is mounted into the container's filesystem.
            Message written is intended to be brief final status, such as an assertion failure message.
            Will be truncated by the node if greater than 4096 bytes. The total message length across
            all containers will be limited to 12kb.
            Defaults to /dev/termination-log.
            Cannot be updated.
            '';
          type = str;
        };
        terminationMessagePolicy = mkOption {
          description = ''
            Indicate how the termination message should be populated. File will use the contents of
            terminationMessagePath to populate the container status message on both success and failure.
            FallbackToLogsOnError will use the last chunk of container log output if the termination
            message file is empty and the container exited with an error.
            The log output is limited to 2048 bytes or 80 lines, whichever is smaller.
            Defaults to File.
            Cannot be updated.
            '';
          type = TerminationMessagePolicy;
        };
        imagePullPolicy = mkOption {
          description = ''
            Image pull policy.
            One of Always, Never, IfNotPresent.
            Defaults to Always if :latest tag is specified, or IfNotPresent otherwise.
            Cannot be updated.
            More info: https://kubernetes.io/docs/concepts/containers/images#updating-images
            '';
          type = PullPolicy;
        };
        securityContext = mkOption {
          description = ''
            Optional: SecurityContext defines the security options the ephemeral container should be run with.
            If set, the fields of SecurityContext override the equivalent fields of PodSecurityContext.
            '';
          type = SecurityContext;
        };
        stdin = mkOption {
          description = ''
            Whether this container should allocate a buffer for stdin in the container runtime. If this
            is not set, reads from stdin in the container will always result in EOF.
            Default is false.
            '';
          type = bool;
        };
        stdinOnce = mkOption {
          description = ''
            Whether the container runtime should close the stdin channel after it has been opened by
            a single attach. When stdin is true the stdin stream will remain open across multiple attach
            sessions. If stdinOnce is set to true, stdin is opened on container start, is empty until the
            first client attaches to stdin, and then remains open and accepts data until the client disconnects,
            at which time stdin is closed and remains closed until the container is restarted. If this
            flag is false, a container processes that reads from stdin will never receive an EOF.
            Default is false
            '';
          type = bool;
        };
        tty = mkOption {
          description = ''
            Whether this container should allocate a TTY for itself, also requires 'stdin' to be true.
            Default is false.
            '';
          type = bool;
        };
      };
    };
  };
  EphemeralVolumeSource = lib.mkOption {
    description = ''
      Represents an ephemeral volume that is handled by a normal storage driver.
      '';
    type = submodule {
      options = {
        volumeClaimTemplate = mkOption {
          description = ''
            Will be used to create a stand-alone PVC to provision the volume.
            The pod in which this EphemeralVolumeSource is embedded will be the
            owner of the PVC, i.e. the PVC will be deleted together with the
            pod.  The name of the PVC will be `<pod name>-<volume name>` where
            `<volume name>` is the name from the `PodSpec.Volumes` array
            entry. Pod validation will reject the pod if the concatenated name
            is not valid for a PVC (for example, too long).
            
            An existing PVC with that name that is not owned by the pod
            will *not* be used for the pod to avoid using an unrelated
            volume by mistake. Starting the pod is then blocked until
            the unrelated PVC is removed. If such a pre-created PVC is
            meant to be used by the pod, the PVC has to updated with an
            owner reference to the pod once the pod exists. Normally
            this should not be necessary, but it may be useful when
            manually reconstructing a broken cluster.
            
            This field is read-only and no changes will be made by Kubernetes
            to the PVC after it has been created.
            
            Required, must not be nil.
            '';
          type = PersistentVolumeClaimTemplate;
        };
      };
    };
  };
  EventSeries = lib.mkOption {
    description = ''
      EventSeries contain information on series of events, i.e. thing that was/is happening
      continuously for some time.
      '';
    type = submodule {
      options = {
        count = mkOption {
          description = ''
            Number of occurrences in this series up to the last heartbeat time
            '';
          type = int;
        };
        lastObservedTime = mkOption {
          description = ''
            Time of the last occurrence observed
            '';
          type = meta/v1.MicroTime;
        };
      };
    };
  };
  EventSource = lib.mkOption {
    description = ''
      EventSource contains information for an event.
      '';
    type = submodule {
      options = {
        component = mkOption {
          description = ''
            Component from which the event is generated.
            '';
          type = str;
        };
        host = mkOption {
          description = ''
            Node name on which the event is generated.
            '';
          type = str;
        };
      };
    };
  };
  ExecAction = lib.mkOption {
    description = ''
      ExecAction describes a "run in container" action.
      '';
    type = submodule {
      options = {
        command = mkOption {
          description = ''
            Command is the command line to execute inside the container, the working directory for the
            command  is root ('/') in the container's filesystem. The command is simply exec'd, it is
            not run inside a shell, so traditional shell instructions ('|', etc) won't work. To use
            a shell, you need to explicitly call out to that shell.
            Exit status of 0 is treated as live/healthy and non-zero is unhealthy.
            '';
          type = (listOf str);
        };
      };
    };
  };
  FCVolumeSource = lib.mkOption {
    description = ''
      Represents a Fibre Channel volume.
      Fibre Channel volumes can only be mounted as read/write once.
      Fibre Channel volumes support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        targetWWNs = mkOption {
          description = ''
            targetWWNs is Optional: FC target worldwide names (WWNs)
            '';
          type = (listOf str);
        };
        lun = mkOption {
          description = ''
            lun is Optional: FC target lun number
            '';
          type = int;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            TODO: how do we prevent errors in the filesystem from compromising the machine
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly is Optional: Defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            '';
          type = bool;
        };
        wwids = mkOption {
          description = ''
            wwids Optional: FC volume world wide identifiers (wwids)
            Either wwids or combination of targetWWNs and lun must be set, but not both simultaneously.
            '';
          type = (listOf str);
        };
      };
    };
  };
  FinalizerName = lib.mkOption {
    description = ''
      FinalizerName is the name identifying a finalizer during namespace lifecycle.
      '';
  };
  FlexPersistentVolumeSource = lib.mkOption {
    description = ''
      FlexPersistentVolumeSource represents a generic persistent volume resource that is
      provisioned/attached using an exec based plugin.
      '';
    type = submodule {
      options = {
        driver = mkOption {
          description = ''
            driver is the name of the driver to use for this volume.
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the Filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs". The default filesystem depends on FlexVolume script.
            '';
          type = str;
        };
        secretRef = mkOption {
          description = ''
            secretRef is Optional: SecretRef is reference to the secret object containing
            sensitive information to pass to the plugin scripts. This may be
            empty if no secret object is specified. If the secret object
            contains more than one secret, all secrets are passed to the plugin
            scripts.
            '';
          type = SecretReference;
        };
        readOnly = mkOption {
          description = ''
            readOnly is Optional: defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            '';
          type = bool;
        };
        options = mkOption {
          description = ''
            options is Optional: this field holds extra command options if any.
            '';
          type = (attrsOf str);
        };
      };
    };
  };
  FlexVolumeSource = lib.mkOption {
    description = ''
      FlexVolume represents a generic volume resource that is
      provisioned/attached using an exec based plugin.
      '';
    type = submodule {
      options = {
        driver = mkOption {
          description = ''
            driver is the name of the driver to use for this volume.
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs". The default filesystem depends on FlexVolume script.
            '';
          type = str;
        };
        secretRef = mkOption {
          description = ''
            secretRef is Optional: secretRef is reference to the secret object containing
            sensitive information to pass to the plugin scripts. This may be
            empty if no secret object is specified. If the secret object
            contains more than one secret, all secrets are passed to the plugin
            scripts.
            '';
          type = LocalObjectReference;
        };
        readOnly = mkOption {
          description = ''
            readOnly is Optional: defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            '';
          type = bool;
        };
        options = mkOption {
          description = ''
            options is Optional: this field holds extra command options if any.
            '';
          type = (attrsOf str);
        };
      };
    };
  };
  FlockerVolumeSource = lib.mkOption {
    description = ''
      Represents a Flocker volume mounted by the Flocker agent.
      One and only one of datasetName and datasetUUID should be set.
      Flocker volumes do not support ownership management or SELinux relabeling.
      '';
    type = submodule {
      options = {
        datasetName = mkOption {
          description = ''
            datasetName is Name of the dataset stored as metadata -> name on the dataset for Flocker
            should be considered as deprecated
            '';
          type = str;
        };
        datasetUUID = mkOption {
          description = ''
            datasetUUID is the UUID of the dataset. This is unique identifier of a Flocker dataset
            '';
          type = str;
        };
      };
    };
  };
  GCEPersistentDiskVolumeSource = lib.mkOption {
    description = ''
      Represents a Persistent Disk resource in Google Compute Engine.
      
      A GCE PD must exist before mounting to a container. The disk must
      also be in the same GCE project and zone as the kubelet. A GCE PD
      can only be mounted as read/write once or read-only many times. GCE
      PDs support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        pdName = mkOption {
          description = ''
            pdName is unique name of the PD resource in GCE. Used to identify the disk in GCE.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is filesystem type of the volume that you want to mount.
            Tip: Ensure that the filesystem type is supported by the host operating system.
            Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
            TODO: how do we prevent errors in the filesystem from compromising the machine
            '';
          type = str;
        };
        partition = mkOption {
          description = ''
            partition is the partition in the volume that you want to mount.
            If omitted, the default is to mount by volume name.
            Examples: For volume /dev/sda1, you specify the partition as "1".
            Similarly, the volume partition for /dev/sda is "0" (or you can leave the property empty).
            More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
            '';
          type = int;
        };
        readOnly = mkOption {
          description = ''
            readOnly here will force the ReadOnly setting in VolumeMounts.
            Defaults to false.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
            '';
          type = bool;
        };
      };
    };
  };
  GRPCAction = lib.mkOption {
    description = ''
      
      '';
    type = submodule {
      options = {
        port = mkOption {
          description = ''
            Port number of the gRPC service. Number must be in the range 1 to 65535.
            '';
          type = int;
        };
        service = mkOption {
          description = ''
            Service is the name of the service to place in the gRPC HealthCheckRequest
            (see https://github.com/grpc/grpc/blob/master/doc/health-checking.md).
            
            If this is not specified, the default behavior is defined by gRPC.
            '';
          type = str;
        };
      };
    };
  };
  GitRepoVolumeSource = lib.mkOption {
    description = ''
      Represents a volume that is populated with the contents of a git repository.
      Git repo volumes do not support ownership management.
      Git repo volumes support SELinux relabeling.
      
      DEPRECATED: GitRepo is deprecated. To provision a container with a git repo, mount an
      EmptyDir into an InitContainer that clones the repo using git, then mount the EmptyDir
      into the Pod's container.
      '';
    type = submodule {
      options = {
        repository = mkOption {
          description = ''
            repository is the URL
            '';
          type = str;
        };
        revision = mkOption {
          description = ''
            revision is the commit hash for the specified revision.
            '';
          type = str;
        };
        directory = mkOption {
          description = ''
            directory is the target directory name.
            Must not contain or start with '..'.  If '.' is supplied, the volume directory will be the
            git repository.  Otherwise, if specified, the volume will contain the git repository in
            the subdirectory with the given name.
            '';
          type = str;
        };
      };
    };
  };
  GlusterfsPersistentVolumeSource = lib.mkOption {
    description = ''
      Represents a Glusterfs mount that lasts the lifetime of a pod.
      Glusterfs volumes do not support ownership management or SELinux relabeling.
      '';
    type = submodule {
      options = {
        endpoints = mkOption {
          description = ''
            endpoints is the endpoint name that details Glusterfs topology.
            More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod
            '';
          type = str;
        };
        path = mkOption {
          description = ''
            path is the Glusterfs volume path.
            More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly here will force the Glusterfs volume to be mounted with read-only permissions.
            Defaults to false.
            More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod
            '';
          type = bool;
        };
        endpointsNamespace = mkOption {
          description = ''
            endpointsNamespace is the namespace that contains Glusterfs endpoint.
            If this field is empty, the EndpointNamespace defaults to the same namespace as the bound PVC.
            More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod
            '';
          type = str;
        };
      };
    };
  };
  GlusterfsVolumeSource = lib.mkOption {
    description = ''
      Represents a Glusterfs mount that lasts the lifetime of a pod.
      Glusterfs volumes do not support ownership management or SELinux relabeling.
      '';
    type = submodule {
      options = {
        endpoints = mkOption {
          description = ''
            endpoints is the endpoint name that details Glusterfs topology.
            More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod
            '';
          type = str;
        };
        path = mkOption {
          description = ''
            path is the Glusterfs volume path.
            More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly here will force the Glusterfs volume to be mounted with read-only permissions.
            Defaults to false.
            More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod
            '';
          type = bool;
        };
      };
    };
  };
  HTTPGetAction = lib.mkOption {
    description = ''
      HTTPGetAction describes an action based on HTTP Get requests.
      '';
    type = submodule {
      options = {
        path = mkOption {
          description = ''
            Path to access on the HTTP server.
            '';
          type = str;
        };
        port = mkOption {
          description = ''
            Name or number of the port to access on the container.
            Number must be in the range 1 to 65535.
            Name must be an IANA_SVC_NAME.
            '';
          type = k8s.io/apimachinery/pkg/util/intstr.IntOrString;
        };
        host = mkOption {
          description = ''
            Host name to connect to, defaults to the pod IP. You probably want to set
            "Host" in httpHeaders instead.
            '';
          type = str;
        };
        scheme = mkOption {
          description = ''
            Scheme to use for connecting to the host.
            Defaults to HTTP.
            '';
          type = URIScheme;
        };
        httpHeaders = mkOption {
          description = ''
            Custom headers to set in the request. HTTP allows repeated headers.
            '';
          type = (listOf HTTPHeader);
        };
      };
    };
  };
  HTTPHeader = lib.mkOption {
    description = ''
      HTTPHeader describes a custom header to be used in HTTP probes
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            The header field name
            '';
          type = str;
        };
        value = mkOption {
          description = ''
            The header field value
            '';
          type = str;
        };
      };
    };
  };
  HostAlias = lib.mkOption {
    description = ''
      HostAlias holds the mapping between IP and hostnames that will be injected as an entry in the
      pod's hosts file.
      '';
    type = submodule {
      options = {
        ip = mkOption {
          description = ''
            IP address of the host file entry.
            '';
          type = str;
        };
        hostnames = mkOption {
          description = ''
            Hostnames for the above IP address.
            '';
          type = (listOf str);
        };
      };
    };
  };
  HostPathType = lib.mkOption {
    description = ''

      '';
  };
  HostPathVolumeSource = lib.mkOption {
    description = ''
      Represents a host path mapped into a pod.
      Host path volumes do not support ownership management or SELinux relabeling.
      '';
    type = submodule {
      options = {
        path = mkOption {
          description = ''
            path of the directory on the host.
            If the path is a symlink, it will follow the link to the real path.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath
            '';
          type = str;
        };
        type = mkOption {
          description = ''
            type for HostPath Volume
            Defaults to ""
            More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath
            '';
          type = HostPathType;
        };
      };
    };
  };
  IPFamily = lib.mkOption {
    description = ''
      IPFamily represents the IP Family (IPv4 or IPv6). This type is used
      to express the family of an IP expressed by a type (e.g. service.spec.ipFamilies).
      '';
  };
  IPFamilyPolicy = lib.mkOption {
    description = ''
      for backwards compat
      '';
  };
  ISCSIPersistentVolumeSource = lib.mkOption {
    description = ''
      ISCSIPersistentVolumeSource represents an ISCSI disk.
      ISCSI volumes can only be mounted as read/write once.
      ISCSI volumes support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        targetPortal = mkOption {
          description = ''
            targetPortal is iSCSI Target Portal. The Portal is either an IP or ip_addr:port if the port
            is other than default (typically TCP ports 860 and 3260).
            '';
          type = str;
        };
        iqn = mkOption {
          description = ''
            iqn is Target iSCSI Qualified Name.
            '';
          type = str;
        };
        lun = mkOption {
          description = ''
            lun is iSCSI Target Lun number.
            '';
          type = int;
        };
        iscsiInterface = mkOption {
          description = ''
            iscsiInterface is the interface Name that uses an iSCSI transport.
            Defaults to 'default' (tcp).
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type of the volume that you want to mount.
            Tip: Ensure that the filesystem type is supported by the host operating system.
            Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#iscsi
            TODO: how do we prevent errors in the filesystem from compromising the machine
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly here will force the ReadOnly setting in VolumeMounts.
            Defaults to false.
            '';
          type = bool;
        };
        portals = mkOption {
          description = ''
            portals is the iSCSI Target Portal List. The Portal is either an IP or ip_addr:port if the port
            is other than default (typically TCP ports 860 and 3260).
            '';
          type = (listOf str);
        };
        chapAuthDiscovery = mkOption {
          description = ''
            chapAuthDiscovery defines whether support iSCSI Discovery CHAP authentication
            '';
          type = bool;
        };
        chapAuthSession = mkOption {
          description = ''
            chapAuthSession defines whether support iSCSI Session CHAP authentication
            '';
          type = bool;
        };
        secretRef = mkOption {
          description = ''
            secretRef is the CHAP Secret for iSCSI target and initiator authentication
            '';
          type = SecretReference;
        };
        initiatorName = mkOption {
          description = ''
            initiatorName is the custom iSCSI Initiator Name.
            If initiatorName is specified with iscsiInterface simultaneously, new iSCSI interface
            <target portal>:<volume name> will be created for the connection.
            '';
          type = str;
        };
      };
    };
  };
  ISCSIVolumeSource = lib.mkOption {
    description = ''
      Represents an ISCSI disk.
      ISCSI volumes can only be mounted as read/write once.
      ISCSI volumes support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        targetPortal = mkOption {
          description = ''
            targetPortal is iSCSI Target Portal. The Portal is either an IP or ip_addr:port if the port
            is other than default (typically TCP ports 860 and 3260).
            '';
          type = str;
        };
        iqn = mkOption {
          description = ''
            iqn is the target iSCSI Qualified Name.
            '';
          type = str;
        };
        lun = mkOption {
          description = ''
            lun represents iSCSI Target Lun number.
            '';
          type = int;
        };
        iscsiInterface = mkOption {
          description = ''
            iscsiInterface is the interface Name that uses an iSCSI transport.
            Defaults to 'default' (tcp).
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type of the volume that you want to mount.
            Tip: Ensure that the filesystem type is supported by the host operating system.
            Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#iscsi
            TODO: how do we prevent errors in the filesystem from compromising the machine
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly here will force the ReadOnly setting in VolumeMounts.
            Defaults to false.
            '';
          type = bool;
        };
        portals = mkOption {
          description = ''
            portals is the iSCSI Target Portal List. The portal is either an IP or ip_addr:port if the port
            is other than default (typically TCP ports 860 and 3260).
            '';
          type = (listOf str);
        };
        chapAuthDiscovery = mkOption {
          description = ''
            chapAuthDiscovery defines whether support iSCSI Discovery CHAP authentication
            '';
          type = bool;
        };
        chapAuthSession = mkOption {
          description = ''
            chapAuthSession defines whether support iSCSI Session CHAP authentication
            '';
          type = bool;
        };
        secretRef = mkOption {
          description = ''
            secretRef is the CHAP Secret for iSCSI target and initiator authentication
            '';
          type = LocalObjectReference;
        };
        initiatorName = mkOption {
          description = ''
            initiatorName is the custom iSCSI Initiator Name.
            If initiatorName is specified with iscsiInterface simultaneously, new iSCSI interface
            <target portal>:<volume name> will be created for the connection.
            '';
          type = str;
        };
      };
    };
  };
  KeyToPath = lib.mkOption {
    description = ''
      Maps a string key to a path within a volume.
      '';
    type = submodule {
      options = {
        key = mkOption {
          description = ''
            key is the key to project.
            '';
          type = str;
        };
        path = mkOption {
          description = ''
            path is the relative path of the file to map the key to.
            May not be an absolute path.
            May not contain the path element '..'.
            May not start with the string '..'.
            '';
          type = str;
        };
        mode = mkOption {
          description = ''
            mode is Optional: mode bits used to set permissions on this file.
            Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
            YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
            If not specified, the volume defaultMode will be used.
            This might be in conflict with other options that affect the file
            mode, like fsGroup, and the result can be other mode bits set.
            '';
          type = int;
        };
      };
    };
  };
  Lifecycle = lib.mkOption {
    description = ''
      Lifecycle describes actions that the management system should take in response to container lifecycle
      events. For the PostStart and PreStop lifecycle handlers, management of the container blocks
      until the action is complete, unless the container process fails, in which case the handler is aborted.
      '';
    type = submodule {
      options = {
        postStart = mkOption {
          description = ''
            PostStart is called immediately after a container is created. If the handler fails,
            the container is terminated and restarted according to its restart policy.
            Other management of the container blocks until the hook completes.
            More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks
            '';
          type = LifecycleHandler;
        };
        preStop = mkOption {
          description = ''
            PreStop is called immediately before a container is terminated due to an
            API request or management event such as liveness/startup probe failure,
            preemption, resource contention, etc. The handler is not called if the
            container crashes or exits. The Pod's termination grace period countdown begins before the
            PreStop hook is executed. Regardless of the outcome of the handler, the
            container will eventually terminate within the Pod's termination grace
            period (unless delayed by finalizers). Other management of the container blocks until the hook completes
            or until the termination grace period is reached.
            More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks
            '';
          type = LifecycleHandler;
        };
      };
    };
  };
  LifecycleHandler = lib.mkOption {
    description = ''
      LifecycleHandler defines a specific action that should be taken in a lifecycle
      hook. One and only one of the fields, except TCPSocket must be specified.
      '';
    type = submodule {
      options = {
        exec = mkOption {
          description = ''
            Exec specifies the action to take.
            '';
          type = ExecAction;
        };
        httpGet = mkOption {
          description = ''
            HTTPGet specifies the http request to perform.
            '';
          type = HTTPGetAction;
        };
        tcpSocket = mkOption {
          description = ''
            Deprecated. TCPSocket is NOT supported as a LifecycleHandler and kept
            for the backward compatibility. There are no validation of this field and
            lifecycle hooks will fail in runtime when tcp handler is specified.
            '';
          type = TCPSocketAction;
        };
      };
    };
  };
  LimitRangeItem = lib.mkOption {
    description = ''
      LimitRangeItem defines a min/max usage limit for any resource that matches on kind.
      '';
    type = submodule {
      options = {
        type = mkOption {
          description = ''
            Type of resource that this limit applies to.
            '';
          type = LimitType;
        };
        max = mkOption {
          description = ''
            Max usage constraints on this kind by resource name.
            '';
          type = ResourceList;
        };
        min = mkOption {
          description = ''
            Min usage constraints on this kind by resource name.
            '';
          type = ResourceList;
        };
        default = mkOption {
          description = ''
            Default resource requirement limit value by resource name if resource limit is omitted.
            '';
          type = ResourceList;
        };
        defaultRequest = mkOption {
          description = ''
            DefaultRequest is the default resource requirement request value by resource name if resource request is omitted.
            '';
          type = ResourceList;
        };
        maxLimitRequestRatio = mkOption {
          description = ''
            MaxLimitRequestRatio if specified, the named resource must have a request and limit that are both non-zero where limit divided by request is less than or equal to the enumerated value; this represents the max burst for the named resource.
            '';
          type = ResourceList;
        };
      };
    };
  };
  LimitRangeSpec = lib.mkOption {
    description = ''
      LimitRangeSpec defines a min/max usage limit for resources that match on kind.
      '';
    type = submodule {
      options = {
        limits = mkOption {
          description = ''
            Limits is the list of LimitRangeItem objects that are enforced.
            '';
          type = (listOf LimitRangeItem);
        };
      };
    };
  };
  LimitType = lib.mkOption {
    description = ''
      LimitType is a type of object that is limited. It can be Pod, Container, PersistentVolumeClaim or
      a fully qualified resource name.
      '';
  };
  LoadBalancerIngress = lib.mkOption {
    description = ''
      LoadBalancerIngress represents the status of a load-balancer ingress point:
      traffic intended for the service should be sent to an ingress point.
      '';
    type = submodule {
      options = {
        ip = mkOption {
          description = ''
            IP is set for load-balancer ingress points that are IP based
            (typically GCE or OpenStack load-balancers)
            '';
          type = str;
        };
        hostname = mkOption {
          description = ''
            Hostname is set for load-balancer ingress points that are DNS based
            (typically AWS load-balancers)
            '';
          type = str;
        };
        ports = mkOption {
          description = ''
            Ports is a list of records of service ports
            If used, every port defined in the service should have an entry in it
            '';
          type = (listOf PortStatus);
        };
      };
    };
  };
  LoadBalancerStatus = lib.mkOption {
    description = ''
      LoadBalancerStatus represents the status of a load-balancer.
      '';
    type = submodule {
      options = {
        ingress = mkOption {
          description = ''
            Ingress is a list containing ingress points for the load-balancer.
            Traffic intended for the service should be sent to these ingress points.
            '';
          type = (listOf LoadBalancerIngress);
        };
      };
    };
  };
  LocalObjectReference = lib.mkOption {
    description = ''
      LocalObjectReference contains enough information to let you locate the
      referenced object inside the same namespace.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name of the referent.
            More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
            TODO: Add other useful fields. apiVersion, kind, uid?
            '';
          type = str;
        };
      };
    };
  };
  LocalVolumeSource = lib.mkOption {
    description = ''
      Local represents directly-attached storage with node affinity (Beta feature)
      '';
    type = submodule {
      options = {
        path = mkOption {
          description = ''
            path of the full path to the volume on the node.
            It can be either a directory or block device (disk, partition, ...).
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type to mount.
            It applies only when the Path is a block device.
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs". The default value is to auto-select a filesystem if unspecified.
            '';
          type = str;
        };
      };
    };
  };
  MountPropagationMode = lib.mkOption {
    description = ''
      MountPropagationMode describes mount propagation.
      '';
  };
  NFSVolumeSource = lib.mkOption {
    description = ''
      Represents an NFS mount that lasts the lifetime of a pod.
      NFS volumes do not support ownership management or SELinux relabeling.
      '';
    type = submodule {
      options = {
        server = mkOption {
          description = ''
            server is the hostname or IP address of the NFS server.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
            '';
          type = str;
        };
        path = mkOption {
          description = ''
            path that is exported by the NFS server.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly here will force the NFS export to be mounted with read-only permissions.
            Defaults to false.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
            '';
          type = bool;
        };
      };
    };
  };
  NamespaceCondition = lib.mkOption {
    description = ''
      NamespaceCondition contains details about state of namespace.
      '';
    type = submodule {
      options = {
        type = mkOption {
          description = ''
            Type of namespace controller condition.
            '';
          type = NamespaceConditionType;
        };
        status = mkOption {
          description = ''
            Status of the condition, one of True, False, Unknown.
            '';
          type = ConditionStatus;
        };
        lastTransitionTime = mkOption {
          description = ''

            '';
          type = meta/v1.Time;
        };
        reason = mkOption {
          description = ''

            '';
          type = str;
        };
        message = mkOption {
          description = ''

            '';
          type = str;
        };
      };
    };
  };
  NamespaceConditionType = lib.mkOption {
    description = ''
      
      '';
  };
  NamespacePhase = lib.mkOption {
    description = ''

      '';
  };
  NamespaceSpec = lib.mkOption {
    description = ''
      NamespaceSpec describes the attributes on a Namespace.
      '';
    type = submodule {
      options = {
        finalizers = mkOption {
          description = ''
            Finalizers is an opaque list of values that must be empty to permanently remove object from storage.
            More info: https://kubernetes.io/docs/tasks/administer-cluster/namespaces/
            '';
          type = (listOf FinalizerName);
        };
      };
    };
  };
  NamespaceStatus = lib.mkOption {
    description = ''
      NamespaceStatus is information about the current status of a Namespace.
      '';
    type = submodule {
      options = {
        phase = mkOption {
          description = ''
            Phase is the current lifecycle phase of the namespace.
            More info: https://kubernetes.io/docs/tasks/administer-cluster/namespaces/
            '';
          type = NamespacePhase;
        };
        conditions = mkOption {
          description = ''
            Represents the latest available observations of a namespace's current state.
            '';
          type = (listOf NamespaceCondition);
        };
      };
    };
  };
  NodeAddress = lib.mkOption {
    description = ''
      NodeAddress contains information for the node's address.
      '';
    type = submodule {
      options = {
        type = mkOption {
          description = ''
            Node address type, one of Hostname, ExternalIP or InternalIP.
            '';
          type = NodeAddressType;
        };
        address = mkOption {
          description = ''
            The node address.
            '';
          type = str;
        };
      };
    };
  };
  NodeAddressType = lib.mkOption {
    description = ''
      
      '';
  };
  NodeAffinity = lib.mkOption {
    description = ''
      Node affinity is a group of node affinity scheduling rules.
      '';
    type = submodule {
      options = {
        requiredDuringSchedulingIgnoredDuringExecution = mkOption {
          description = ''
            If the affinity requirements specified by this field are not met at
            scheduling time, the pod will not be scheduled onto the node.
            If the affinity requirements specified by this field cease to be met
            at some point during pod execution (e.g. due to an update), the system
            may or may not try to eventually evict the pod from its node.
            '';
          type = NodeSelector;
        };
        preferredDuringSchedulingIgnoredDuringExecution = mkOption {
          description = ''
            The scheduler will prefer to schedule pods to nodes that satisfy
            the affinity expressions specified by this field, but it may choose
            a node that violates one or more of the expressions. The node that is
            most preferred is the one with the greatest sum of weights, i.e.
            for each node that meets all of the scheduling requirements (resource
            request, requiredDuringScheduling affinity expressions, etc.),
            compute a sum by iterating through the elements of this field and adding
            "weight" to the sum if the node matches the corresponding matchExpressions; the
            node(s) with the highest sum are the most preferred.
            '';
          type = (listOf PreferredSchedulingTerm);
        };
      };
    };
  };
  NodeCondition = lib.mkOption {
    description = ''
      NodeCondition contains condition information for a node.
      '';
    type = submodule {
      options = {
        type = mkOption {
          description = ''
            Type of node condition.
            '';
          type = NodeConditionType;
        };
        status = mkOption {
          description = ''
            Status of the condition, one of True, False, Unknown.
            '';
          type = ConditionStatus;
        };
        lastHeartbeatTime = mkOption {
          description = ''
            Last time we got an update on a given condition.
            '';
          type = meta/v1.Time;
        };
        lastTransitionTime = mkOption {
          description = ''
            Last time the condition transit from one status to another.
            '';
          type = meta/v1.Time;
        };
        reason = mkOption {
          description = ''
            (brief) reason for the condition's last transition.
            '';
          type = str;
        };
        message = mkOption {
          description = ''
            Human readable message indicating details about last transition.
            '';
          type = str;
        };
      };
    };
  };
  NodeConditionType = lib.mkOption {
    description = ''
      
      '';
  };
  NodeConfigSource = lib.mkOption {
    description = ''
      NodeConfigSource specifies a source of node configuration. Exactly one subfield (excluding metadata) must be non-nil.
      This API is deprecated since 1.22
      '';
    type = submodule {
      options = {
        configMap = mkOption {
          description = ''
            ConfigMap is a reference to a Node's ConfigMap
            '';
          type = ConfigMapNodeConfigSource;
        };
      };
    };
  };
  NodeConfigStatus = lib.mkOption {
    description = ''
      NodeConfigStatus describes the status of the config assigned by Node.Spec.ConfigSource.
      '';
    type = submodule {
      options = {
        assigned = mkOption {
          description = ''
            Assigned reports the checkpointed config the node will try to use.
            When Node.Spec.ConfigSource is updated, the node checkpoints the associated
            config payload to local disk, along with a record indicating intended
            config. The node refers to this record to choose its config checkpoint, and
            reports this record in Assigned. Assigned only updates in the status after
            the record has been checkpointed to disk. When the Kubelet is restarted,
            it tries to make the Assigned config the Active config by loading and
            validating the checkpointed payload identified by Assigned.
            '';
          type = NodeConfigSource;
        };
        active = mkOption {
          description = ''
            Active reports the checkpointed config the node is actively using.
            Active will represent either the current version of the Assigned config,
            or the current LastKnownGood config, depending on whether attempting to use the
            Assigned config results in an error.
            '';
          type = NodeConfigSource;
        };
        lastKnownGood = mkOption {
          description = ''
            LastKnownGood reports the checkpointed config the node will fall back to
            when it encounters an error attempting to use the Assigned config.
            The Assigned config becomes the LastKnownGood config when the node determines
            that the Assigned config is stable and correct.
            This is currently implemented as a 10-minute soak period starting when the local
            record of Assigned config is updated. If the Assigned config is Active at the end
            of this period, it becomes the LastKnownGood. Note that if Spec.ConfigSource is
            reset to nil (use local defaults), the LastKnownGood is also immediately reset to nil,
            because the local default config is always assumed good.
            You should not make assumptions about the node's method of determining config stability
            and correctness, as this may change or become configurable in the future.
            '';
          type = NodeConfigSource;
        };
        error = mkOption {
          description = ''
            Error describes any problems reconciling the Spec.ConfigSource to the Active config.
            Errors may occur, for example, attempting to checkpoint Spec.ConfigSource to the local Assigned
            record, attempting to checkpoint the payload associated with Spec.ConfigSource, attempting
            to load or validate the Assigned config, etc.
            Errors may occur at different points while syncing config. Earlier errors (e.g. download or
            checkpointing errors) will not result in a rollback to LastKnownGood, and may resolve across
            Kubelet retries. Later errors (e.g. loading or validating a checkpointed config) will result in
            a rollback to LastKnownGood. In the latter case, it is usually possible to resolve the error
            by fixing the config assigned in Spec.ConfigSource.
            You can find additional information for debugging by searching the error message in the Kubelet log.
            Error is a human-readable description of the error state; machines can check whether or not Error
            is empty, but should not rely on the stability of the Error text across Kubelet versions.
            '';
          type = str;
        };
      };
    };
  };
  NodeDaemonEndpoints = lib.mkOption {
    description = ''
      NodeDaemonEndpoints lists ports opened by daemons running on the Node.
      '';
    type = submodule {
      options = {
        kubeletEndpoint = mkOption {
          description = ''
            Endpoint on which Kubelet is listening.
            '';
          type = DaemonEndpoint;
        };
      };
    };
  };
  NodeInclusionPolicy = lib.mkOption {
    description = ''
      NodeInclusionPolicy defines the type of node inclusion policy
      '';
  };
  NodePhase = lib.mkOption {
    description = ''

      '';
  };
  NodeSelector = lib.mkOption {
    description = ''
      A node selector represents the union of the results of one or more label queries
      over a set of nodes; that is, it represents the OR of the selectors represented
      by the node selector terms.
      '';
    type = submodule {
      options = {
        nodeSelectorTerms = mkOption {
          description = ''
            Required. A list of node selector terms. The terms are ORed.
            '';
          type = (listOf NodeSelectorTerm);
        };
      };
    };
  };
  NodeSelectorOperator = lib.mkOption {
    description = ''
      A node selector operator is the set of operators that can be used in
      a node selector requirement.
      '';
  };
  NodeSelectorRequirement = lib.mkOption {
    description = ''
      A node selector requirement is a selector that contains values, a key, and an operator
      that relates the key and values.
      '';
    type = submodule {
      options = {
        key = mkOption {
          description = ''
            The label key that the selector applies to.
            '';
          type = str;
        };
        operator = mkOption {
          description = ''
            Represents a key's relationship to a set of values.
            Valid operators are In, NotIn, Exists, DoesNotExist. Gt, and Lt.
            '';
          type = NodeSelectorOperator;
        };
        values = mkOption {
          description = ''
            An array of string values. If the operator is In or NotIn,
            the values array must be non-empty. If the operator is Exists or DoesNotExist,
            the values array must be empty. If the operator is Gt or Lt, the values
            array must have a single element, which will be interpreted as an integer.
            This array is replaced during a strategic merge patch.
            '';
          type = (listOf str);
        };
      };
    };
  };
  NodeSelectorTerm = lib.mkOption {
    description = ''
      A null or empty node selector term matches no objects. The requirements of
      them are ANDed.
      The TopologySelectorTerm type implements a subset of the NodeSelectorTerm.
      '';
    type = submodule {
      options = {
        matchExpressions = mkOption {
          description = ''
            A list of node selector requirements by node's labels.
            '';
          type = (listOf NodeSelectorRequirement);
        };
        matchFields = mkOption {
          description = ''
            A list of node selector requirements by node's fields.
            '';
          type = (listOf NodeSelectorRequirement);
        };
      };
    };
  };
  NodeSpec = lib.mkOption {
    description = ''
      NodeSpec describes the attributes that a node is created with.
      '';
    type = submodule {
      options = {
        podCIDR = mkOption {
          description = ''
            PodCIDR represents the pod IP range assigned to the node.
            '';
          type = str;
        };
        podCIDRs = mkOption {
          description = ''
            podCIDRs represents the IP ranges assigned to the node for usage by Pods on that node. If this
            field is specified, the 0th entry must match the podCIDR field. It may contain at most 1 value for
            each of IPv4 and IPv6.
            '';
          type = (listOf str);
        };
        providerID = mkOption {
          description = ''
            ID of the node assigned by the cloud provider in the format: <ProviderName>://<ProviderSpecificNodeID>
            '';
          type = str;
        };
        unschedulable = mkOption {
          description = ''
            Unschedulable controls node schedulability of new pods. By default, node is schedulable.
            More info: https://kubernetes.io/docs/concepts/nodes/node/#manual-node-administration
            '';
          type = bool;
        };
        taints = mkOption {
          description = ''
            If specified, the node's taints.
            '';
          type = (listOf Taint);
        };
        configSource = mkOption {
          description = ''
            Deprecated: Previously used to specify the source of the node's configuration for the DynamicKubeletConfig feature. This feature is removed.
            '';
          type = NodeConfigSource;
        };
        externalID = mkOption {
          description = ''
            Deprecated. Not all kubelets will set this field. Remove field after 1.13.
            see: https://issues.k8s.io/61966
            '';
          type = str;
        };
      };
    };
  };
  NodeStatus = lib.mkOption {
    description = ''
      NodeStatus is information about the current status of a node.
      '';
    type = submodule {
      options = {
        capacity = mkOption {
          description = ''
            Capacity represents the total resources of a node.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#capacity
            '';
          type = ResourceList;
        };
        allocatable = mkOption {
          description = ''
            Allocatable represents the resources of a node that are available for scheduling.
            Defaults to Capacity.
            '';
          type = ResourceList;
        };
        phase = mkOption {
          description = ''
            NodePhase is the recently observed lifecycle phase of the node.
            More info: https://kubernetes.io/docs/concepts/nodes/node/#phase
            The field is never populated, and now is deprecated.
            '';
          type = NodePhase;
        };
        conditions = mkOption {
          description = ''
            Conditions is an array of current observed node conditions.
            More info: https://kubernetes.io/docs/concepts/nodes/node/#condition
            '';
          type = (listOf NodeCondition);
        };
        addresses = mkOption {
          description = ''
            List of addresses reachable to the node.
            Queried from cloud provider, if available.
            More info: https://kubernetes.io/docs/concepts/nodes/node/#addresses
            Note: This field is declared as mergeable, but the merge key is not sufficiently
            unique, which can cause data corruption when it is merged. Callers should instead
            use a full-replacement patch. See https://pr.k8s.io/79391 for an example.
            '';
          type = (listOf NodeAddress);
        };
        daemonEndpoints = mkOption {
          description = ''
            Endpoints of daemons running on the Node.
            '';
          type = NodeDaemonEndpoints;
        };
        nodeInfo = mkOption {
          description = ''
            Set of ids/uuids to uniquely identify the node.
            More info: https://kubernetes.io/docs/concepts/nodes/node/#info
            '';
          type = NodeSystemInfo;
        };
        images = mkOption {
          description = ''
            List of container images on this node
            '';
          type = (listOf ContainerImage);
        };
        volumesInUse = mkOption {
          description = ''
            List of attachable volumes in use (mounted) by the node.
            '';
          type = (listOf UniqueVolumeName);
        };
        volumesAttached = mkOption {
          description = ''
            List of volumes that are attached to the node.
            '';
          type = (listOf AttachedVolume);
        };
        config = mkOption {
          description = ''
            Status of the config assigned to the node via the dynamic Kubelet config feature.
            '';
          type = NodeConfigStatus;
        };
      };
    };
  };
  NodeSystemInfo = lib.mkOption {
    description = ''
      NodeSystemInfo is a set of ids/uuids to uniquely identify the node.
      '';
    type = submodule {
      options = {
        machineID = mkOption {
          description = ''
            MachineID reported by the node. For unique machine identification
            in the cluster this field is preferred. Learn more from man(5)
            machine-id: http://man7.org/linux/man-pages/man5/machine-id.5.html
            '';
          type = str;
        };
        systemUUID = mkOption {
          description = ''
            SystemUUID reported by the node. For unique machine identification
            MachineID is preferred. This field is specific to Red Hat hosts
            https://access.redhat.com/documentation/en-us/red_hat_subscription_management/1/html/rhsm/uuid
            '';
          type = str;
        };
        bootID = mkOption {
          description = ''
            Boot ID reported by the node.
            '';
          type = str;
        };
        kernelVersion = mkOption {
          description = ''
            Kernel Version reported by the node from 'uname -r' (e.g. 3.16.0-0.bpo.4-amd64).
            '';
          type = str;
        };
        osImage = mkOption {
          description = ''
            OS Image reported by the node from /etc/os-release (e.g. Debian GNU/Linux 7 (wheezy)).
            '';
          type = str;
        };
        containerRuntimeVersion = mkOption {
          description = ''
            ContainerRuntime Version reported by the node through runtime remote API (e.g. containerd://1.4.2).
            '';
          type = str;
        };
        kubeletVersion = mkOption {
          description = ''
            Kubelet Version reported by the node.
            '';
          type = str;
        };
        kubeProxyVersion = mkOption {
          description = ''
            KubeProxy Version reported by the node.
            '';
          type = str;
        };
        operatingSystem = mkOption {
          description = ''
            The Operating System reported by the node
            '';
          type = str;
        };
        architecture = mkOption {
          description = ''
            The Architecture reported by the node
            '';
          type = str;
        };
      };
    };
  };
  OSName = lib.mkOption {
    description = ''
      OSName is the set of OS'es that can be used in OS.
      '';
  };
  ObjectFieldSelector = lib.mkOption {
    description = ''
      ObjectFieldSelector selects an APIVersioned field of an object.
      '';
    type = submodule {
      options = {
        apiVersion = mkOption {
          description = ''
            Version of the schema the FieldPath is written in terms of, defaults to "v1".
            '';
          type = str;
        };
        fieldPath = mkOption {
          description = ''
            Path of the field to select in the specified API version.
            '';
          type = str;
        };
      };
    };
  };
  PersistentVolumeAccessMode = lib.mkOption {
    description = ''

      '';
  };
  PersistentVolumeClaimCondition = lib.mkOption {
    description = ''
      PersistentVolumeClaimCondition contails details about state of pvc
      '';
    type = submodule {
      options = {
        type = mkOption {
          description = ''
            
            '';
          type = PersistentVolumeClaimConditionType;
        };
        status = mkOption {
          description = ''
            
            '';
          type = ConditionStatus;
        };
        lastProbeTime = mkOption {
          description = ''
            lastProbeTime is the time we probed the condition.
            '';
          type = meta/v1.Time;
        };
        lastTransitionTime = mkOption {
          description = ''
            lastTransitionTime is the time the condition transitioned from one status to another.
            '';
          type = meta/v1.Time;
        };
        reason = mkOption {
          description = ''
            reason is a unique, this should be a short, machine understandable string that gives the reason
            for condition's last transition. If it reports "ResizeStarted" that means the underlying
            persistent volume is being resized.
            '';
          type = str;
        };
        message = mkOption {
          description = ''
            message is the human-readable message indicating details about last transition.
            '';
          type = str;
        };
      };
    };
  };
  PersistentVolumeClaimConditionType = lib.mkOption {
    description = ''
      PersistentVolumeClaimConditionType is a valid value of PersistentVolumeClaimCondition.Type
      '';
  };
  PersistentVolumeClaimPhase = lib.mkOption {
    description = ''

      '';
  };
  PersistentVolumeClaimResizeStatus = lib.mkOption {
    description = ''

      '';
  };
  PersistentVolumeClaimSpec = lib.mkOption {
    description = ''
      PersistentVolumeClaimSpec describes the common attributes of storage devices
      and allows a Source for provider-specific attributes
      '';
    type = submodule {
      options = {
        accessModes = mkOption {
          description = ''
            accessModes contains the desired access modes the volume should have.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1
            '';
          type = (listOf PersistentVolumeAccessMode);
        };
        selector = mkOption {
          description = ''
            selector is a label query over volumes to consider for binding.
            '';
          type = meta/v1.LabelSelector;
        };
        resources = mkOption {
          description = ''
            resources represents the minimum resources the volume should have.
            If RecoverVolumeExpansionFailure feature is enabled users are allowed to specify resource requirements
            that are lower than previous value but must still be higher than capacity recorded in the
            status field of the claim.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#resources
            '';
          type = ResourceRequirements;
        };
        volumeName = mkOption {
          description = ''
            volumeName is the binding reference to the PersistentVolume backing this claim.
            '';
          type = str;
        };
        storageClassName = mkOption {
          description = ''
            storageClassName is the name of the StorageClass required by the claim.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#class-1
            '';
          type = str;
        };
        volumeMode = mkOption {
          description = ''
            volumeMode defines what type of volume is required by the claim.
            Value of Filesystem is implied when not included in claim spec.
            '';
          type = PersistentVolumeMode;
        };
        dataSource = mkOption {
          description = ''
            dataSource field can be used to specify either:
            * An existing VolumeSnapshot object (snapshot.storage.k8s.io/VolumeSnapshot)
            * An existing PVC (PersistentVolumeClaim)
            If the provisioner or an external controller can support the specified data source,
            it will create a new volume based on the contents of the specified data source.
            When the AnyVolumeDataSource feature gate is enabled, dataSource contents will be copied to dataSourceRef,
            and dataSourceRef contents will be copied to dataSource when dataSourceRef.namespace is not specified.
            If the namespace is specified, then dataSourceRef will not be copied to dataSource.
            '';
          type = TypedLocalObjectReference;
        };
        dataSourceRef = mkOption {
          description = ''
            dataSourceRef specifies the object from which to populate the volume with data, if a non-empty
            volume is desired. This may be any object from a non-empty API group (non
            core object) or a PersistentVolumeClaim object.
            When this field is specified, volume binding will only succeed if the type of
            the specified object matches some installed volume populator or dynamic
            provisioner.
            This field will replace the functionality of the dataSource field and as such
            if both fields are non-empty, they must have the same value. For backwards
            compatibility, when namespace isn't specified in dataSourceRef,
            both fields (dataSource and dataSourceRef) will be set to the same
            value automatically if one of them is empty and the other is non-empty.
            When namespace is specified in dataSourceRef,
            dataSource isn't set to the same value and must be empty.
            There are three important differences between dataSource and dataSourceRef:
            * While dataSource only allows two specific types of objects, dataSourceRef
              allows any non-core object, as well as PersistentVolumeClaim objects.
            * While dataSource ignores disallowed values (dropping them), dataSourceRef
              preserves all values, and generates an error if a disallowed value is
              specified.
            * While dataSource only allows local objects, dataSourceRef allows objects
              in any namespaces.
            (Beta) Using this field requires the AnyVolumeDataSource feature gate to be enabled.
            (Alpha) Using the namespace field of dataSourceRef requires the CrossNamespaceVolumeDataSource feature gate to be enabled.
            '';
          type = TypedObjectReference;
        };
      };
    };
  };
  PersistentVolumeClaimStatus = lib.mkOption {
    description = ''
      PersistentVolumeClaimStatus is the current status of a persistent volume claim.
      '';
    type = submodule {
      options = {
        phase = mkOption {
          description = ''
            phase represents the current phase of PersistentVolumeClaim.
            '';
          type = PersistentVolumeClaimPhase;
        };
        accessModes = mkOption {
          description = ''
            accessModes contains the actual access modes the volume backing the PVC has.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1
            '';
          type = (listOf PersistentVolumeAccessMode);
        };
        capacity = mkOption {
          description = ''
            capacity represents the actual resources of the underlying volume.
            '';
          type = ResourceList;
        };
        conditions = mkOption {
          description = ''
            conditions is the current Condition of persistent volume claim. If underlying persistent volume is being
            resized then the Condition will be set to 'ResizeStarted'.
            '';
          type = (listOf PersistentVolumeClaimCondition);
        };
        allocatedResources = mkOption {
          description = ''
            allocatedResources is the storage resource within AllocatedResources tracks the capacity allocated to a PVC. It may
            be larger than the actual capacity when a volume expansion operation is requested.
            For storage quota, the larger value from allocatedResources and PVC.spec.resources is used.
            If allocatedResources is not set, PVC.spec.resources alone is used for quota calculation.
            If a volume expansion capacity request is lowered, allocatedResources is only
            lowered if there are no expansion operations in progress and if the actual volume capacity
            is equal or lower than the requested capacity.
            This is an alpha field and requires enabling RecoverVolumeExpansionFailure feature.
            '';
          type = ResourceList;
        };
        resizeStatus = mkOption {
          description = ''
            resizeStatus stores status of resize operation.
            ResizeStatus is not set by default but when expansion is complete resizeStatus is set to empty
            string by resize controller or kubelet.
            This is an alpha field and requires enabling RecoverVolumeExpansionFailure feature.
            '';
          type = PersistentVolumeClaimResizeStatus;
        };
      };
    };
  };
  PersistentVolumeClaimTemplate = lib.mkOption {
    description = ''
      PersistentVolumeClaimTemplate is used to produce
      PersistentVolumeClaim objects as part of an EphemeralVolumeSource.
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            May contain labels and annotations that will be copied into the PVC
            when creating it. No other fields are allowed and will be rejected during
            validation.
            
            '';
          type = meta/v1.ObjectMeta;
        };
        spec = mkOption {
          description = ''
            The specification for the PersistentVolumeClaim. The entire content is
            copied unchanged into the PVC that gets created from this
            template. The same fields as in a PersistentVolumeClaim
            are also valid here.
            '';
          type = PersistentVolumeClaimSpec;
        };
      };
    };
  };
  PersistentVolumeClaimVolumeSource = lib.mkOption {
    description = ''
      PersistentVolumeClaimVolumeSource references the user's PVC in the same namespace.
      This volume finds the bound PV and mounts that volume for the pod. A
      PersistentVolumeClaimVolumeSource is, essentially, a wrapper around another
      type of volume that is owned by someone else (the system).
      '';
    type = submodule {
      options = {
        claimName = mkOption {
          description = ''
            claimName is the name of a PersistentVolumeClaim in the same namespace as the pod using this volume.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly Will force the ReadOnly setting in VolumeMounts.
            Default false.
            '';
          type = bool;
        };
      };
    };
  };
  PersistentVolumeMode = lib.mkOption {
    description = ''
      PersistentVolumeMode describes how a volume is intended to be consumed, either Block or Filesystem.
      '';
  };
  PersistentVolumePhase = lib.mkOption {
    description = ''

      '';
  };
  PersistentVolumeReclaimPolicy = lib.mkOption {
    description = ''
      PersistentVolumeReclaimPolicy describes a policy for end-of-life maintenance of persistent volumes.
      '';
  };
  PersistentVolumeSource = lib.mkOption {
    description = ''
      PersistentVolumeSource is similar to VolumeSource but meant for the
      administrator who creates PVs. Exactly one of its members must be set.
      '';
    type = submodule {
      options = {
        gcePersistentDisk = mkOption {
          description = ''
            gcePersistentDisk represents a GCE Disk resource that is attached to a
            kubelet's host machine and then exposed to the pod. Provisioned by an admin.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
            '';
          type = GCEPersistentDiskVolumeSource;
        };
        awsElasticBlockStore = mkOption {
          description = ''
            awsElasticBlockStore represents an AWS Disk resource that is attached to a
            kubelet's host machine and then exposed to the pod.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
            '';
          type = AWSElasticBlockStoreVolumeSource;
        };
        hostPath = mkOption {
          description = ''
            hostPath represents a directory on the host.
            Provisioned by a developer or tester.
            This is useful for single-node development and testing only!
            On-host storage is not supported in any way and WILL NOT WORK in a multi-node cluster.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath
            '';
          type = HostPathVolumeSource;
        };
        glusterfs = mkOption {
          description = ''
            glusterfs represents a Glusterfs volume that is attached to a host and
            exposed to the pod. Provisioned by an admin.
            More info: https://examples.k8s.io/volumes/glusterfs/README.md
            '';
          type = GlusterfsPersistentVolumeSource;
        };
        nfs = mkOption {
          description = ''
            nfs represents an NFS mount on the host. Provisioned by an admin.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
            '';
          type = NFSVolumeSource;
        };
        rbd = mkOption {
          description = ''
            rbd represents a Rados Block Device mount on the host that shares a pod's lifetime.
            More info: https://examples.k8s.io/volumes/rbd/README.md
            '';
          type = RBDPersistentVolumeSource;
        };
        iscsi = mkOption {
          description = ''
            iscsi represents an ISCSI Disk resource that is attached to a
            kubelet's host machine and then exposed to the pod. Provisioned by an admin.
            '';
          type = ISCSIPersistentVolumeSource;
        };
        cinder = mkOption {
          description = ''
            cinder represents a cinder volume attached and mounted on kubelets host machine.
            More info: https://examples.k8s.io/mysql-cinder-pd/README.md
            '';
          type = CinderPersistentVolumeSource;
        };
        cephfs = mkOption {
          description = ''
            cephFS represents a Ceph FS mount on the host that shares a pod's lifetime
            '';
          type = CephFSPersistentVolumeSource;
        };
        fc = mkOption {
          description = ''
            fc represents a Fibre Channel resource that is attached to a kubelet's host machine and then exposed to the pod.
            '';
          type = FCVolumeSource;
        };
        flocker = mkOption {
          description = ''
            flocker represents a Flocker volume attached to a kubelet's host machine and exposed to the pod for its usage. This depends on the Flocker control service being running
            '';
          type = FlockerVolumeSource;
        };
        flexVolume = mkOption {
          description = ''
            flexVolume represents a generic volume resource that is
            provisioned/attached using an exec based plugin.
            '';
          type = FlexPersistentVolumeSource;
        };
        azureFile = mkOption {
          description = ''
            azureFile represents an Azure File Service mount on the host and bind mount to the pod.
            '';
          type = AzureFilePersistentVolumeSource;
        };
        vsphereVolume = mkOption {
          description = ''
            vsphereVolume represents a vSphere volume attached and mounted on kubelets host machine
            '';
          type = VsphereVirtualDiskVolumeSource;
        };
        quobyte = mkOption {
          description = ''
            quobyte represents a Quobyte mount on the host that shares a pod's lifetime
            '';
          type = QuobyteVolumeSource;
        };
        azureDisk = mkOption {
          description = ''
            azureDisk represents an Azure Data Disk mount on the host and bind mount to the pod.
            '';
          type = AzureDiskVolumeSource;
        };
        photonPersistentDisk = mkOption {
          description = ''
            photonPersistentDisk represents a PhotonController persistent disk attached and mounted on kubelets host machine
            '';
          type = PhotonPersistentDiskVolumeSource;
        };
        portworxVolume = mkOption {
          description = ''
            portworxVolume represents a portworx volume attached and mounted on kubelets host machine
            '';
          type = PortworxVolumeSource;
        };
        scaleIO = mkOption {
          description = ''
            scaleIO represents a ScaleIO persistent volume attached and mounted on Kubernetes nodes.
            '';
          type = ScaleIOPersistentVolumeSource;
        };
        local = mkOption {
          description = ''
            local represents directly-attached storage with node affinity
            '';
          type = LocalVolumeSource;
        };
        storageos = mkOption {
          description = ''
            storageOS represents a StorageOS volume that is attached to the kubelet's host machine and mounted into the pod
            More info: https://examples.k8s.io/volumes/storageos/README.md
            '';
          type = StorageOSPersistentVolumeSource;
        };
        csi = mkOption {
          description = ''
            csi represents storage that is handled by an external CSI driver (Beta feature).
            '';
          type = CSIPersistentVolumeSource;
        };
      };
    };
  };
  PersistentVolumeSpec = lib.mkOption {
    description = ''
      PersistentVolumeSpec is the specification of a persistent volume.
      '';
    type = submodule {
      options = {
        capacity = mkOption {
          description = ''
            capacity is the description of the persistent volume's resources and capacity.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#capacity
            '';
          type = ResourceList;
        };
        PersistentVolumeSource = mkOption {
          description = ''
            persistentVolumeSource is the actual volume backing the persistent volume.
            '';
          type = PersistentVolumeSource;
        };
        accessModes = mkOption {
          description = ''
            accessModes contains all ways the volume can be mounted.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes
            '';
          type = (listOf PersistentVolumeAccessMode);
        };
        claimRef = mkOption {
          description = ''
            claimRef is part of a bi-directional binding between PersistentVolume and PersistentVolumeClaim.
            Expected to be non-nil when bound.
            claim.VolumeName is the authoritative bind between PV and PVC.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#binding
            '';
          type = ObjectReference;
        };
        persistentVolumeReclaimPolicy = mkOption {
          description = ''
            persistentVolumeReclaimPolicy defines what happens to a persistent volume when released from its claim.
            Valid options are Retain (default for manually created PersistentVolumes), Delete (default
            for dynamically provisioned PersistentVolumes), and Recycle (deprecated).
            Recycle must be supported by the volume plugin underlying this PersistentVolume.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#reclaiming
            '';
          type = PersistentVolumeReclaimPolicy;
        };
        storageClassName = mkOption {
          description = ''
            storageClassName is the name of StorageClass to which this persistent volume belongs. Empty value
            means that this volume does not belong to any StorageClass.
            '';
          type = str;
        };
        mountOptions = mkOption {
          description = ''
            mountOptions is the list of mount options, e.g. ["ro", "soft"]. Not validated - mount will
            simply fail if one is invalid.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#mount-options
            '';
          type = (listOf str);
        };
        volumeMode = mkOption {
          description = ''
            volumeMode defines if a volume is intended to be used with a formatted filesystem
            or to remain in raw block state. Value of Filesystem is implied when not included in spec.
            '';
          type = PersistentVolumeMode;
        };
        nodeAffinity = mkOption {
          description = ''
            nodeAffinity defines constraints that limit what nodes this volume can be accessed from.
            This field influences the scheduling of pods that use this volume.
            '';
          type = VolumeNodeAffinity;
        };
      };
    };
  };
  PersistentVolumeStatus = lib.mkOption {
    description = ''
      PersistentVolumeStatus is the current status of a persistent volume.
      '';
    type = submodule {
      options = {
        phase = mkOption {
          description = ''
            phase indicates if a volume is available, bound to a claim, or released by a claim.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#phase
            '';
          type = PersistentVolumePhase;
        };
        message = mkOption {
          description = ''
            message is a human-readable message indicating details about why the volume is in this state.
            '';
          type = str;
        };
        reason = mkOption {
          description = ''
            reason is a brief CamelCase string that describes any failure and is meant
            for machine parsing and tidy display in the CLI.
            '';
          type = str;
        };
      };
    };
  };
  PhotonPersistentDiskVolumeSource = lib.mkOption {
    description = ''
      Represents a Photon Controller persistent disk resource.
      '';
    type = submodule {
      options = {
        pdID = mkOption {
          description = ''
            pdID is the ID that identifies Photon Controller persistent disk
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            '';
          type = str;
        };
      };
    };
  };
  PodAffinity = lib.mkOption {
    description = ''
      Pod affinity is a group of inter pod affinity scheduling rules.
      '';
    type = submodule {
      options = {
        requiredDuringSchedulingIgnoredDuringExecution = mkOption {
          description = ''
            If the affinity requirements specified by this field are not met at
            scheduling time, the pod will not be scheduled onto the node.
            If the affinity requirements specified by this field cease to be met
            at some point during pod execution (e.g. due to a pod label update), the
            system may or may not try to eventually evict the pod from its node.
            When there are multiple elements, the lists of nodes corresponding to each
            podAffinityTerm are intersected, i.e. all terms must be satisfied.
            '';
          type = (listOf PodAffinityTerm);
        };
        preferredDuringSchedulingIgnoredDuringExecution = mkOption {
          description = ''
            The scheduler will prefer to schedule pods to nodes that satisfy
            the affinity expressions specified by this field, but it may choose
            a node that violates one or more of the expressions. The node that is
            most preferred is the one with the greatest sum of weights, i.e.
            for each node that meets all of the scheduling requirements (resource
            request, requiredDuringScheduling affinity expressions, etc.),
            compute a sum by iterating through the elements of this field and adding
            "weight" to the sum if the node has pods which matches the corresponding podAffinityTerm; the
            node(s) with the highest sum are the most preferred.
            '';
          type = (listOf WeightedPodAffinityTerm);
        };
      };
    };
  };
  PodAffinityTerm = lib.mkOption {
    description = ''
      Defines a set of pods (namely those matching the labelSelector
      relative to the given namespace(s)) that this pod should be
      co-located (affinity) or not co-located (anti-affinity) with,
      where co-located is defined as running on a node whose value of
      the label with key <topologyKey> matches that of any node on which
      a pod of the set of pods is running
      '';
    type = submodule {
      options = {
        labelSelector = mkOption {
          description = ''
            A label query over a set of resources, in this case pods.
            '';
          type = meta/v1.LabelSelector;
        };
        namespaces = mkOption {
          description = ''
            namespaces specifies a static list of namespace names that the term applies to.
            The term is applied to the union of the namespaces listed in this field
            and the ones selected by namespaceSelector.
            null or empty namespaces list and null namespaceSelector means "this pod's namespace".
            '';
          type = (listOf str);
        };
        topologyKey = mkOption {
          description = ''
            This pod should be co-located (affinity) or not co-located (anti-affinity) with the pods matching
            the labelSelector in the specified namespaces, where co-located is defined as running on a node
            whose value of the label with key topologyKey matches that of any node on which any of the
            selected pods is running.
            Empty topologyKey is not allowed.
            '';
          type = str;
        };
        namespaceSelector = mkOption {
          description = ''
            A label query over the set of namespaces that the term applies to.
            The term is applied to the union of the namespaces selected by this field
            and the ones listed in the namespaces field.
            null selector and null or empty namespaces list means "this pod's namespace".
            An empty selector ({}) matches all namespaces.
            '';
          type = meta/v1.LabelSelector;
        };
      };
    };
  };
  PodAntiAffinity = lib.mkOption {
    description = ''
      Pod anti affinity is a group of inter pod anti affinity scheduling rules.
      '';
    type = submodule {
      options = {
        requiredDuringSchedulingIgnoredDuringExecution = mkOption {
          description = ''
            If the anti-affinity requirements specified by this field are not met at
            scheduling time, the pod will not be scheduled onto the node.
            If the anti-affinity requirements specified by this field cease to be met
            at some point during pod execution (e.g. due to a pod label update), the
            system may or may not try to eventually evict the pod from its node.
            When there are multiple elements, the lists of nodes corresponding to each
            podAffinityTerm are intersected, i.e. all terms must be satisfied.
            '';
          type = (listOf PodAffinityTerm);
        };
        preferredDuringSchedulingIgnoredDuringExecution = mkOption {
          description = ''
            The scheduler will prefer to schedule pods to nodes that satisfy
            the anti-affinity expressions specified by this field, but it may choose
            a node that violates one or more of the expressions. The node that is
            most preferred is the one with the greatest sum of weights, i.e.
            for each node that meets all of the scheduling requirements (resource
            request, requiredDuringScheduling anti-affinity expressions, etc.),
            compute a sum by iterating through the elements of this field and adding
            "weight" to the sum if the node has pods which matches the corresponding podAffinityTerm; the
            node(s) with the highest sum are the most preferred.
            '';
          type = (listOf WeightedPodAffinityTerm);
        };
      };
    };
  };
  PodCondition = lib.mkOption {
    description = ''
      PodCondition contains details for the current condition of this pod.
      '';
    type = submodule {
      options = {
        type = mkOption {
          description = ''
            Type is the type of the condition.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-conditions
            '';
          type = PodConditionType;
        };
        status = mkOption {
          description = ''
            Status is the status of the condition.
            Can be True, False, Unknown.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-conditions
            '';
          type = ConditionStatus;
        };
        lastProbeTime = mkOption {
          description = ''
            Last time we probed the condition.
            '';
          type = meta/v1.Time;
        };
        lastTransitionTime = mkOption {
          description = ''
            Last time the condition transitioned from one status to another.
            '';
          type = meta/v1.Time;
        };
        reason = mkOption {
          description = ''
            Unique, one-word, CamelCase reason for the condition's last transition.
            '';
          type = str;
        };
        message = mkOption {
          description = ''
            Human-readable message indicating details about last transition.
            '';
          type = str;
        };
      };
    };
  };
  PodConditionType = lib.mkOption {
    description = ''
      PodConditionType is a valid value for PodCondition.Type
      '';
  };
  PodDNSConfig = lib.mkOption {
    description = ''
      PodDNSConfig defines the DNS parameters of a pod in addition to
      those generated from DNSPolicy.
      '';
    type = submodule {
      options = {
        nameservers = mkOption {
          description = ''
            A list of DNS name server IP addresses.
            This will be appended to the base nameservers generated from DNSPolicy.
            Duplicated nameservers will be removed.
            '';
          type = (listOf str);
        };
        searches = mkOption {
          description = ''
            A list of DNS search domains for host-name lookup.
            This will be appended to the base search paths generated from DNSPolicy.
            Duplicated search paths will be removed.
            '';
          type = (listOf str);
        };
        options = mkOption {
          description = ''
            A list of DNS resolver options.
            This will be merged with the base options generated from DNSPolicy.
            Duplicated entries will be removed. Resolution options given in Options
            will override those that appear in the base DNSPolicy.
            '';
          type = (listOf PodDNSConfigOption);
        };
      };
    };
  };
  PodDNSConfigOption = lib.mkOption {
    description = ''
      PodDNSConfigOption defines DNS resolver options of a pod.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Required.
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
  PodFSGroupChangePolicy = lib.mkOption {
    description = ''
      PodFSGroupChangePolicy holds policies that will be used for applying fsGroup to a volume
      when volume is mounted.
      '';
  };
  PodIP = lib.mkOption {
    description = ''
      IP address information for entries in the (plural) PodIPs field.
      Each entry includes:
      
      	IP: An IP address allocated to the pod. Routable at least within the cluster.
      '';
    type = submodule {
      options = {
        ip = mkOption {
          description = ''
            ip is an IP address (IPv4 or IPv6) assigned to the pod
            '';
          type = str;
        };
      };
    };
  };
  PodOS = lib.mkOption {
    description = ''
      PodOS defines the OS parameters of a pod.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name is the name of the operating system. The currently supported values are linux and windows.
            Additional value may be defined in future and can be one of:
            https://github.com/opencontainers/runtime-spec/blob/master/config.md#platform-specific-configuration
            Clients should expect to handle additional values and treat unrecognized values in this field as os: null
            '';
          type = OSName;
        };
      };
    };
  };
  PodPhase = lib.mkOption {
    description = ''
      PodPhase is a label for the condition of a pod at the current time.
      '';
  };
  PodQOSClass = lib.mkOption {
    description = ''
      PodQOSClass defines the supported qos classes of Pods.
      '';
  };
  PodReadinessGate = lib.mkOption {
    description = ''
      PodReadinessGate contains the reference to a pod condition
      '';
    type = submodule {
      options = {
        conditionType = mkOption {
          description = ''
            ConditionType refers to a condition in the pod's condition list with matching type.
            '';
          type = PodConditionType;
        };
      };
    };
  };
  PodResourceClaim = lib.mkOption {
    description = ''
      PodResourceClaim references exactly one ResourceClaim through a ClaimSource.
      It adds a name to it that uniquely identifies the ResourceClaim inside the Pod.
      Containers that need access to the ResourceClaim reference it with this name.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name uniquely identifies this resource claim inside the pod.
            This must be a DNS_LABEL.
            '';
          type = str;
        };
        source = mkOption {
          description = ''
            Source describes where to find the ResourceClaim.
            '';
          type = ClaimSource;
        };
      };
    };
  };
  PodSchedulingGate = lib.mkOption {
    description = ''
      PodSchedulingGate is associated to a Pod to guard its scheduling.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name of the scheduling gate.
            Each scheduling gate must have a unique name field.
            '';
          type = str;
        };
      };
    };
  };
  PodSecurityContext = lib.mkOption {
    description = ''
      PodSecurityContext holds pod-level security attributes and common container settings.
      Some fields are also present in container.securityContext.  Field values of
      container.securityContext take precedence over field values of PodSecurityContext.
      '';
    type = submodule {
      options = {
        seLinuxOptions = mkOption {
          description = ''
            The SELinux context to be applied to all containers.
            If unspecified, the container runtime will allocate a random SELinux context for each
            container.  May also be set in SecurityContext.  If set in
            both SecurityContext and PodSecurityContext, the value specified in SecurityContext
            takes precedence for that container.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = SELinuxOptions;
        };
        windowsOptions = mkOption {
          description = ''
            The Windows specific settings applied to all containers.
            If unspecified, the options within a container's SecurityContext will be used.
            If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.
            Note that this field cannot be set when spec.os.name is linux.
            '';
          type = WindowsSecurityContextOptions;
        };
        runAsUser = mkOption {
          description = ''
            The UID to run the entrypoint of the container process.
            Defaults to user specified in image metadata if unspecified.
            May also be set in SecurityContext.  If set in both SecurityContext and
            PodSecurityContext, the value specified in SecurityContext takes precedence
            for that container.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = int;
        };
        runAsGroup = mkOption {
          description = ''
            The GID to run the entrypoint of the container process.
            Uses runtime default if unset.
            May also be set in SecurityContext.  If set in both SecurityContext and
            PodSecurityContext, the value specified in SecurityContext takes precedence
            for that container.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = int;
        };
        runAsNonRoot = mkOption {
          description = ''
            Indicates that the container must run as a non-root user.
            If true, the Kubelet will validate the image at runtime to ensure that it
            does not run as UID 0 (root) and fail to start the container if it does.
            If unset or false, no such validation will be performed.
            May also be set in SecurityContext.  If set in both SecurityContext and
            PodSecurityContext, the value specified in SecurityContext takes precedence.
            '';
          type = bool;
        };
        supplementalGroups = mkOption {
          description = ''
            A list of groups applied to the first process run in each container, in addition
            to the container's primary GID, the fsGroup (if specified), and group memberships
            defined in the container image for the uid of the container process. If unspecified,
            no additional groups are added to any container. Note that group memberships
            defined in the container image for the uid of the container process are still effective,
            even if they are not included in this list.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = (listOf int);
        };
        fsGroup = mkOption {
          description = ''
            A special supplemental group that applies to all containers in a pod.
            Some volume types allow the Kubelet to change the ownership of that volume
            to be owned by the pod:
            
            1. The owning GID will be the FSGroup
            2. The setgid bit is set (new files created in the volume will be owned by FSGroup)
            3. The permission bits are OR'd with rw-rw----
            
            If unset, the Kubelet will not modify the ownership and permissions of any volume.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = int;
        };
        sysctls = mkOption {
          description = ''
            Sysctls hold a list of namespaced sysctls used for the pod. Pods with unsupported
            sysctls (by the container runtime) might fail to launch.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = (listOf Sysctl);
        };
        fsGroupChangePolicy = mkOption {
          description = ''
            fsGroupChangePolicy defines behavior of changing ownership and permission of the volume
            before being exposed inside Pod. This field will only apply to
            volume types which support fsGroup based ownership(and permissions).
            It will have no effect on ephemeral volume types such as: secret, configmaps
            and emptydir.
            Valid values are "OnRootMismatch" and "Always". If not specified, "Always" is used.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = PodFSGroupChangePolicy;
        };
        seccompProfile = mkOption {
          description = ''
            The seccomp options to use by the containers in this pod.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = SeccompProfile;
        };
      };
    };
  };
  PodSignature = lib.mkOption {
    description = ''
      Describes the class of pods that should avoid this node.
      Exactly one field should be set.
      '';
    type = submodule {
      options = {
        podController = mkOption {
          description = ''
            Reference to controller whose pods should avoid this node.
            '';
          type = meta/v1.OwnerReference;
        };
      };
    };
  };
  PodSpec = lib.mkOption {
    description = ''
      PodSpec is a description of a pod.
      '';
    type = submodule {
      options = {
        volumes = mkOption {
          description = ''
            List of volumes that can be mounted by containers belonging to the pod.
            More info: https://kubernetes.io/docs/concepts/storage/volumes
            '';
          type = (listOf Volume);
        };
        initContainers = mkOption {
          description = ''
            List of initialization containers belonging to the pod.
            Init containers are executed in order prior to containers being started. If any
            init container fails, the pod is considered to have failed and is handled according
            to its restartPolicy. The name for an init container or normal container must be
            unique among all containers.
            Init containers may not have Lifecycle actions, Readiness probes, Liveness probes, or Startup probes.
            The resourceRequirements of an init container are taken into account during scheduling
            by finding the highest request/limit for each resource type, and then using the max of
            of that value or the sum of the normal containers. Limits are applied to init containers
            in a similar fashion.
            Init containers cannot currently be added or removed.
            Cannot be updated.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
            '';
          type = (listOf Container);
        };
        containers = mkOption {
          description = ''
            List of containers belonging to the pod.
            Containers cannot currently be added or removed.
            There must be at least one container in a Pod.
            Cannot be updated.
            '';
          type = (listOf Container);
        };
        ephemeralContainers = mkOption {
          description = ''
            List of ephemeral containers run in this pod. Ephemeral containers may be run in an existing
            pod to perform user-initiated actions such as debugging. This list cannot be specified when
            creating a pod, and it cannot be modified by updating the pod spec. In order to add an
            ephemeral container to an existing pod, use the pod's ephemeralcontainers subresource.
            '';
          type = (listOf EphemeralContainer);
        };
        restartPolicy = mkOption {
          description = ''
            Restart policy for all containers within the pod.
            One of Always, OnFailure, Never.
            Default to Always.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy
            '';
          type = RestartPolicy;
        };
        terminationGracePeriodSeconds = mkOption {
          description = ''
            Optional duration in seconds the pod needs to terminate gracefully. May be decreased in delete request.
            Value must be non-negative integer. The value zero indicates stop immediately via
            the kill signal (no opportunity to shut down).
            If this value is nil, the default grace period will be used instead.
            The grace period is the duration in seconds after the processes running in the pod are sent
            a termination signal and the time when the processes are forcibly halted with a kill signal.
            Set this value longer than the expected cleanup time for your process.
            Defaults to 30 seconds.
            '';
          type = int;
        };
        activeDeadlineSeconds = mkOption {
          description = ''
            Optional duration in seconds the pod may be active on the node relative to
            StartTime before the system will actively try to mark it failed and kill associated containers.
            Value must be a positive integer.
            '';
          type = int;
        };
        dnsPolicy = mkOption {
          description = ''
            Set DNS policy for the pod.
            Defaults to "ClusterFirst".
            Valid values are 'ClusterFirstWithHostNet', 'ClusterFirst', 'Default' or 'None'.
            DNS parameters given in DNSConfig will be merged with the policy selected with DNSPolicy.
            To have DNS options set along with hostNetwork, you have to specify DNS policy
            explicitly to 'ClusterFirstWithHostNet'.
            '';
          type = DNSPolicy;
        };
        nodeSelector = mkOption {
          description = ''
            NodeSelector is a selector which must be true for the pod to fit on a node.
            Selector which must match a node's labels for the pod to be scheduled on that node.
            More info: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
            '';
          type = (attrsOf str);
        };
        serviceAccountName = mkOption {
          description = ''
            ServiceAccountName is the name of the ServiceAccount to use to run this pod.
            More info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
            '';
          type = str;
        };
        serviceAccount = mkOption {
          description = ''
            DeprecatedServiceAccount is a depreciated alias for ServiceAccountName.
            Deprecated: Use serviceAccountName instead.
            '';
          type = str;
        };
        automountServiceAccountToken = mkOption {
          description = ''
            AutomountServiceAccountToken indicates whether a service account token should be automatically mounted.
            '';
          type = bool;
        };
        nodeName = mkOption {
          description = ''
            NodeName is a request to schedule this pod onto a specific node. If it is non-empty,
            the scheduler simply schedules this pod onto that node, assuming that it fits resource
            requirements.
            '';
          type = str;
        };
        hostNetwork = mkOption {
          description = ''
            Host networking requested for this pod. Use the host's network namespace.
            If this option is set, the ports that will be used must be specified.
            Default to false.
            '';
          type = bool;
        };
        hostPID = mkOption {
          description = ''
            Use the host's pid namespace.
            Optional: Default to false.
            '';
          type = bool;
        };
        hostIPC = mkOption {
          description = ''
            Use the host's ipc namespace.
            Optional: Default to false.
            '';
          type = bool;
        };
        shareProcessNamespace = mkOption {
          description = ''
            Share a single process namespace between all of the containers in a pod.
            When this is set containers will be able to view and signal processes from other containers
            in the same pod, and the first process in each container will not be assigned PID 1.
            HostPID and ShareProcessNamespace cannot both be set.
            Optional: Default to false.
            '';
          type = bool;
        };
        securityContext = mkOption {
          description = ''
            SecurityContext holds pod-level security attributes and common container settings.
            Optional: Defaults to empty.  See type description for default values of each field.
            '';
          type = PodSecurityContext;
        };
        imagePullSecrets = mkOption {
          description = ''
            ImagePullSecrets is an optional list of references to secrets in the same namespace to use for pulling any of the images used by this PodSpec.
            If specified, these secrets will be passed to individual puller implementations for them to use.
            More info: https://kubernetes.io/docs/concepts/containers/images#specifying-imagepullsecrets-on-a-pod
            '';
          type = (listOf LocalObjectReference);
        };
        hostname = mkOption {
          description = ''
            Specifies the hostname of the Pod
            If not specified, the pod's hostname will be set to a system-defined value.
            '';
          type = str;
        };
        subdomain = mkOption {
          description = ''
            If specified, the fully qualified Pod hostname will be "<hostname>.<subdomain>.<pod namespace>.svc.<cluster domain>".
            If not specified, the pod will not have a domainname at all.
            '';
          type = str;
        };
        affinity = mkOption {
          description = ''
            If specified, the pod's scheduling constraints
            '';
          type = Affinity;
        };
        schedulerName = mkOption {
          description = ''
            If specified, the pod will be dispatched by specified scheduler.
            If not specified, the pod will be dispatched by default scheduler.
            '';
          type = str;
        };
        tolerations = mkOption {
          description = ''
            If specified, the pod's tolerations.
            '';
          type = (listOf Toleration);
        };
        hostAliases = mkOption {
          description = ''
            HostAliases is an optional list of hosts and IPs that will be injected into the pod's hosts
            file if specified. This is only valid for non-hostNetwork pods.
            '';
          type = (listOf HostAlias);
        };
        priorityClassName = mkOption {
          description = ''
            If specified, indicates the pod's priority. "system-node-critical" and
            "system-cluster-critical" are two special keywords which indicate the
            highest priorities with the former being the highest priority. Any other
            name must be defined by creating a PriorityClass object with that name.
            If not specified, the pod priority will be default or zero if there is no
            default.
            '';
          type = str;
        };
        priority = mkOption {
          description = ''
            The priority value. Various system components use this field to find the
            priority of the pod. When Priority Admission Controller is enabled, it
            prevents users from setting this field. The admission controller populates
            this field from PriorityClassName.
            The higher the value, the higher the priority.
            '';
          type = int;
        };
        dnsConfig = mkOption {
          description = ''
            Specifies the DNS parameters of a pod.
            Parameters specified here will be merged to the generated DNS
            configuration based on DNSPolicy.
            '';
          type = PodDNSConfig;
        };
        readinessGates = mkOption {
          description = ''
            If specified, all readiness gates will be evaluated for pod readiness.
            A pod is ready when all its containers are ready AND
            all conditions specified in the readiness gates have status equal to "True"
            More info: https://git.k8s.io/enhancements/keps/sig-network/580-pod-readiness-gates
            '';
          type = (listOf PodReadinessGate);
        };
        runtimeClassName = mkOption {
          description = ''
            RuntimeClassName refers to a RuntimeClass object in the node.k8s.io group, which should be used
            to run this pod.  If no RuntimeClass resource matches the named class, the pod will not be run.
            If unset or empty, the "legacy" RuntimeClass will be used, which is an implicit class with an
            empty definition that uses the default runtime handler.
            More info: https://git.k8s.io/enhancements/keps/sig-node/585-runtime-class
            '';
          type = str;
        };
        enableServiceLinks = mkOption {
          description = ''
            EnableServiceLinks indicates whether information about services should be injected into pod's
            environment variables, matching the syntax of Docker links.
            Optional: Defaults to true.
            '';
          type = bool;
        };
        preemptionPolicy = mkOption {
          description = ''
            PreemptionPolicy is the Policy for preempting pods with lower priority.
            One of Never, PreemptLowerPriority.
            Defaults to PreemptLowerPriority if unset.
            '';
          type = PreemptionPolicy;
        };
        overhead = mkOption {
          description = ''
            Overhead represents the resource overhead associated with running a pod for a given RuntimeClass.
            This field will be autopopulated at admission time by the RuntimeClass admission controller. If
            the RuntimeClass admission controller is enabled, overhead must not be set in Pod create requests.
            The RuntimeClass admission controller will reject Pod create requests which have the overhead already
            set. If RuntimeClass is configured and selected in the PodSpec, Overhead will be set to the value
            defined in the corresponding RuntimeClass, otherwise it will remain unset and treated as zero.
            More info: https://git.k8s.io/enhancements/keps/sig-node/688-pod-overhead/README.md
            '';
          type = ResourceList;
        };
        topologySpreadConstraints = mkOption {
          description = ''
            TopologySpreadConstraints describes how a group of pods ought to spread across topology
            domains. Scheduler will schedule pods in a way which abides by the constraints.
            All topologySpreadConstraints are ANDed.
            '';
          type = (listOf TopologySpreadConstraint);
        };
        setHostnameAsFQDN = mkOption {
          description = ''
            If true the pod's hostname will be configured as the pod's FQDN, rather than the leaf name (the default).
            In Linux containers, this means setting the FQDN in the hostname field of the kernel (the nodename field of struct utsname).
            In Windows containers, this means setting the registry value of hostname for the registry key HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters to FQDN.
            If a pod does not have FQDN, this has no effect.
            Default to false.
            '';
          type = bool;
        };
        os = mkOption {
          description = ''
            Specifies the OS of the containers in the pod.
            Some pod and container fields are restricted if this is set.
            
            If the OS field is set to linux, the following fields must be unset:
            -securityContext.windowsOptions
            
            If the OS field is set to windows, following fields must be unset:
            - spec.hostPID
            - spec.hostIPC
            - spec.hostUsers
            - spec.securityContext.seLinuxOptions
            - spec.securityContext.seccompProfile
            - spec.securityContext.fsGroup
            - spec.securityContext.fsGroupChangePolicy
            - spec.securityContext.sysctls
            - spec.shareProcessNamespace
            - spec.securityContext.runAsUser
            - spec.securityContext.runAsGroup
            - spec.securityContext.supplementalGroups
            - spec.containers[*].securityContext.seLinuxOptions
            - spec.containers[*].securityContext.seccompProfile
            - spec.containers[*].securityContext.capabilities
            - spec.containers[*].securityContext.readOnlyRootFilesystem
            - spec.containers[*].securityContext.privileged
            - spec.containers[*].securityContext.allowPrivilegeEscalation
            - spec.containers[*].securityContext.procMount
            - spec.containers[*].securityContext.runAsUser
            - spec.containers[*].securityContext.runAsGroup
            '';
          type = PodOS;
        };
        hostUsers = mkOption {
          description = ''
            Use the host's user namespace.
            Optional: Default to true.
            If set to true or not present, the pod will be run in the host user namespace, useful
            for when the pod needs a feature only available to the host user namespace, such as
            loading a kernel module with CAP_SYS_MODULE.
            When set to false, a new userns is created for the pod. Setting false is useful for
            mitigating container breakout vulnerabilities even allowing users to run their
            containers as root without actually having root privileges on the host.
            This field is alpha-level and is only honored by servers that enable the UserNamespacesSupport feature.
            '';
          type = bool;
        };
        schedulingGates = mkOption {
          description = ''
            SchedulingGates is an opaque list of values that if specified will block scheduling the pod.
            More info:  https://git.k8s.io/enhancements/keps/sig-scheduling/3521-pod-scheduling-readiness.
            
            This is an alpha-level feature enabled by PodSchedulingReadiness feature gate.
            '';
          type = (listOf PodSchedulingGate);
        };
        resourceClaims = mkOption {
          description = ''
            ResourceClaims defines which ResourceClaims must be allocated
            and reserved before the Pod is allowed to start. The resources
            will be made available to those containers which consume them
            by name.
            
            This is an alpha field and requires enabling the
            DynamicResourceAllocation feature gate.
            
            This field is immutable.
            
            '';
          type = (listOf PodResourceClaim);
        };
      };
    };
  };
  PodStatus = lib.mkOption {
    description = ''
      PodStatus represents information about the status of a pod. Status may trail the actual
      state of a system, especially if the node that hosts the pod cannot contact the control
      plane.
      '';
    type = submodule {
      options = {
        phase = mkOption {
          description = ''
            The phase of a Pod is a simple, high-level summary of where the Pod is in its lifecycle.
            The conditions array, the reason and message fields, and the individual container status
            arrays contain more detail about the pod's status.
            There are five possible phase values:
            
            Pending: The pod has been accepted by the Kubernetes system, but one or more of the
            container images has not been created. This includes time before being scheduled as
            well as time spent downloading images over the network, which could take a while.
            Running: The pod has been bound to a node, and all of the containers have been created.
            At least one container is still running, or is in the process of starting or restarting.
            Succeeded: All containers in the pod have terminated in success, and will not be restarted.
            Failed: All containers in the pod have terminated, and at least one container has
            terminated in failure. The container either exited with non-zero status or was terminated
            by the system.
            Unknown: For some reason the state of the pod could not be obtained, typically due to an
            error in communicating with the host of the pod.
            
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-phase
            '';
          type = PodPhase;
        };
        conditions = mkOption {
          description = ''
            Current service state of pod.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-conditions
            '';
          type = (listOf PodCondition);
        };
        message = mkOption {
          description = ''
            A human readable message indicating details about why the pod is in this condition.
            '';
          type = str;
        };
        reason = mkOption {
          description = ''
            A brief CamelCase message indicating details about why the pod is in this state.
            e.g. 'Evicted'
            '';
          type = str;
        };
        nominatedNodeName = mkOption {
          description = ''
            nominatedNodeName is set only when this pod preempts other pods on the node, but it cannot be
            scheduled right away as preemption victims receive their graceful termination periods.
            This field does not guarantee that the pod will be scheduled on this node. Scheduler may decide
            to place the pod elsewhere if other nodes become available sooner. Scheduler may also decide to
            give the resources on this node to a higher priority pod that is created after preemption.
            As a result, this field may be different than PodSpec.nodeName when the pod is
            scheduled.
            '';
          type = str;
        };
        hostIP = mkOption {
          description = ''
            IP address of the host to which the pod is assigned. Empty if not yet scheduled.
            '';
          type = str;
        };
        podIP = mkOption {
          description = ''
            IP address allocated to the pod. Routable at least within the cluster.
            Empty if not yet allocated.
            '';
          type = str;
        };
        podIPs = mkOption {
          description = ''
            podIPs holds the IP addresses allocated to the pod. If this field is specified, the 0th entry must
            match the podIP field. Pods may be allocated at most 1 value for each of IPv4 and IPv6. This list
            is empty if no IPs have been allocated yet.
            '';
          type = (listOf PodIP);
        };
        startTime = mkOption {
          description = ''
            RFC 3339 date and time at which the object was acknowledged by the Kubelet.
            This is before the Kubelet pulled the container image(s) for the pod.
            '';
          type = meta/v1.Time;
        };
        initContainerStatuses = mkOption {
          description = ''
            The list has one entry per init container in the manifest. The most recent successful
            init container will have ready = true, the most recently started container will have
            startTime set.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-and-container-status
            '';
          type = (listOf ContainerStatus);
        };
        containerStatuses = mkOption {
          description = ''
            The list has one entry per container in the manifest.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-and-container-status
            '';
          type = (listOf ContainerStatus);
        };
        qosClass = mkOption {
          description = ''
            The Quality of Service (QOS) classification assigned to the pod based on resource requirements
            See PodQOSClass type for available QOS classes
            More info: https://git.k8s.io/community/contributors/design-proposals/node/resource-qos.md
            '';
          type = PodQOSClass;
        };
        ephemeralContainerStatuses = mkOption {
          description = ''
            Status for any ephemeral containers that have run in this pod.
            '';
          type = (listOf ContainerStatus);
        };
      };
    };
  };
  PodTemplateSpec = lib.mkOption {
    description = ''
      PodTemplateSpec describes the data a pod should have when created from a template
      '';
    type = submodule {
      options = {
        metadata = mkOption {
          description = ''
            Standard object's metadata.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
            '';
          type = meta/v1.ObjectMeta;
        };
        spec = mkOption {
          description = ''
            Specification of the desired behavior of the pod.
            More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
            '';
          type = PodSpec;
        };
      };
    };
  };
  PortStatus = lib.mkOption {
    description = ''
      
      '';
    type = submodule {
      options = {
        port = mkOption {
          description = ''
            Port is the port number of the service port of which status is recorded here
            '';
          type = int;
        };
        protocol = mkOption {
          description = ''
            Protocol is the protocol of the service port of which status is recorded here
            The supported values are: "TCP", "UDP", "SCTP"
            '';
          type = Protocol;
        };
        error = mkOption {
          description = ''
            Error is to record the problem with the service port
            The format of the error shall comply with the following rules:
            - built-in error values shall be specified in this file and those shall use
              CamelCase names
            - cloud provider specific error values must have names that comply with the
              format foo.example.com/CamelCase.
            ---
            The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
            '';
          type = str;
        };
      };
    };
  };
  PortworxVolumeSource = lib.mkOption {
    description = ''
      PortworxVolumeSource represents a Portworx volume resource.
      '';
    type = submodule {
      options = {
        volumeID = mkOption {
          description = ''
            volumeID uniquely identifies a Portworx volume
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fSType represents the filesystem type to mount
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs". Implicitly inferred to be "ext4" if unspecified.
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            '';
          type = bool;
        };
      };
    };
  };
  PreemptionPolicy = lib.mkOption {
    description = ''
      PreemptionPolicy describes a policy for if/when to preempt a pod.
      '';
  };
  PreferAvoidPodsEntry = lib.mkOption {
    description = ''
      Describes a class of pods that should avoid this node.
      '';
    type = submodule {
      options = {
        podSignature = mkOption {
          description = ''
            The class of pods.
            '';
          type = PodSignature;
        };
        evictionTime = mkOption {
          description = ''
            Time at which this entry was added to the list.
            '';
          type = meta/v1.Time;
        };
        reason = mkOption {
          description = ''
            (brief) reason why this entry was added to the list.
            '';
          type = str;
        };
        message = mkOption {
          description = ''
            Human readable message indicating why this entry was added to the list.
            '';
          type = str;
        };
      };
    };
  };
  PreferredSchedulingTerm = lib.mkOption {
    description = ''
      An empty preferred scheduling term matches all objects with implicit weight 0
      (i.e. it's a no-op). A null preferred scheduling term matches no objects (i.e. is also a no-op).
      '';
    type = submodule {
      options = {
        weight = mkOption {
          description = ''
            Weight associated with matching the corresponding nodeSelectorTerm, in the range 1-100.
            '';
          type = int;
        };
        preference = mkOption {
          description = ''
            A node selector term, associated with the corresponding weight.
            '';
          type = NodeSelectorTerm;
        };
      };
    };
  };
  Probe = lib.mkOption {
    description = ''
      Probe describes a health check to be performed against a container to determine whether it is
      alive or ready to receive traffic.
      '';
    type = submodule {
      options = {
        ProbeHandler = mkOption {
          description = ''
            The action taken to determine the health of a container
            '';
          type = ProbeHandler;
        };
        initialDelaySeconds = mkOption {
          description = ''
            Number of seconds after the container has started before liveness probes are initiated.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
            '';
          type = int;
        };
        timeoutSeconds = mkOption {
          description = ''
            Number of seconds after which the probe times out.
            Defaults to 1 second. Minimum value is 1.
            More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
            '';
          type = int;
        };
        periodSeconds = mkOption {
          description = ''
            How often (in seconds) to perform the probe.
            Default to 10 seconds. Minimum value is 1.
            '';
          type = int;
        };
        successThreshold = mkOption {
          description = ''
            Minimum consecutive successes for the probe to be considered successful after having failed.
            Defaults to 1. Must be 1 for liveness and startup. Minimum value is 1.
            '';
          type = int;
        };
        failureThreshold = mkOption {
          description = ''
            Minimum consecutive failures for the probe to be considered failed after having succeeded.
            Defaults to 3. Minimum value is 1.
            '';
          type = int;
        };
        terminationGracePeriodSeconds = mkOption {
          description = ''
            Optional duration in seconds the pod needs to terminate gracefully upon probe failure.
            The grace period is the duration in seconds after the processes running in the pod are sent
            a termination signal and the time when the processes are forcibly halted with a kill signal.
            Set this value longer than the expected cleanup time for your process.
            If this value is nil, the pod's terminationGracePeriodSeconds will be used. Otherwise, this
            value overrides the value provided by the pod spec.
            Value must be non-negative integer. The value zero indicates stop immediately via
            the kill signal (no opportunity to shut down).
            This is a beta field and requires enabling ProbeTerminationGracePeriod feature gate.
            Minimum value is 1. spec.terminationGracePeriodSeconds is used if unset.
            '';
          type = int;
        };
      };
    };
  };
  ProbeHandler = lib.mkOption {
    description = ''
      ProbeHandler defines a specific action that should be taken in a probe.
      One and only one of the fields must be specified.
      '';
    type = submodule {
      options = {
        exec = mkOption {
          description = ''
            Exec specifies the action to take.
            '';
          type = ExecAction;
        };
        httpGet = mkOption {
          description = ''
            HTTPGet specifies the http request to perform.
            '';
          type = HTTPGetAction;
        };
        tcpSocket = mkOption {
          description = ''
            TCPSocket specifies an action involving a TCP port.
            '';
          type = TCPSocketAction;
        };
        grpc = mkOption {
          description = ''
            GRPC specifies an action involving a GRPC port.
            This is a beta field and requires enabling GRPCContainerProbe feature gate.
            '';
          type = GRPCAction;
        };
      };
    };
  };
  ProcMountType = lib.mkOption {
    description = ''

      '';
  };
  ProjectedVolumeSource = lib.mkOption {
    description = ''
      Represents a projected volume source
      '';
    type = submodule {
      options = {
        sources = mkOption {
          description = ''
            sources is the list of volume projections
            '';
          type = (listOf VolumeProjection);
        };
        defaultMode = mkOption {
          description = ''
            defaultMode are the mode bits used to set permissions on created files by default.
            Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
            YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
            Directories within the path are not affected by this setting.
            This might be in conflict with other options that affect the file
            mode, like fsGroup, and the result can be other mode bits set.
            '';
          type = int;
        };
      };
    };
  };
  Protocol = lib.mkOption {
    description = ''
      Protocol defines network protocols supported for things like container ports.
      '';
  };
  PullPolicy = lib.mkOption {
    description = ''
      PullPolicy describes a policy for if/when to pull a container image
      '';
  };
  QuobyteVolumeSource = lib.mkOption {
    description = ''
      Represents a Quobyte mount that lasts the lifetime of a pod.
      Quobyte volumes do not support ownership management or SELinux relabeling.
      '';
    type = submodule {
      options = {
        registry = mkOption {
          description = ''
            registry represents a single or multiple Quobyte Registry services
            specified as a string as host:port pair (multiple entries are separated with commas)
            which acts as the central registry for volumes
            '';
          type = str;
        };
        volume = mkOption {
          description = ''
            volume is a string that references an already created Quobyte volume by name.
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly here will force the Quobyte volume to be mounted with read-only permissions.
            Defaults to false.
            '';
          type = bool;
        };
        user = mkOption {
          description = ''
            user to map volume access to
            Defaults to serivceaccount user
            '';
          type = str;
        };
        group = mkOption {
          description = ''
            group to map volume access to
            Default is no group
            '';
          type = str;
        };
        tenant = mkOption {
          description = ''
            tenant owning the given Quobyte volume in the Backend
            Used with dynamically provisioned Quobyte volumes, value is set by the plugin
            '';
          type = str;
        };
      };
    };
  };
  RBDPersistentVolumeSource = lib.mkOption {
    description = ''
      Represents a Rados Block Device mount that lasts the lifetime of a pod.
      RBD volumes support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        monitors = mkOption {
          description = ''
            monitors is a collection of Ceph monitors.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = (listOf str);
        };
        image = mkOption {
          description = ''
            image is the rados image name.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type of the volume that you want to mount.
            Tip: Ensure that the filesystem type is supported by the host operating system.
            Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#rbd
            TODO: how do we prevent errors in the filesystem from compromising the machine
            '';
          type = str;
        };
        pool = mkOption {
          description = ''
            pool is the rados pool name.
            Default is rbd.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = str;
        };
        user = mkOption {
          description = ''
            user is the rados user name.
            Default is admin.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = str;
        };
        keyring = mkOption {
          description = ''
            keyring is the path to key ring for RBDUser.
            Default is /etc/ceph/keyring.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = str;
        };
        secretRef = mkOption {
          description = ''
            secretRef is name of the authentication secret for RBDUser. If provided
            overrides keyring.
            Default is nil.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = SecretReference;
        };
        readOnly = mkOption {
          description = ''
            readOnly here will force the ReadOnly setting in VolumeMounts.
            Defaults to false.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = bool;
        };
      };
    };
  };
  RBDVolumeSource = lib.mkOption {
    description = ''
      Represents a Rados Block Device mount that lasts the lifetime of a pod.
      RBD volumes support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        monitors = mkOption {
          description = ''
            monitors is a collection of Ceph monitors.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = (listOf str);
        };
        image = mkOption {
          description = ''
            image is the rados image name.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type of the volume that you want to mount.
            Tip: Ensure that the filesystem type is supported by the host operating system.
            Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#rbd
            TODO: how do we prevent errors in the filesystem from compromising the machine
            '';
          type = str;
        };
        pool = mkOption {
          description = ''
            pool is the rados pool name.
            Default is rbd.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = str;
        };
        user = mkOption {
          description = ''
            user is the rados user name.
            Default is admin.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = str;
        };
        keyring = mkOption {
          description = ''
            keyring is the path to key ring for RBDUser.
            Default is /etc/ceph/keyring.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = str;
        };
        secretRef = mkOption {
          description = ''
            secretRef is name of the authentication secret for RBDUser. If provided
            overrides keyring.
            Default is nil.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = LocalObjectReference;
        };
        readOnly = mkOption {
          description = ''
            readOnly here will force the ReadOnly setting in VolumeMounts.
            Defaults to false.
            More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
            '';
          type = bool;
        };
      };
    };
  };
  ReplicationControllerCondition = lib.mkOption {
    description = ''
      ReplicationControllerCondition describes the state of a replication controller at a certain point.
      '';
    type = submodule {
      options = {
        type = mkOption {
          description = ''
            Type of replication controller condition.
            '';
          type = ReplicationControllerConditionType;
        };
        status = mkOption {
          description = ''
            Status of the condition, one of True, False, Unknown.
            '';
          type = ConditionStatus;
        };
        lastTransitionTime = mkOption {
          description = ''
            The last time the condition transitioned from one status to another.
            '';
          type = meta/v1.Time;
        };
        reason = mkOption {
          description = ''
            The reason for the condition's last transition.
            '';
          type = str;
        };
        message = mkOption {
          description = ''
            A human readable message indicating details about the transition.
            '';
          type = str;
        };
      };
    };
  };
  ReplicationControllerConditionType = lib.mkOption {
    description = ''
      
      '';
  };
  ReplicationControllerSpec = lib.mkOption {
    description = ''
      ReplicationControllerSpec is the specification of a replication controller.
      '';
    type = submodule {
      options = {
        replicas = mkOption {
          description = ''
            Replicas is the number of desired replicas.
            This is a pointer to distinguish between explicit zero and unspecified.
            Defaults to 1.
            More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#what-is-a-replicationcontroller
            '';
          type = int;
        };
        minReadySeconds = mkOption {
          description = ''
            Minimum number of seconds for which a newly created pod should be ready
            without any of its container crashing, for it to be considered available.
            Defaults to 0 (pod will be considered available as soon as it is ready)
            '';
          type = int;
        };
        selector = mkOption {
          description = ''
            Selector is a label query over pods that should match the Replicas count.
            If Selector is empty, it is defaulted to the labels present on the Pod template.
            Label keys and values that must match in order to be controlled by this replication
            controller, if empty defaulted to labels on Pod template.
            More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
            '';
          type = (attrsOf str);
        };
        template = mkOption {
          description = ''
            Template is the object that describes the pod that will be created if
            insufficient replicas are detected. This takes precedence over a TemplateRef.
            More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#pod-template
            '';
          type = PodTemplateSpec;
        };
      };
    };
  };
  ReplicationControllerStatus = lib.mkOption {
    description = ''
      ReplicationControllerStatus represents the current status of a replication
      controller.
      '';
    type = submodule {
      options = {
        replicas = mkOption {
          description = ''
            Replicas is the most recently observed number of replicas.
            More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#what-is-a-replicationcontroller
            '';
          type = int;
        };
        fullyLabeledReplicas = mkOption {
          description = ''
            The number of pods that have labels matching the labels of the pod template of the replication controller.
            '';
          type = int;
        };
        readyReplicas = mkOption {
          description = ''
            The number of ready replicas for this replication controller.
            '';
          type = int;
        };
        availableReplicas = mkOption {
          description = ''
            The number of available replicas (ready for at least minReadySeconds) for this replication controller.
            '';
          type = int;
        };
        observedGeneration = mkOption {
          description = ''
            ObservedGeneration reflects the generation of the most recently observed replication controller.
            '';
          type = int;
        };
        conditions = mkOption {
          description = ''
            Represents the latest available observations of a replication controller's current state.
            '';
          type = (listOf ReplicationControllerCondition);
        };
      };
    };
  };
  ResourceClaim = lib.mkOption {
    description = ''
      ResourceClaim references one entry in PodSpec.ResourceClaims.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name must match the name of one entry in pod.spec.resourceClaims of
            the Pod where this field is used. It makes that resource available
            inside a container.
            '';
          type = str;
        };
      };
    };
  };
  ResourceFieldSelector = lib.mkOption {
    description = ''
      ResourceFieldSelector represents container resources (cpu, memory) and their output format
      '';
    type = submodule {
      options = {
        containerName = mkOption {
          description = ''
            Container name: required for volumes, optional for env vars
            '';
          type = str;
        };
        resource = mkOption {
          description = ''
            Required: resource to select
            '';
          type = str;
        };
        divisor = mkOption {
          description = ''
            Specifies the output format of the exposed resources, defaults to "1"
            '';
          type = k8s.io/apimachinery/pkg/api/resource.Quantity;
        };
      };
    };
  };
  ResourceList = lib.mkOption {
    description = ''
      ResourceList is a set of (resource name, quantity) pairs.
      '';
  };
  ResourceQuotaScope = lib.mkOption {
    description = ''
      A ResourceQuotaScope defines a filter that must match each object tracked by a quota
      '';
  };
  ResourceQuotaSpec = lib.mkOption {
    description = ''
      ResourceQuotaSpec defines the desired hard limits to enforce for Quota.
      '';
    type = submodule {
      options = {
        hard = mkOption {
          description = ''
            hard is the set of desired hard limits for each named resource.
            More info: https://kubernetes.io/docs/concepts/policy/resource-quotas/
            '';
          type = ResourceList;
        };
        scopes = mkOption {
          description = ''
            A collection of filters that must match each object tracked by a quota.
            If not specified, the quota matches all objects.
            '';
          type = (listOf ResourceQuotaScope);
        };
        scopeSelector = mkOption {
          description = ''
            scopeSelector is also a collection of filters like scopes that must match each object tracked by a quota
            but expressed using ScopeSelectorOperator in combination with possible values.
            For a resource to match, both scopes AND scopeSelector (if specified in spec), must be matched.
            '';
          type = ScopeSelector;
        };
      };
    };
  };
  ResourceQuotaStatus = lib.mkOption {
    description = ''
      ResourceQuotaStatus defines the enforced hard limits and observed use.
      '';
    type = submodule {
      options = {
        hard = mkOption {
          description = ''
            Hard is the set of enforced hard limits for each named resource.
            More info: https://kubernetes.io/docs/concepts/policy/resource-quotas/
            '';
          type = ResourceList;
        };
        used = mkOption {
          description = ''
            Used is the current observed total usage of the resource in the namespace.
            '';
          type = ResourceList;
        };
      };
    };
  };
  ResourceRequirements = lib.mkOption {
    description = ''
      ResourceRequirements describes the compute resource requirements.
      '';
    type = submodule {
      options = {
        limits = mkOption {
          description = ''
            Limits describes the maximum amount of compute resources allowed.
            More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
            '';
          type = ResourceList;
        };
        requests = mkOption {
          description = ''
            Requests describes the minimum amount of compute resources required.
            If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
            otherwise to an implementation-defined value.
            More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
            '';
          type = ResourceList;
        };
        claims = mkOption {
          description = ''
            Claims lists the names of resources, defined in spec.resourceClaims,
            that are used by this container.
            
            This is an alpha field and requires enabling the
            DynamicResourceAllocation feature gate.
            
            This field is immutable.
            
            '';
          type = (listOf ResourceClaim);
        };
      };
    };
  };
  RestartPolicy = lib.mkOption {
    description = ''
      RestartPolicy describes how the container should be restarted.
      Only one of the following restart policies may be specified.
      If none of the following policies is specified, the default one
      is RestartPolicyAlways.
      '';
  };
  SELinuxOptions = lib.mkOption {
    description = ''
      SELinuxOptions are the labels to be applied to the container
      '';
    type = submodule {
      options = {
        user = mkOption {
          description = ''
            User is a SELinux user label that applies to the container.
            '';
          type = str;
        };
        role = mkOption {
          description = ''
            Role is a SELinux role label that applies to the container.
            '';
          type = str;
        };
        type = mkOption {
          description = ''
            Type is a SELinux type label that applies to the container.
            '';
          type = str;
        };
        level = mkOption {
          description = ''
            Level is SELinux level label that applies to the container.
            '';
          type = str;
        };
      };
    };
  };
  ScaleIOPersistentVolumeSource = lib.mkOption {
    description = ''
      ScaleIOPersistentVolumeSource represents a persistent ScaleIO volume
      '';
    type = submodule {
      options = {
        gateway = mkOption {
          description = ''
            gateway is the host address of the ScaleIO API Gateway.
            '';
          type = str;
        };
        system = mkOption {
          description = ''
            system is the name of the storage system as configured in ScaleIO.
            '';
          type = str;
        };
        secretRef = mkOption {
          description = ''
            secretRef references to the secret for ScaleIO user and other
            sensitive information. If this is not provided, Login operation will fail.
            '';
          type = SecretReference;
        };
        sslEnabled = mkOption {
          description = ''
            sslEnabled is the flag to enable/disable SSL communication with Gateway, default false
            '';
          type = bool;
        };
        protectionDomain = mkOption {
          description = ''
            protectionDomain is the name of the ScaleIO Protection Domain for the configured storage.
            '';
          type = str;
        };
        storagePool = mkOption {
          description = ''
            storagePool is the ScaleIO Storage Pool associated with the protection domain.
            '';
          type = str;
        };
        storageMode = mkOption {
          description = ''
            storageMode indicates whether the storage for a volume should be ThickProvisioned or ThinProvisioned.
            Default is ThinProvisioned.
            '';
          type = str;
        };
        volumeName = mkOption {
          description = ''
            volumeName is the name of a volume already created in the ScaleIO system
            that is associated with this volume source.
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs".
            Default is "xfs"
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            '';
          type = bool;
        };
      };
    };
  };
  ScaleIOVolumeSource = lib.mkOption {
    description = ''
      ScaleIOVolumeSource represents a persistent ScaleIO volume
      '';
    type = submodule {
      options = {
        gateway = mkOption {
          description = ''
            gateway is the host address of the ScaleIO API Gateway.
            '';
          type = str;
        };
        system = mkOption {
          description = ''
            system is the name of the storage system as configured in ScaleIO.
            '';
          type = str;
        };
        secretRef = mkOption {
          description = ''
            secretRef references to the secret for ScaleIO user and other
            sensitive information. If this is not provided, Login operation will fail.
            '';
          type = LocalObjectReference;
        };
        sslEnabled = mkOption {
          description = ''
            sslEnabled Flag enable/disable SSL communication with Gateway, default false
            '';
          type = bool;
        };
        protectionDomain = mkOption {
          description = ''
            protectionDomain is the name of the ScaleIO Protection Domain for the configured storage.
            '';
          type = str;
        };
        storagePool = mkOption {
          description = ''
            storagePool is the ScaleIO Storage Pool associated with the protection domain.
            '';
          type = str;
        };
        storageMode = mkOption {
          description = ''
            storageMode indicates whether the storage for a volume should be ThickProvisioned or ThinProvisioned.
            Default is ThinProvisioned.
            '';
          type = str;
        };
        volumeName = mkOption {
          description = ''
            volumeName is the name of a volume already created in the ScaleIO system
            that is associated with this volume source.
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs".
            Default is "xfs".
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly Defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            '';
          type = bool;
        };
      };
    };
  };
  ScopeSelector = lib.mkOption {
    description = ''
      A scope selector represents the AND of the selectors represented
      by the scoped-resource selector requirements.
      '';
    type = submodule {
      options = {
        matchExpressions = mkOption {
          description = ''
            A list of scope selector requirements by scope of the resources.
            '';
          type = (listOf ScopedResourceSelectorRequirement);
        };
      };
    };
  };
  ScopeSelectorOperator = lib.mkOption {
    description = ''
      A scope selector operator is the set of operators that can be used in
      a scope selector requirement.
      '';
  };
  ScopedResourceSelectorRequirement = lib.mkOption {
    description = ''
      A scoped-resource selector requirement is a selector that contains values, a scope name, and an operator
      that relates the scope name and values.
      '';
    type = submodule {
      options = {
        scopeName = mkOption {
          description = ''
            The name of the scope that the selector applies to.
            '';
          type = ResourceQuotaScope;
        };
        operator = mkOption {
          description = ''
            Represents a scope's relationship to a set of values.
            Valid operators are In, NotIn, Exists, DoesNotExist.
            '';
          type = ScopeSelectorOperator;
        };
        values = mkOption {
          description = ''
            An array of string values. If the operator is In or NotIn,
            the values array must be non-empty. If the operator is Exists or DoesNotExist,
            the values array must be empty.
            This array is replaced during a strategic merge patch.
            '';
          type = (listOf str);
        };
      };
    };
  };
  SeccompProfile = lib.mkOption {
    description = ''
      SeccompProfile defines a pod/container's seccomp profile settings.
      Only one profile source may be set.
      '';
    type = submodule {
      options = {
        type = mkOption {
          description = ''
            type indicates which kind of seccomp profile will be applied.
            Valid options are:
            
            Localhost - a profile defined in a file on the node should be used.
            RuntimeDefault - the container runtime default profile should be used.
            Unconfined - no profile should be applied.
            '';
          type = SeccompProfileType;
        };
        localhostProfile = mkOption {
          description = ''
            localhostProfile indicates a profile defined in a file on the node should be used.
            The profile must be preconfigured on the node to work.
            Must be a descending path, relative to the kubelet's configured seccomp profile location.
            Must only be set if type is "Localhost".
            '';
          type = str;
        };
      };
    };
  };
  SeccompProfileType = lib.mkOption {
    description = ''
      SeccompProfileType defines the supported seccomp profile types.
      '';
  };
  SecretEnvSource = lib.mkOption {
    description = ''
      SecretEnvSource selects a Secret to populate the environment
      variables with.
      
      The contents of the target Secret's Data field will represent the
      key-value pairs as environment variables.
      '';
    type = submodule {
      options = {
        LocalObjectReference = mkOption {
          description = ''
            The Secret to select from.
            '';
          type = LocalObjectReference;
        };
        optional = mkOption {
          description = ''
            Specify whether the Secret must be defined
            '';
          type = bool;
        };
      };
    };
  };
  SecretKeySelector = lib.mkOption {
    description = ''
      SecretKeySelector selects a key of a Secret.
      '';
    type = submodule {
      options = {
        LocalObjectReference = mkOption {
          description = ''
            The name of the secret in the pod's namespace to select from.
            '';
          type = LocalObjectReference;
        };
        key = mkOption {
          description = ''
            The key of the secret to select from.  Must be a valid secret key.
            '';
          type = str;
        };
        optional = mkOption {
          description = ''
            Specify whether the Secret or its key must be defined
            '';
          type = bool;
        };
      };
    };
  };
  SecretProjection = lib.mkOption {
    description = ''
      Adapts a secret into a projected volume.
      
      The contents of the target Secret's Data field will be presented in a
      projected volume as files using the keys in the Data field as the file names.
      Note that this is identical to a secret volume source without the default
      mode.
      '';
    type = submodule {
      options = {
        LocalObjectReference = mkOption {
          description = ''
            
            '';
          type = LocalObjectReference;
        };
        items = mkOption {
          description = ''
            items if unspecified, each key-value pair in the Data field of the referenced
            Secret will be projected into the volume as a file whose name is the
            key and content is the value. If specified, the listed keys will be
            projected into the specified paths, and unlisted keys will not be
            present. If a key is specified which is not present in the Secret,
            the volume setup will error unless it is marked optional. Paths must be
            relative and may not contain the '..' path or start with '..'.
            '';
          type = (listOf KeyToPath);
        };
        optional = mkOption {
          description = ''
            optional field specify whether the Secret or its key must be defined
            '';
          type = bool;
        };
      };
    };
  };
  SecretReference = lib.mkOption {
    description = ''
      SecretReference represents a Secret Reference. It has enough information to retrieve secret
      in any namespace
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            name is unique within a namespace to reference a secret resource.
            '';
          type = str;
        };
        namespace = mkOption {
          description = ''
            namespace defines the space within which the secret name must be unique.
            '';
          type = str;
        };
      };
    };
  };
  SecretType = lib.mkOption {
    description = ''
      
      '';
  };
  SecretVolumeSource = lib.mkOption {
    description = ''
      Adapts a Secret into a volume.
      
      The contents of the target Secret's Data field will be presented in a volume
      as files using the keys in the Data field as the file names.
      Secret volumes support ownership management and SELinux relabeling.
      '';
    type = submodule {
      options = {
        secretName = mkOption {
          description = ''
            secretName is the name of the secret in the pod's namespace to use.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#secret
            '';
          type = str;
        };
        items = mkOption {
          description = ''
            items If unspecified, each key-value pair in the Data field of the referenced
            Secret will be projected into the volume as a file whose name is the
            key and content is the value. If specified, the listed keys will be
            projected into the specified paths, and unlisted keys will not be
            present. If a key is specified which is not present in the Secret,
            the volume setup will error unless it is marked optional. Paths must be
            relative and may not contain the '..' path or start with '..'.
            '';
          type = (listOf KeyToPath);
        };
        defaultMode = mkOption {
          description = ''
            defaultMode is Optional: mode bits used to set permissions on created files by default.
            Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
            YAML accepts both octal and decimal values, JSON requires decimal values
            for mode bits. Defaults to 0644.
            Directories within the path are not affected by this setting.
            This might be in conflict with other options that affect the file
            mode, like fsGroup, and the result can be other mode bits set.
            '';
          type = int;
        };
        optional = mkOption {
          description = ''
            optional field specify whether the Secret or its keys must be defined
            '';
          type = bool;
        };
      };
    };
  };
  SecurityContext = lib.mkOption {
    description = ''
      SecurityContext holds security configuration that will be applied to a container.
      Some fields are present in both SecurityContext and PodSecurityContext.  When both
      are set, the values in SecurityContext take precedence.
      '';
    type = submodule {
      options = {
        capabilities = mkOption {
          description = ''
            The capabilities to add/drop when running containers.
            Defaults to the default set of capabilities granted by the container runtime.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = Capabilities;
        };
        privileged = mkOption {
          description = ''
            Run container in privileged mode.
            Processes in privileged containers are essentially equivalent to root on the host.
            Defaults to false.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = bool;
        };
        seLinuxOptions = mkOption {
          description = ''
            The SELinux context to be applied to the container.
            If unspecified, the container runtime will allocate a random SELinux context for each
            container.  May also be set in PodSecurityContext.  If set in both SecurityContext and
            PodSecurityContext, the value specified in SecurityContext takes precedence.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = SELinuxOptions;
        };
        windowsOptions = mkOption {
          description = ''
            The Windows specific settings applied to all containers.
            If unspecified, the options from the PodSecurityContext will be used.
            If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.
            Note that this field cannot be set when spec.os.name is linux.
            '';
          type = WindowsSecurityContextOptions;
        };
        runAsUser = mkOption {
          description = ''
            The UID to run the entrypoint of the container process.
            Defaults to user specified in image metadata if unspecified.
            May also be set in PodSecurityContext.  If set in both SecurityContext and
            PodSecurityContext, the value specified in SecurityContext takes precedence.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = int;
        };
        runAsGroup = mkOption {
          description = ''
            The GID to run the entrypoint of the container process.
            Uses runtime default if unset.
            May also be set in PodSecurityContext.  If set in both SecurityContext and
            PodSecurityContext, the value specified in SecurityContext takes precedence.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = int;
        };
        runAsNonRoot = mkOption {
          description = ''
            Indicates that the container must run as a non-root user.
            If true, the Kubelet will validate the image at runtime to ensure that it
            does not run as UID 0 (root) and fail to start the container if it does.
            If unset or false, no such validation will be performed.
            May also be set in PodSecurityContext.  If set in both SecurityContext and
            PodSecurityContext, the value specified in SecurityContext takes precedence.
            '';
          type = bool;
        };
        readOnlyRootFilesystem = mkOption {
          description = ''
            Whether this container has a read-only root filesystem.
            Default is false.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = bool;
        };
        allowPrivilegeEscalation = mkOption {
          description = ''
            AllowPrivilegeEscalation controls whether a process can gain more
            privileges than its parent process. This bool directly controls if
            the no_new_privs flag will be set on the container process.
            AllowPrivilegeEscalation is true always when the container is:
            1) run as Privileged
            2) has CAP_SYS_ADMIN
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = bool;
        };
        procMount = mkOption {
          description = ''
            procMount denotes the type of proc mount to use for the containers.
            The default is DefaultProcMount which uses the container runtime defaults for
            readonly paths and masked paths.
            This requires the ProcMountType feature flag to be enabled.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = ProcMountType;
        };
        seccompProfile = mkOption {
          description = ''
            The seccomp options to use by this container. If seccomp options are
            provided at both the pod & container level, the container options
            override the pod options.
            Note that this field cannot be set when spec.os.name is windows.
            '';
          type = SeccompProfile;
        };
      };
    };
  };
  ServiceAccountTokenProjection = lib.mkOption {
    description = ''
      ServiceAccountTokenProjection represents a projected service account token
      volume. This projection can be used to insert a service account token into
      the pods runtime filesystem for use against APIs (Kubernetes API Server or
      otherwise).
      '';
    type = submodule {
      options = {
        audience = mkOption {
          description = ''
            audience is the intended audience of the token. A recipient of a token
            must identify itself with an identifier specified in the audience of the
            token, and otherwise should reject the token. The audience defaults to the
            identifier of the apiserver.
            '';
          type = str;
        };
        expirationSeconds = mkOption {
          description = ''
            expirationSeconds is the requested duration of validity of the service
            account token. As the token approaches expiration, the kubelet volume
            plugin will proactively rotate the service account token. The kubelet will
            start trying to rotate the token if the token is older than 80 percent of
            its time to live or if the token is older than 24 hours.Defaults to 1 hour
            and must be at least 10 minutes.
            '';
          type = int;
        };
        path = mkOption {
          description = ''
            path is the path relative to the mount point of the file to project the
            token into.
            '';
          type = str;
        };
      };
    };
  };
  ServiceAffinity = lib.mkOption {
    description = ''
      Session Affinity Type string
      '';
  };
  ServiceExternalTrafficPolicyType = lib.mkOption {
    description = ''
      ServiceExternalTrafficPolicyType describes how nodes distribute service traffic they
      receive on one of the Service's "externally-facing" addresses (NodePorts, ExternalIPs,
      and LoadBalancer IPs).
      '';
  };
  ServiceInternalTrafficPolicyType = lib.mkOption {
    description = ''
      ServiceInternalTrafficPolicyType describes how nodes distribute service traffic they
      receive on the ClusterIP.
      '';
  };
  ServicePort = lib.mkOption {
    description = ''
      ServicePort contains information on service's port.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            The name of this port within the service. This must be a DNS_LABEL.
            All ports within a ServiceSpec must have unique names. When considering
            the endpoints for a Service, this must match the 'name' field in the
            EndpointPort.
            Optional if only one ServicePort is defined on this service.
            '';
          type = str;
        };
        protocol = mkOption {
          description = ''
            The IP protocol for this port. Supports "TCP", "UDP", and "SCTP".
            Default is TCP.
            '';
          type = Protocol;
        };
        appProtocol = mkOption {
          description = ''
            The application protocol for this port.
            This field follows standard Kubernetes label syntax.
            Un-prefixed names are reserved for IANA standard service names (as per
            RFC-6335 and https://www.iana.org/assignments/service-names).
            Non-standard protocols should use prefixed names such as
            mycompany.com/my-custom-protocol.
            '';
          type = str;
        };
        port = mkOption {
          description = ''
            The port that will be exposed by this service.
            '';
          type = int;
        };
        targetPort = mkOption {
          description = ''
            Number or name of the port to access on the pods targeted by the service.
            Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME.
            If this is a string, it will be looked up as a named port in the
            target Pod's container ports. If this is not specified, the value
            of the 'port' field is used (an identity map).
            This field is ignored for services with clusterIP=None, and should be
            omitted or set equal to the 'port' field.
            More info: https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service
            '';
          type = k8s.io/apimachinery/pkg/util/intstr.IntOrString;
        };
        nodePort = mkOption {
          description = ''
            The port on each node on which this service is exposed when type is
            NodePort or LoadBalancer.  Usually assigned by the system. If a value is
            specified, in-range, and not in use it will be used, otherwise the
            operation will fail.  If not specified, a port will be allocated if this
            Service requires one.  If this field is specified when creating a
            Service which does not need it, creation will fail. This field will be
            wiped when updating a Service to no longer need it (e.g. changing type
            from NodePort to ClusterIP).
            More info: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
            '';
          type = int;
        };
      };
    };
  };
  ServiceSpec = lib.mkOption {
    description = ''
      ServiceSpec describes the attributes that a user creates on a service.
      '';
    type = submodule {
      options = {
        ports = mkOption {
          description = ''
            The list of ports that are exposed by this service.
            More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
            '';
          type = (listOf ServicePort);
        };
        selector = mkOption {
          description = ''
            Route service traffic to pods with label keys and values matching this
            selector. If empty or not present, the service is assumed to have an
            external process managing its endpoints, which Kubernetes will not
            modify. Only applies to types ClusterIP, NodePort, and LoadBalancer.
            Ignored if type is ExternalName.
            More info: https://kubernetes.io/docs/concepts/services-networking/service/
            '';
          type = (attrsOf str);
        };
        clusterIP = mkOption {
          description = ''
            clusterIP is the IP address of the service and is usually assigned
            randomly. If an address is specified manually, is in-range (as per
            system configuration), and is not in use, it will be allocated to the
            service; otherwise creation of the service will fail. This field may not
            be changed through updates unless the type field is also being changed
            to ExternalName (which requires this field to be blank) or the type
            field is being changed from ExternalName (in which case this field may
            optionally be specified, as describe above).  Valid values are "None",
            empty string (""), or a valid IP address. Setting this to "None" makes a
            "headless service" (no virtual IP), which is useful when direct endpoint
            connections are preferred and proxying is not required.  Only applies to
            types ClusterIP, NodePort, and LoadBalancer. If this field is specified
            when creating a Service of type ExternalName, creation will fail. This
            field will be wiped when updating a Service to type ExternalName.
            More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
            '';
          type = str;
        };
        clusterIPs = mkOption {
          description = ''
            ClusterIPs is a list of IP addresses assigned to this service, and are
            usually assigned randomly.  If an address is specified manually, is
            in-range (as per system configuration), and is not in use, it will be
            allocated to the service; otherwise creation of the service will fail.
            This field may not be changed through updates unless the type field is
            also being changed to ExternalName (which requires this field to be
            empty) or the type field is being changed from ExternalName (in which
            case this field may optionally be specified, as describe above).  Valid
            values are "None", empty string (""), or a valid IP address.  Setting
            this to "None" makes a "headless service" (no virtual IP), which is
            useful when direct endpoint connections are preferred and proxying is
            not required.  Only applies to types ClusterIP, NodePort, and
            LoadBalancer. If this field is specified when creating a Service of type
            ExternalName, creation will fail. This field will be wiped when updating
            a Service to type ExternalName.  If this field is not specified, it will
            be initialized from the clusterIP field.  If this field is specified,
            clients must ensure that clusterIPs[0] and clusterIP have the same
            value.
            
            This field may hold a maximum of two entries (dual-stack IPs, in either order).
            These IPs must correspond to the values of the ipFamilies field. Both
            clusterIPs and ipFamilies are governed by the ipFamilyPolicy field.
            More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
            '';
          type = (listOf str);
        };
        type = mkOption {
          description = ''
            type determines how the Service is exposed. Defaults to ClusterIP. Valid
            options are ExternalName, ClusterIP, NodePort, and LoadBalancer.
            "ClusterIP" allocates a cluster-internal IP address for load-balancing
            to endpoints. Endpoints are determined by the selector or if that is not
            specified, by manual construction of an Endpoints object or
            EndpointSlice objects. If clusterIP is "None", no virtual IP is
            allocated and the endpoints are published as a set of endpoints rather
            than a virtual IP.
            "NodePort" builds on ClusterIP and allocates a port on every node which
            routes to the same endpoints as the clusterIP.
            "LoadBalancer" builds on NodePort and creates an external load-balancer
            (if supported in the current cloud) which routes to the same endpoints
            as the clusterIP.
            "ExternalName" aliases this service to the specified externalName.
            Several other fields do not apply to ExternalName services.
            More info: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
            '';
          type = ServiceType;
        };
        externalIPs = mkOption {
          description = ''
            externalIPs is a list of IP addresses for which nodes in the cluster
            will also accept traffic for this service.  These IPs are not managed by
            Kubernetes.  The user is responsible for ensuring that traffic arrives
            at a node with this IP.  A common example is external load-balancers
            that are not part of the Kubernetes system.
            '';
          type = (listOf str);
        };
        sessionAffinity = mkOption {
          description = ''
            Supports "ClientIP" and "None". Used to maintain session affinity.
            Enable client IP based session affinity.
            Must be ClientIP or None.
            Defaults to None.
            More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
            '';
          type = ServiceAffinity;
        };
        loadBalancerIP = mkOption {
          description = ''
            Only applies to Service Type: LoadBalancer.
            This feature depends on whether the underlying cloud-provider supports specifying
            the loadBalancerIP when a load balancer is created.
            This field will be ignored if the cloud-provider does not support the feature.
            Deprecated: This field was under-specified and its meaning varies across implementations,
            and it cannot support dual-stack.
            As of Kubernetes v1.24, users are encouraged to use implementation-specific annotations when available.
            This field may be removed in a future API version.
            '';
          type = str;
        };
        loadBalancerSourceRanges = mkOption {
          description = ''
            If specified and supported by the platform, this will restrict traffic through the cloud-provider
            load-balancer will be restricted to the specified client IPs. This field will be ignored if the
            cloud-provider does not support the feature."
            More info: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/
            '';
          type = (listOf str);
        };
        externalName = mkOption {
          description = ''
            externalName is the external reference that discovery mechanisms will
            return as an alias for this service (e.g. a DNS CNAME record). No
            proxying will be involved.  Must be a lowercase RFC-1123 hostname
            (https://tools.ietf.org/html/rfc1123) and requires `type` to be "ExternalName".
            '';
          type = str;
        };
        externalTrafficPolicy = mkOption {
          description = ''
            externalTrafficPolicy describes how nodes distribute service traffic they
            receive on one of the Service's "externally-facing" addresses (NodePorts,
            ExternalIPs, and LoadBalancer IPs). If set to "Local", the proxy will configure
            the service in a way that assumes that external load balancers will take care
            of balancing the service traffic between nodes, and so each node will deliver
            traffic only to the node-local endpoints of the service, without masquerading
            the client source IP. (Traffic mistakenly sent to a node with no endpoints will
            be dropped.) The default value, "Cluster", uses the standard behavior of
            routing to all endpoints evenly (possibly modified by topology and other
            features). Note that traffic sent to an External IP or LoadBalancer IP from
            within the cluster will always get "Cluster" semantics, but clients sending to
            a NodePort from within the cluster may need to take traffic policy into account
            when picking a node.
            '';
          type = ServiceExternalTrafficPolicyType;
        };
        healthCheckNodePort = mkOption {
          description = ''
            healthCheckNodePort specifies the healthcheck nodePort for the service.
            This only applies when type is set to LoadBalancer and
            externalTrafficPolicy is set to Local. If a value is specified, is
            in-range, and is not in use, it will be used.  If not specified, a value
            will be automatically allocated.  External systems (e.g. load-balancers)
            can use this port to determine if a given node holds endpoints for this
            service or not.  If this field is specified when creating a Service
            which does not need it, creation will fail. This field will be wiped
            when updating a Service to no longer need it (e.g. changing type).
            This field cannot be updated once set.
            '';
          type = int;
        };
        publishNotReadyAddresses = mkOption {
          description = ''
            publishNotReadyAddresses indicates that any agent which deals with endpoints for this
            Service should disregard any indications of ready/not-ready.
            The primary use case for setting this field is for a StatefulSet's Headless Service to
            propagate SRV DNS records for its Pods for the purpose of peer discovery.
            The Kubernetes controllers that generate Endpoints and EndpointSlice resources for
            Services interpret this to mean that all endpoints are considered "ready" even if the
            Pods themselves are not. Agents which consume only Kubernetes generated endpoints
            through the Endpoints or EndpointSlice resources can safely assume this behavior.
            '';
          type = bool;
        };
        sessionAffinityConfig = mkOption {
          description = ''
            sessionAffinityConfig contains the configurations of session affinity.
            '';
          type = SessionAffinityConfig;
        };
        ipFamilies = mkOption {
          description = ''
            IPFamilies is a list of IP families (e.g. IPv4, IPv6) assigned to this
            service. This field is usually assigned automatically based on cluster
            configuration and the ipFamilyPolicy field. If this field is specified
            manually, the requested family is available in the cluster,
            and ipFamilyPolicy allows it, it will be used; otherwise creation of
            the service will fail. This field is conditionally mutable: it allows
            for adding or removing a secondary IP family, but it does not allow
            changing the primary IP family of the Service. Valid values are "IPv4"
            and "IPv6".  This field only applies to Services of types ClusterIP,
            NodePort, and LoadBalancer, and does apply to "headless" services.
            This field will be wiped when updating a Service to type ExternalName.
            
            This field may hold a maximum of two entries (dual-stack families, in
            either order).  These families must correspond to the values of the
            clusterIPs field, if specified. Both clusterIPs and ipFamilies are
            governed by the ipFamilyPolicy field.
            '';
          type = (listOf IPFamily);
        };
        ipFamilyPolicy = mkOption {
          description = ''
            IPFamilyPolicy represents the dual-stack-ness requested or required by
            this Service. If there is no value provided, then this field will be set
            to SingleStack. Services can be "SingleStack" (a single IP family),
            "PreferDualStack" (two IP families on dual-stack configured clusters or
            a single IP family on single-stack clusters), or "RequireDualStack"
            (two IP families on dual-stack configured clusters, otherwise fail). The
            ipFamilies and clusterIPs fields depend on the value of this field. This
            field will be wiped when updating a service to type ExternalName.
            '';
          type = IPFamilyPolicy;
        };
        allocateLoadBalancerNodePorts = mkOption {
          description = ''
            allocateLoadBalancerNodePorts defines if NodePorts will be automatically
            allocated for services with type LoadBalancer.  Default is "true". It
            may be set to "false" if the cluster load-balancer does not rely on
            NodePorts.  If the caller requests specific NodePorts (by specifying a
            value), those requests will be respected, regardless of this field.
            This field may only be set for services with type LoadBalancer and will
            be cleared if the type is changed to any other type.
            '';
          type = bool;
        };
        loadBalancerClass = mkOption {
          description = ''
            loadBalancerClass is the class of the load balancer implementation this Service belongs to.
            If specified, the value of this field must be a label-style identifier, with an optional prefix,
            e.g. "internal-vip" or "example.com/internal-vip". Unprefixed names are reserved for end-users.
            This field can only be set when the Service type is 'LoadBalancer'. If not set, the default load
            balancer implementation is used, today this is typically done through the cloud provider integration,
            but should apply for any default implementation. If set, it is assumed that a load balancer
            implementation is watching for Services with a matching class. Any default load balancer
            implementation (e.g. cloud providers) should ignore Services that set this field.
            This field can only be set when creating or updating a Service to type 'LoadBalancer'.
            Once set, it can not be changed. This field will be wiped when a service is updated to a non 'LoadBalancer' type.
            '';
          type = str;
        };
        internalTrafficPolicy = mkOption {
          description = ''
            InternalTrafficPolicy describes how nodes distribute service traffic they
            receive on the ClusterIP. If set to "Local", the proxy will assume that pods
            only want to talk to endpoints of the service on the same node as the pod,
            dropping the traffic if there are no local endpoints. The default value,
            "Cluster", uses the standard behavior of routing to all endpoints evenly
            (possibly modified by topology and other features).
            '';
          type = ServiceInternalTrafficPolicyType;
        };
      };
    };
  };
  ServiceStatus = lib.mkOption {
    description = ''
      ServiceStatus represents the current status of a service.
      '';
    type = submodule {
      options = {
        loadBalancer = mkOption {
          description = ''
            LoadBalancer contains the current status of the load-balancer,
            if one is present.
            '';
          type = LoadBalancerStatus;
        };
        conditions = mkOption {
          description = ''
            Current service state
            '';
          type = (listOf meta/v1.Condition);
        };
      };
    };
  };
  ServiceType = lib.mkOption {
    description = ''
      Service Type string describes ingress methods for a service
      '';
  };
  SessionAffinityConfig = lib.mkOption {
    description = ''
      SessionAffinityConfig represents the configurations of session affinity.
      '';
    type = submodule {
      options = {
        clientIP = mkOption {
          description = ''
            clientIP contains the configurations of Client IP based session affinity.
            '';
          type = ClientIPConfig;
        };
      };
    };
  };
  StorageMedium = lib.mkOption {
    description = ''
      StorageMedium defines ways that storage can be allocated to a volume.
      '';
  };
  StorageOSPersistentVolumeSource = lib.mkOption {
    description = ''
      Represents a StorageOS persistent volume resource.
      '';
    type = submodule {
      options = {
        volumeName = mkOption {
          description = ''
            volumeName is the human-readable name of the StorageOS volume.  Volume
            names are only unique within a namespace.
            '';
          type = str;
        };
        volumeNamespace = mkOption {
          description = ''
            volumeNamespace specifies the scope of the volume within StorageOS.  If no
            namespace is specified then the Pod's namespace will be used.  This allows the
            Kubernetes name scoping to be mirrored within StorageOS for tighter integration.
            Set VolumeName to any name to override the default behaviour.
            Set to "default" if you are not using namespaces within StorageOS.
            Namespaces that do not pre-exist within StorageOS will be created.
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            '';
          type = bool;
        };
        secretRef = mkOption {
          description = ''
            secretRef specifies the secret to use for obtaining the StorageOS API
            credentials.  If not specified, default values will be attempted.
            '';
          type = ObjectReference;
        };
      };
    };
  };
  StorageOSVolumeSource = lib.mkOption {
    description = ''
      Represents a StorageOS persistent volume resource.
      '';
    type = submodule {
      options = {
        volumeName = mkOption {
          description = ''
            volumeName is the human-readable name of the StorageOS volume.  Volume
            names are only unique within a namespace.
            '';
          type = str;
        };
        volumeNamespace = mkOption {
          description = ''
            volumeNamespace specifies the scope of the volume within StorageOS.  If no
            namespace is specified then the Pod's namespace will be used.  This allows the
            Kubernetes name scoping to be mirrored within StorageOS for tighter integration.
            Set VolumeName to any name to override the default behaviour.
            Set to "default" if you are not using namespaces within StorageOS.
            Namespaces that do not pre-exist within StorageOS will be created.
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is the filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            readOnly defaults to false (read/write). ReadOnly here will force
            the ReadOnly setting in VolumeMounts.
            '';
          type = bool;
        };
        secretRef = mkOption {
          description = ''
            secretRef specifies the secret to use for obtaining the StorageOS API
            credentials.  If not specified, default values will be attempted.
            '';
          type = LocalObjectReference;
        };
      };
    };
  };
  Sysctl = lib.mkOption {
    description = ''
      Sysctl defines a kernel parameter to be set
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name of a property to set
            '';
          type = str;
        };
        value = mkOption {
          description = ''
            Value of a property to set
            '';
          type = str;
        };
      };
    };
  };
  TCPSocketAction = lib.mkOption {
    description = ''
      TCPSocketAction describes an action based on opening a socket
      '';
    type = submodule {
      options = {
        port = mkOption {
          description = ''
            Number or name of the port to access on the container.
            Number must be in the range 1 to 65535.
            Name must be an IANA_SVC_NAME.
            '';
          type = k8s.io/apimachinery/pkg/util/intstr.IntOrString;
        };
        host = mkOption {
          description = ''
            Optional: Host name to connect to, defaults to the pod IP.
            '';
          type = str;
        };
      };
    };
  };
  Taint = lib.mkOption {
    description = ''
      The node this Taint is attached to has the "effect" on
      any pod that does not tolerate the Taint.
      '';
    type = submodule {
      options = {
        key = mkOption {
          description = ''
            Required. The taint key to be applied to a node.
            '';
          type = str;
        };
        value = mkOption {
          description = ''
            The taint value corresponding to the taint key.
            '';
          type = str;
        };
        effect = mkOption {
          description = ''
            Required. The effect of the taint on pods
            that do not tolerate the taint.
            Valid effects are NoSchedule, PreferNoSchedule and NoExecute.
            '';
          type = TaintEffect;
        };
        timeAdded = mkOption {
          description = ''
            TimeAdded represents the time at which the taint was added.
            It is only written for NoExecute taints.
            '';
          type = meta/v1.Time;
        };
      };
    };
  };
  TaintEffect = lib.mkOption {
    description = ''

      '';
  };
  TerminationMessagePolicy = lib.mkOption {
    description = ''
      TerminationMessagePolicy describes how termination messages are retrieved from a container.
      '';
  };
  Toleration = lib.mkOption {
    description = ''
      The pod this Toleration is attached to tolerates any taint that matches
      the triple <key,value,effect> using the matching operator <operator>.
      '';
    type = submodule {
      options = {
        key = mkOption {
          description = ''
            Key is the taint key that the toleration applies to. Empty means match all taint keys.
            If the key is empty, operator must be Exists; this combination means to match all values and all keys.
            '';
          type = str;
        };
        operator = mkOption {
          description = ''
            Operator represents a key's relationship to the value.
            Valid operators are Exists and Equal. Defaults to Equal.
            Exists is equivalent to wildcard for value, so that a pod can
            tolerate all taints of a particular category.
            '';
          type = TolerationOperator;
        };
        value = mkOption {
          description = ''
            Value is the taint value the toleration matches to.
            If the operator is Exists, the value should be empty, otherwise just a regular string.
            '';
          type = str;
        };
        effect = mkOption {
          description = ''
            Effect indicates the taint effect to match. Empty means match all taint effects.
            When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.
            '';
          type = TaintEffect;
        };
        tolerationSeconds = mkOption {
          description = ''
            TolerationSeconds represents the period of time the toleration (which must be
            of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
            it is not set, which means tolerate the taint forever (do not evict). Zero and
            negative values will be treated as 0 (evict immediately) by the system.
            '';
          type = int;
        };
      };
    };
  };
  TolerationOperator = lib.mkOption {
    description = ''
      A toleration operator is the set of operators that can be used in a toleration.
      '';
  };
  TopologySelectorLabelRequirement = lib.mkOption {
    description = ''
      A topology selector requirement is a selector that matches given label.
      This is an alpha feature and may change in the future.
      '';
    type = submodule {
      options = {
        key = mkOption {
          description = ''
            The label key that the selector applies to.
            '';
          type = str;
        };
        values = mkOption {
          description = ''
            An array of string values. One value must match the label to be selected.
            Each entry in Values is ORed.
            '';
          type = (listOf str);
        };
      };
    };
  };
  TopologySpreadConstraint = lib.mkOption {
    description = ''
      TopologySpreadConstraint specifies how to spread matching pods among the given topology.
      '';
    type = submodule {
      options = {
        maxSkew = mkOption {
          description = ''
            MaxSkew describes the degree to which pods may be unevenly distributed.
            When `whenUnsatisfiable=DoNotSchedule`, it is the maximum permitted difference
            between the number of matching pods in the target topology and the global minimum.
            The global minimum is the minimum number of matching pods in an eligible domain
            or zero if the number of eligible domains is less than MinDomains.
            For example, in a 3-zone cluster, MaxSkew is set to 1, and pods with the same
            labelSelector spread as 2/2/1:
            In this case, the global minimum is 1.
            | zone1 | zone2 | zone3 |
            |  P P  |  P P  |   P   |
            - if MaxSkew is 1, incoming pod can only be scheduled to zone3 to become 2/2/2;
            scheduling it onto zone1(zone2) would make the ActualSkew(3-1) on zone1(zone2)
            violate MaxSkew(1).
            - if MaxSkew is 2, incoming pod can be scheduled onto any zone.
            When `whenUnsatisfiable=ScheduleAnyway`, it is used to give higher precedence
            to topologies that satisfy it.
            It's a required field. Default value is 1 and 0 is not allowed.
            '';
          type = int;
        };
        topologyKey = mkOption {
          description = ''
            TopologyKey is the key of node labels. Nodes that have a label with this key
            and identical values are considered to be in the same topology.
            We consider each <key, value> as a "bucket", and try to put balanced number
            of pods into each bucket.
            We define a domain as a particular instance of a topology.
            Also, we define an eligible domain as a domain whose nodes meet the requirements of
            nodeAffinityPolicy and nodeTaintsPolicy.
            e.g. If TopologyKey is "kubernetes.io/hostname", each Node is a domain of that topology.
            And, if TopologyKey is "topology.kubernetes.io/zone", each zone is a domain of that topology.
            It's a required field.
            '';
          type = str;
        };
        whenUnsatisfiable = mkOption {
          description = ''
            WhenUnsatisfiable indicates how to deal with a pod if it doesn't satisfy
            the spread constraint.
            - DoNotSchedule (default) tells the scheduler not to schedule it.
            - ScheduleAnyway tells the scheduler to schedule the pod in any location,
              but giving higher precedence to topologies that would help reduce the
              skew.
            A constraint is considered "Unsatisfiable" for an incoming pod
            if and only if every possible node assignment for that pod would violate
            "MaxSkew" on some topology.
            For example, in a 3-zone cluster, MaxSkew is set to 1, and pods with the same
            labelSelector spread as 3/1/1:
            | zone1 | zone2 | zone3 |
            | P P P |   P   |   P   |
            If WhenUnsatisfiable is set to DoNotSchedule, incoming pod can only be scheduled
            to zone2(zone3) to become 3/2/1(3/1/2) as ActualSkew(2-1) on zone2(zone3) satisfies
            MaxSkew(1). In other words, the cluster can still be imbalanced, but scheduler
            won't make it *more* imbalanced.
            It's a required field.
            '';
          type = UnsatisfiableConstraintAction;
        };
        labelSelector = mkOption {
          description = ''
            LabelSelector is used to find matching pods.
            Pods that match this label selector are counted to determine the number of pods
            in their corresponding topology domain.
            '';
          type = meta/v1.LabelSelector;
        };
        minDomains = mkOption {
          description = ''
            MinDomains indicates a minimum number of eligible domains.
            When the number of eligible domains with matching topology keys is less than minDomains,
            Pod Topology Spread treats "global minimum" as 0, and then the calculation of Skew is performed.
            And when the number of eligible domains with matching topology keys equals or greater than minDomains,
            this value has no effect on scheduling.
            As a result, when the number of eligible domains is less than minDomains,
            scheduler won't schedule more than maxSkew Pods to those domains.
            If value is nil, the constraint behaves as if MinDomains is equal to 1.
            Valid values are integers greater than 0.
            When value is not nil, WhenUnsatisfiable must be DoNotSchedule.
            
            For example, in a 3-zone cluster, MaxSkew is set to 2, MinDomains is set to 5 and pods with the same
            labelSelector spread as 2/2/2:
            | zone1 | zone2 | zone3 |
            |  P P  |  P P  |  P P  |
            The number of domains is less than 5(MinDomains), so "global minimum" is treated as 0.
            In this situation, new pod with the same labelSelector cannot be scheduled,
            because computed skew will be 3(3 - 0) if new Pod is scheduled to any of the three zones,
            it will violate MaxSkew.
            
            This is a beta field and requires the MinDomainsInPodTopologySpread feature gate to be enabled (enabled by default).
            '';
          type = int;
        };
        nodeAffinityPolicy = mkOption {
          description = ''
            NodeAffinityPolicy indicates how we will treat Pod's nodeAffinity/nodeSelector
            when calculating pod topology spread skew. Options are:
            - Honor: only nodes matching nodeAffinity/nodeSelector are included in the calculations.
            - Ignore: nodeAffinity/nodeSelector are ignored. All nodes are included in the calculations.
            
            If this value is nil, the behavior is equivalent to the Honor policy.
            This is a beta-level feature default enabled by the NodeInclusionPolicyInPodTopologySpread feature flag.
            '';
          type = NodeInclusionPolicy;
        };
        nodeTaintsPolicy = mkOption {
          description = ''
            NodeTaintsPolicy indicates how we will treat node taints when calculating
            pod topology spread skew. Options are:
            - Honor: nodes without taints, along with tainted nodes for which the incoming pod
            has a toleration, are included.
            - Ignore: node taints are ignored. All nodes are included.
            
            If this value is nil, the behavior is equivalent to the Ignore policy.
            This is a beta-level feature default enabled by the NodeInclusionPolicyInPodTopologySpread feature flag.
            '';
          type = NodeInclusionPolicy;
        };
        matchLabelKeys = mkOption {
          description = ''
            MatchLabelKeys is a set of pod label keys to select the pods over which
            spreading will be calculated. The keys are used to lookup values from the
            incoming pod labels, those key-value labels are ANDed with labelSelector
            to select the group of existing pods over which spreading will be calculated
            for the incoming pod. Keys that don't exist in the incoming pod labels will
            be ignored. A null or empty list means only match against labelSelector.
            '';
          type = (listOf str);
        };
      };
    };
  };
  TypedLocalObjectReference = lib.mkOption {
    description = ''
      TypedLocalObjectReference contains enough information to let you locate the
      typed referenced object inside the same namespace.
      '';
    type = submodule {
      options = {
        apiGroup = mkOption {
          description = ''
            APIGroup is the group for the resource being referenced.
            If APIGroup is not specified, the specified Kind must be in the core API group.
            For any other third-party types, APIGroup is required.
            '';
          type = str;
        };
        kind = mkOption {
          description = ''
            Kind is the type of resource being referenced
            '';
          type = str;
        };
        name = mkOption {
          description = ''
            Name is the name of resource being referenced
            '';
          type = str;
        };
      };
    };
  };
  TypedObjectReference = lib.mkOption {
    description = ''
      
      '';
    type = submodule {
      options = {
        apiGroup = mkOption {
          description = ''
            APIGroup is the group for the resource being referenced.
            If APIGroup is not specified, the specified Kind must be in the core API group.
            For any other third-party types, APIGroup is required.
            '';
          type = str;
        };
        kind = mkOption {
          description = ''
            Kind is the type of resource being referenced
            '';
          type = str;
        };
        name = mkOption {
          description = ''
            Name is the name of resource being referenced
            '';
          type = str;
        };
        namespace = mkOption {
          description = ''
            Namespace is the namespace of resource being referenced
            Note that when a namespace is specified, a gateway.networking.k8s.io/ReferenceGrant object is required in the referent namespace to allow that namespace's owner to accept the reference. See the ReferenceGrant documentation for details.
            (Alpha) This field requires the CrossNamespaceVolumeDataSource feature gate to be enabled.
            '';
          type = str;
        };
      };
    };
  };
  URIScheme = lib.mkOption {
    description = ''
      URIScheme identifies the scheme used for connection to a host for Get actions
      '';
  };
  UniqueVolumeName = lib.mkOption {
    description = ''
      
      '';
  };
  UnsatisfiableConstraintAction = lib.mkOption {
    description = ''

      '';
  };
  Volume = lib.mkOption {
    description = ''
      Volume represents a named volume in a pod that may be accessed by any container in the pod.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            name of the volume.
            Must be a DNS_LABEL and unique within the pod.
            More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
            '';
          type = str;
        };
        VolumeSource = mkOption {
          description = ''
            volumeSource represents the location and type of the mounted volume.
            If not specified, the Volume is implied to be an EmptyDir.
            This implied behavior is deprecated and will be removed in a future version.
            '';
          type = VolumeSource;
        };
      };
    };
  };
  VolumeDevice = lib.mkOption {
    description = ''
      volumeDevice describes a mapping of a raw block device within a container.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            name must match the name of a persistentVolumeClaim in the pod
            '';
          type = str;
        };
        devicePath = mkOption {
          description = ''
            devicePath is the path inside of the container that the device will be mapped to.
            '';
          type = str;
        };
      };
    };
  };
  VolumeMount = lib.mkOption {
    description = ''
      VolumeMount describes a mounting of a Volume within a container.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            This must match the Name of a Volume.
            '';
          type = str;
        };
        readOnly = mkOption {
          description = ''
            Mounted read-only if true, read-write otherwise (false or unspecified).
            Defaults to false.
            '';
          type = bool;
        };
        mountPath = mkOption {
          description = ''
            Path within the container at which the volume should be mounted.  Must
            not contain ':'.
            '';
          type = str;
        };
        subPath = mkOption {
          description = ''
            Path within the volume from which the container's volume should be mounted.
            Defaults to "" (volume's root).
            '';
          type = str;
        };
        mountPropagation = mkOption {
          description = ''
            mountPropagation determines how mounts are propagated from the host
            to container and the other way around.
            When not set, MountPropagationNone is used.
            This field is beta in 1.10.
            '';
          type = MountPropagationMode;
        };
        subPathExpr = mkOption {
          description = ''
            Expanded path within the volume from which the container's volume should be mounted.
            Behaves similarly to SubPath but environment variable references $(VAR_NAME) are expanded using the container's environment.
            Defaults to "" (volume's root).
            SubPathExpr and SubPath are mutually exclusive.
            '';
          type = str;
        };
      };
    };
  };
  VolumeNodeAffinity = lib.mkOption {
    description = ''
      VolumeNodeAffinity defines constraints that limit what nodes this volume can be accessed from.
      '';
    type = submodule {
      options = {
        required = mkOption {
          description = ''
            required specifies hard node constraints that must be met.
            '';
          type = NodeSelector;
        };
      };
    };
  };
  VolumeProjection = lib.mkOption {
    description = ''
      Projection that may be projected along with other supported volume types
      '';
    type = submodule {
      options = {
        secret = mkOption {
          description = ''
            secret information about the secret data to project
            '';
          type = SecretProjection;
        };
        downwardAPI = mkOption {
          description = ''
            downwardAPI information about the downwardAPI data to project
            '';
          type = DownwardAPIProjection;
        };
        configMap = mkOption {
          description = ''
            configMap information about the configMap data to project
            '';
          type = ConfigMapProjection;
        };
        serviceAccountToken = mkOption {
          description = ''
            serviceAccountToken is information about the serviceAccountToken data to project
            '';
          type = ServiceAccountTokenProjection;
        };
      };
    };
  };
  VolumeSource = lib.mkOption {
    description = ''
      Represents the source of a volume to mount.
      Only one of its members may be specified.
      '';
    type = submodule {
      options = {
        hostPath = mkOption {
          description = ''
            hostPath represents a pre-existing file or directory on the host
            machine that is directly exposed to the container. This is generally
            used for system agents or other privileged things that are allowed
            to see the host machine. Most containers will NOT need this.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath
            ---
            TODO(jonesdl) We need to restrict who can use host directory mounts and who can/can not
            mount host directories as read/write.
            '';
          type = HostPathVolumeSource;
        };
        emptyDir = mkOption {
          description = ''
            emptyDir represents a temporary directory that shares a pod's lifetime.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir
            '';
          type = EmptyDirVolumeSource;
        };
        gcePersistentDisk = mkOption {
          description = ''
            gcePersistentDisk represents a GCE Disk resource that is attached to a
            kubelet's host machine and then exposed to the pod.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
            '';
          type = GCEPersistentDiskVolumeSource;
        };
        awsElasticBlockStore = mkOption {
          description = ''
            awsElasticBlockStore represents an AWS Disk resource that is attached to a
            kubelet's host machine and then exposed to the pod.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
            '';
          type = AWSElasticBlockStoreVolumeSource;
        };
        gitRepo = mkOption {
          description = ''
            gitRepo represents a git repository at a particular revision.
            DEPRECATED: GitRepo is deprecated. To provision a container with a git repo, mount an
            EmptyDir into an InitContainer that clones the repo using git, then mount the EmptyDir
            into the Pod's container.
            '';
          type = GitRepoVolumeSource;
        };
        secret = mkOption {
          description = ''
            secret represents a secret that should populate this volume.
            More info: https://kubernetes.io/docs/concepts/storage/volumes#secret
            '';
          type = SecretVolumeSource;
        };
        nfs = mkOption {
          description = ''
            nfs represents an NFS mount on the host that shares a pod's lifetime
            More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
            '';
          type = NFSVolumeSource;
        };
        iscsi = mkOption {
          description = ''
            iscsi represents an ISCSI Disk resource that is attached to a
            kubelet's host machine and then exposed to the pod.
            More info: https://examples.k8s.io/volumes/iscsi/README.md
            '';
          type = ISCSIVolumeSource;
        };
        glusterfs = mkOption {
          description = ''
            glusterfs represents a Glusterfs mount on the host that shares a pod's lifetime.
            More info: https://examples.k8s.io/volumes/glusterfs/README.md
            '';
          type = GlusterfsVolumeSource;
        };
        persistentVolumeClaim = mkOption {
          description = ''
            persistentVolumeClaimVolumeSource represents a reference to a
            PersistentVolumeClaim in the same namespace.
            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
            '';
          type = PersistentVolumeClaimVolumeSource;
        };
        rbd = mkOption {
          description = ''
            rbd represents a Rados Block Device mount on the host that shares a pod's lifetime.
            More info: https://examples.k8s.io/volumes/rbd/README.md
            '';
          type = RBDVolumeSource;
        };
        flexVolume = mkOption {
          description = ''
            flexVolume represents a generic volume resource that is
            provisioned/attached using an exec based plugin.
            '';
          type = FlexVolumeSource;
        };
        cinder = mkOption {
          description = ''
            cinder represents a cinder volume attached and mounted on kubelets host machine.
            More info: https://examples.k8s.io/mysql-cinder-pd/README.md
            '';
          type = CinderVolumeSource;
        };
        cephfs = mkOption {
          description = ''
            cephFS represents a Ceph FS mount on the host that shares a pod's lifetime
            '';
          type = CephFSVolumeSource;
        };
        flocker = mkOption {
          description = ''
            flocker represents a Flocker volume attached to a kubelet's host machine. This depends on the Flocker control service being running
            '';
          type = FlockerVolumeSource;
        };
        downwardAPI = mkOption {
          description = ''
            downwardAPI represents downward API about the pod that should populate this volume
            '';
          type = DownwardAPIVolumeSource;
        };
        fc = mkOption {
          description = ''
            fc represents a Fibre Channel resource that is attached to a kubelet's host machine and then exposed to the pod.
            '';
          type = FCVolumeSource;
        };
        azureFile = mkOption {
          description = ''
            azureFile represents an Azure File Service mount on the host and bind mount to the pod.
            '';
          type = AzureFileVolumeSource;
        };
        configMap = mkOption {
          description = ''
            configMap represents a configMap that should populate this volume
            '';
          type = ConfigMapVolumeSource;
        };
        vsphereVolume = mkOption {
          description = ''
            vsphereVolume represents a vSphere volume attached and mounted on kubelets host machine
            '';
          type = VsphereVirtualDiskVolumeSource;
        };
        quobyte = mkOption {
          description = ''
            quobyte represents a Quobyte mount on the host that shares a pod's lifetime
            '';
          type = QuobyteVolumeSource;
        };
        azureDisk = mkOption {
          description = ''
            azureDisk represents an Azure Data Disk mount on the host and bind mount to the pod.
            '';
          type = AzureDiskVolumeSource;
        };
        photonPersistentDisk = mkOption {
          description = ''
            photonPersistentDisk represents a PhotonController persistent disk attached and mounted on kubelets host machine
            '';
          type = PhotonPersistentDiskVolumeSource;
        };
        projected = mkOption {
          description = ''
            projected items for all in one resources secrets, configmaps, and downward API
            '';
          type = ProjectedVolumeSource;
        };
        portworxVolume = mkOption {
          description = ''
            portworxVolume represents a portworx volume attached and mounted on kubelets host machine
            '';
          type = PortworxVolumeSource;
        };
        scaleIO = mkOption {
          description = ''
            scaleIO represents a ScaleIO persistent volume attached and mounted on Kubernetes nodes.
            '';
          type = ScaleIOVolumeSource;
        };
        storageos = mkOption {
          description = ''
            storageOS represents a StorageOS volume attached and mounted on Kubernetes nodes.
            '';
          type = StorageOSVolumeSource;
        };
        csi = mkOption {
          description = ''
            csi (Container Storage Interface) represents ephemeral storage that is handled by certain external CSI drivers (Beta feature).
            '';
          type = CSIVolumeSource;
        };
        ephemeral = mkOption {
          description = ''
            ephemeral represents a volume that is handled by a cluster storage driver.
            The volume's lifecycle is tied to the pod that defines it - it will be created before the pod starts,
            and deleted when the pod is removed.
            
            Use this if:
            a) the volume is only needed while the pod runs,
            b) features of normal volumes like restoring from snapshot or capacity
               tracking are needed,
            c) the storage driver is specified through a storage class, and
            d) the storage driver supports dynamic volume provisioning through
               a PersistentVolumeClaim (see EphemeralVolumeSource for more
               information on the connection between this volume type
               and PersistentVolumeClaim).
            
            Use PersistentVolumeClaim or one of the vendor-specific
            APIs for volumes that persist for longer than the lifecycle
            of an individual pod.
            
            Use CSI for light-weight local ephemeral volumes if the CSI driver is meant to
            be used that way - see the documentation of the driver for
            more information.
            
            A pod can use both types of ephemeral volumes and
            persistent volumes at the same time.
            
            '';
          type = EphemeralVolumeSource;
        };
      };
    };
  };
  VsphereVirtualDiskVolumeSource = lib.mkOption {
    description = ''
      Represents a vSphere volume resource.
      '';
    type = submodule {
      options = {
        volumePath = mkOption {
          description = ''
            volumePath is the path that identifies vSphere volume vmdk
            '';
          type = str;
        };
        fsType = mkOption {
          description = ''
            fsType is filesystem type to mount.
            Must be a filesystem type supported by the host operating system.
            Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
            '';
          type = str;
        };
        storagePolicyName = mkOption {
          description = ''
            storagePolicyName is the storage Policy Based Management (SPBM) profile name.
            '';
          type = str;
        };
        storagePolicyID = mkOption {
          description = ''
            storagePolicyID is the storage Policy Based Management (SPBM) profile ID associated with the StoragePolicyName.
            '';
          type = str;
        };
      };
    };
  };
  WeightedPodAffinityTerm = lib.mkOption {
    description = ''
      The weights of all of the matched WeightedPodAffinityTerm fields are added per-node to find the most preferred node(s)
      '';
    type = submodule {
      options = {
        weight = mkOption {
          description = ''
            weight associated with matching the corresponding podAffinityTerm,
            in the range 1-100.
            '';
          type = int;
        };
        podAffinityTerm = mkOption {
          description = ''
            Required. A pod affinity term, associated with the corresponding weight.
            '';
          type = PodAffinityTerm;
        };
      };
    };
  };
  WindowsSecurityContextOptions = lib.mkOption {
    description = ''
      WindowsSecurityContextOptions contain Windows-specific options and credentials.
      '';
    type = submodule {
      options = {
        gmsaCredentialSpecName = mkOption {
          description = ''
            GMSACredentialSpecName is the name of the GMSA credential spec to use.
            '';
          type = str;
        };
        gmsaCredentialSpec = mkOption {
          description = ''
            GMSACredentialSpec is where the GMSA admission webhook
            (https://github.com/kubernetes-sigs/windows-gmsa) inlines the contents of the
            GMSA credential spec named by the GMSACredentialSpecName field.
            '';
          type = str;
        };
        runAsUserName = mkOption {
          description = ''
            The UserName in Windows to run the entrypoint of the container process.
            Defaults to the user specified in image metadata if unspecified.
            May also be set in PodSecurityContext. If set in both SecurityContext and
            PodSecurityContext, the value specified in SecurityContext takes precedence.
            '';
          type = str;
        };
        hostProcess = mkOption {
          description = ''
            HostProcess determines if a container should be run as a 'Host Process' container.
            This field is alpha-level and will only be honored by components that enable the
            WindowsHostProcessContainers feature flag. Setting this field without the feature
            flag will result in errors when validating the Pod. All of a Pod's containers must
            have the same effective HostProcess value (it is not allowed to have a mix of HostProcess
            containers and non-HostProcess containers).  In addition, if HostProcess is true
            then HostNetwork must also be set to true.
            '';
          type = bool;
        };
      };
    };
  };
}