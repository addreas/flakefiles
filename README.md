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





# Cockpit nix module (experimental/unmaintained)

https://github.com/NixOS/nixpkgs/issues/38161
https://github.com/repos-holder/nur-packages/blob/master/pkgs/cockpit/default.nix

Since the official release tarball contains pre-packaged web resources we can sidestep the issue of running webpack et. al. by just going for a `make install` in the build phase. 

Adding `module.nix` as an import, and `services.cockpit.enabled = true`  in `/etc/nixos/configuration.nix` should be enough to get started. 

# Seems to work
- Overview (except package updates link, usage history)
- Logs
- Account (only listing)
- Systemd services (not user)
- Terminal

# TODO
- [ ] networkmanager
- [ ] packagekit
- [ ] udisks2
- [ ] selinux
- [ ] cockpit-pcp (remove `--disable-pcp`, but first need to create package for https://github.com/performancecopilot/pcp)
- [ ] cockpit-podman (subpackage https://github.com/cockpit-project/cockpit-podman/)
- [ ] cockpit-machines (subpackage https://github.com/cockpit-project/cockpit-machines)
- [ ] don't run as root?
- [ ] nix flake
