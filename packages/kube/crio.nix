{ pkgs, ... }: {

  config = {

    virtualisation.cri-o = {
      enable = true;
      storageDriver = "btrfs";
      settings.crio.network.plugins_dir = [ "${pkgs.cni-plugins}/bin" "/opt/cni/bin" ];
    };

    system.activationScripts.var-lib-crio = "mkdir -p /var/lib/crio";

  };
}
