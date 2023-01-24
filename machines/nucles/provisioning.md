
Host config`./<new-node>/default.nix`:
```nix
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../default.nix
  ];

  networking.hostName = "new-node";

  services.kubeadm.init = {
    enable = true;
    bootstrapTokenFile = "/var/secret/kubeadm-bootstrap-token"; 

    # for control plane
    certificateKeyFile = "/var/secret/kubeadm-cert-key";
  };
}
```

Add host config in root `flake.nix`
```nix
      nixosConfigurations.<new-node> = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${self}/machines/nucles/<new-node>"
          home-manager.nixosModules.home-manager
          nixosModules.home-manager-addem
        ];
      };

      nixosConfigurations.<some-pxe-host> = ... {
        ...
        modules = [
          ...

          "${self}/packages/pixie-api/module.nix"
          {
            services.pixiecore-host-configs.enable = true;
            services.pixiecore-host-configs.hosts = {
              "84:a9:3e:10:c4:66" = {
                nixosSystem = nixosConfigurations.nucle-installer;
                kernelParams = [ "hostname=<new-node>" ];
              };
            };
          }
        ];
      };
```


Check that everything went well
```sh
ssh new-node.localdomain
cd flakefiles
git pull

sudo ./users/mkshadow.sh addem
sudo nixos-rebuild switch

# These will be failing
systemctl status kubeadm-join
systemctl status kubelet
```

Setup kubelet bootstap token, and rebuild
```sh
ssh nucle1.localdomain -- kubeadm token create | ssh new-node.localdomain -- sudo tee /var/secret/kubeadm-bootstrap-token

#for controlplane
ssh nucle1.localdomain -- sudo kubeadm init phase upload-certs --upload-certs | grep -v upload-certs | ssh new-node.localdomain -- sudo tee /var/secret/kubeadm-cert-key

ssh new-node.localdomain
# Now these hopefully succeed / start
systemctl status kubeadm-join
systemctl status kubelet
````

Finally remove
```
  services.kubeadm.init = {
    ...
  };
```
from `./<new-node>/default.nix` and commit, push, pull and rebuild