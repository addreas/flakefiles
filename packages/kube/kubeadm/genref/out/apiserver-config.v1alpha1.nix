{ lib, ... }:
let
  duration = lib.types.str; # TODO: regex for metav1.Duration
in with lib.types; rec {
  AdmissionConfiguration = lib.mkOption {
    description = ''
      AdmissionConfiguration provides versioned configuration for admission controllers.
      '';
    type = submodule {
      options = {
        plugins = mkOption {
          description = ''
            Plugins allows specifying a configuration per admission control plugin.
            '';
          type = (listOf AdmissionPluginConfiguration);
        };
      };
    };
  };
  EgressSelectorConfiguration = lib.mkOption {
    description = ''
      EgressSelectorConfiguration provides versioned configuration for egress selector clients.
      '';
    type = submodule {
      options = {
        egressSelections = mkOption {
          description = ''
            connectionServices contains a list of egress selection client configurations
            '';
          type = (listOf EgressSelection);
        };
      };
    };
  };
  TracingConfiguration = lib.mkOption {
    description = ''
      TracingConfiguration provides versioned configuration for tracing clients.
      '';
    type = submodule {
      options = {
        endpoint = mkOption {
          description = ''
            Endpoint of the collector that's running on the control-plane node.
            The APIServer uses the egressType ControlPlane when sending data to the collector.
            The syntax is defined in https://github.com/grpc/grpc/blob/master/doc/naming.md.
            Defaults to the otlpgrpc default, localhost:4317
            The connection is insecure, and does not support TLS.
            '';
          type = str;
        };
        samplingRatePerMillion = mkOption {
          description = ''
            SamplingRatePerMillion is the number of samples to collect per million spans.
            Defaults to 0.
            '';
          type = int;
        };
      };
    };
  };
  AdmissionPluginConfiguration = lib.mkOption {
    description = ''
      AdmissionPluginConfiguration provides the configuration for a single plug-in.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            Name is the name of the admission controller.
            It must match the registered admission plugin name.
            '';
          type = str;
        };
        path = mkOption {
          description = ''
            Path is the path to a configuration file that contains the plugin's
            configuration
            '';
          type = str;
        };
        configuration = mkOption {
          description = ''
            Configuration is an embedded configuration object to be used as the plugin's
            configuration. If present, it will be used instead of the path to the configuration file.
            '';
          type = k8s.io/apimachinery/pkg/runtime.Unknown;
        };
      };
    };
  };
  Connection = lib.mkOption {
    description = ''
      Connection provides the configuration for a single egress selection client.
      '';
    type = submodule {
      options = {
        proxyProtocol = mkOption {
          description = ''
            Protocol is the protocol used to connect from client to the konnectivity server.
            '';
          type = ProtocolType;
        };
        transport = mkOption {
          description = ''
            Transport defines the transport configurations we use to dial to the konnectivity server.
            This is required if ProxyProtocol is HTTPConnect or GRPC.
            '';
          type = Transport;
        };
      };
    };
  };
  EgressSelection = lib.mkOption {
    description = ''
      EgressSelection provides the configuration for a single egress selection client.
      '';
    type = submodule {
      options = {
        name = mkOption {
          description = ''
            name is the name of the egress selection.
            Currently supported values are "controlplane", "master", "etcd" and "cluster"
            The "master" egress selector is deprecated in favor of "controlplane"
            '';
          type = str;
        };
        connection = mkOption {
          description = ''
            connection is the exact information used to configure the egress selection
            '';
          type = Connection;
        };
      };
    };
  };
  ProtocolType = lib.mkOption {
    description = ''
      ProtocolType is a set of valid values for Connection.ProtocolType
      '';
  };
  TCPTransport = lib.mkOption {
    description = ''
      TCPTransport provides the information to connect to konnectivity server via TCP
      '';
    type = submodule {
      options = {
        url = mkOption {
          description = ''
            URL is the location of the konnectivity server to connect to.
            As an example it might be "https://127.0.0.1:8131"
            '';
          type = str;
        };
        tlsConfig = mkOption {
          description = ''
            TLSConfig is the config needed to use TLS when connecting to konnectivity server
            '';
          type = TLSConfig;
        };
      };
    };
  };
  TLSConfig = lib.mkOption {
    description = ''
      TLSConfig provides the authentication information to connect to konnectivity server
      Only used with TCPTransport
      '';
    type = submodule {
      options = {
        caBundle = mkOption {
          description = ''
            caBundle is the file location of the CA to be used to determine trust with the konnectivity server.
            Must be absent/empty if TCPTransport.URL is prefixed with http://
            If absent while TCPTransport.URL is prefixed with https://, default to system trust roots.
            '';
          type = str;
        };
        clientKey = mkOption {
          description = ''
            clientKey is the file location of the client key to be used in mtls handshakes with the konnectivity server.
            Must be absent/empty if TCPTransport.URL is prefixed with http://
            Must be configured if TCPTransport.URL is prefixed with https://
            '';
          type = str;
        };
        clientCert = mkOption {
          description = ''
            clientCert is the file location of the client certificate to be used in mtls handshakes with the konnectivity server.
            Must be absent/empty if TCPTransport.URL is prefixed with http://
            Must be configured if TCPTransport.URL is prefixed with https://
            '';
          type = str;
        };
      };
    };
  };
  Transport = lib.mkOption {
    description = ''
      Transport defines the transport configurations we use to dial to the konnectivity server
      '';
    type = submodule {
      options = {
        tcp = mkOption {
          description = ''
            TCP is the TCP configuration for communicating with the konnectivity server via TCP
            ProxyProtocol of GRPC is not supported with TCP transport at the moment
            Requires at least one of TCP or UDS to be set
            '';
          type = TCPTransport;
        };
        uds = mkOption {
          description = ''
            UDS is the UDS configuration for communicating with the konnectivity server via UDS
            Requires at least one of TCP or UDS to be set
            '';
          type = UDSTransport;
        };
      };
    };
  };
  UDSTransport = lib.mkOption {
    description = ''
      UDSTransport provides the information to connect to konnectivity server via UDS
      '';
    type = submodule {
      options = {
        udsName = mkOption {
          description = ''
            UDSName is the name of the unix domain socket to connect to konnectivity server
            This does not use a unix:// prefix. (Eg: /etc/srv/kubernetes/konnectivity-server/konnectivity-server.socket)
            '';
          type = str;
        };
      };
    };
  };
}