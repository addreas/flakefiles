{ lib, ... }:
let
  duration = lib.types.str; # TODO: regex for metav1.Duration
in with lib.types; rec {
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
            - credentialprovider.kubelet.k8s.io/v1
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
}