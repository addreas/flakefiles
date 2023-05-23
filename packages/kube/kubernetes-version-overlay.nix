self: super:
let
  version = "1.26.3";
  sha256 = "sha256-dJMfnd82JIPxyVisr5o9s/bC3ZDiolF841pmV4c9LN8=";
in
{
  kubernetes = super.kubernetes.overrideAttrs
    (oldAttrs: {
      inherit version;
      src = super.fetchFromGitHub {
        inherit sha256;
        owner = "kubernetes";
        repo = "kubernetes";
        rev = "v${version}";
      };
      WHAT = "cmd/kubeadm cmd/kubelet";
    });
}
