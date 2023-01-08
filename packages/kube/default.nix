{ pkgs, ... }: {
  imports = [
    ./crio.nix
    ./cilium.nix
    ./kubernetes-version-overlay.nix
    ./kubeadm
  ];

  config = {
    environment.systemPackages = [ pkgs.openiscsi ];
  };
}
