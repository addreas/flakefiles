{ pkgs, ... }: {

  config = {

    virtualisation.cri-o = {
      enable = true;
      storageDriver = "btrfs";
      settings.crio.network.plugin_dirs = [ "/opt/cni/bin" "${pkgs.cni-plugins}/bin" ];
    };

    system.activationScripts.var-lib-crio = "mkdir -p /var/lib/crio";

  };
}
