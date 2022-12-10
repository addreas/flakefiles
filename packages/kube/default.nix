{
  imports = [
    ./crio.nix
    ./kubernetes-version-overlay.nix
    ./kubeadm/kubeadm.nix
    ./kubeadm/kubelet.nix
  ];
}
