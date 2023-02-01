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
}