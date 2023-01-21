{ pkgs, config, ... }: {
  imports = [
    ./crio.nix
    ./cilium.nix
    ./kubernetes-version-overlay.nix
    ./kubeadm
  ];

  config = {
    environment.systemPackages = [ pkgs.openiscsi ];

    services.openiscsi.enable = true;
    services.openiscsi.name = "iqn.2023-01.se.addem.nucles:${config.networking.hostName}";

    networking.firewall.checkReversePath = false; # even loose breaks kube-dns responses
    networking.firewall.allowedUDPPorts = [
      53 # routing kube dns responses
    ];
  };
}
