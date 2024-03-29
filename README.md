# links

https://blog.dachary.org/2014/02/09/figuring-out-why-ccache-misses/
https://nixos.org/guides/nix-pills/index.html
https://nixos.wiki/wiki/Flakes

https://github.com/jordanisaacs/neovim-flake
https://github.com/jordanisaacs/jdpkgs
https://github.com/jordanisaacs/dotfiles
https://github.com/jordanisaacs/neovim-flake
https://jdisaacs.com/blog/nixos-config/
https://christine.website/blog/my-homelab-nas-2021-11-29
https://christine.website/blog/nix-flakes-1-2022-02-21
https://christine.website/blog/nix-flakes-2-2022-02-27
https://christine.website/blog/nix-flakes-3-2022-04-07
https://christine.website/blog/nix-flakes-4-wsl-2022-05-01

https://cnx.srht.site/blog/butter/index.html

https://wiki.archlinux.org/title/Avahi

# nixos

```sh
sudo nixos-rebuild switch --flake .#LAPTOP-EK7DRJB8
```

```
nix develop .#pcp

echo "src = $src" && cd $(mktemp -d) && unpackPhase && cd * && patchPhase && configurePhase
```

```
  build .#nixosConfigurations.sergio.config.system.build.toplevel
  nix-diff --character-oriented /run/current-system result
```

https://nixos.wiki/wiki/Netboot
https://github.com/danderson/netboot/tree/master/pixiecore
https://github.com/lucernae/nixos-pi/

```sh
# pixie pie host
# if boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
nix build .#nixosConfigurations.pixie-pie-host.config.system.build.sdImage

# requests http://localhost:8080/v1/boot/84:a9:3e:10:c4:66

# PXE unattended provisioning
nix build .#nixosConfigurations.pixie-installer.config.system.build.kernel
nix build .#nixosConfigurations.pixie-installer.config.system.build.netbootRamdisk
nix build .#nixosConfigurations.pixie-installer.config.system.build.netbootIpxeScript

# PXE tmproot
nix build .#nixosConfigurations.pixie-trixie.config.system.build.kernel
nix build .#nixosConfigurations.pixie-trixie.config.system.build.netbootRamdisk
nix build .#nixosConfigurations.pixie-trixie.config.system.build.netbootIpxeScript
```
