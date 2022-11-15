# Cockpit nix module (experimental/unmaintained)

https://github.com/NixOS/nixpkgs/issues/38161
https://github.com/repos-holder/nur-packages/blob/master/pkgs/cockpit/default.nix

Since the official release tarball contains pre-packaged web resources we can sidestep the issue of running webpack et. al. by just going for a `make install` in the build phase.

# Seems to work

-   Overview (except package updates link, usage history)
-   Logs
-   Account (only listing)
-   Systemd services (not user)
-   Terminal

# TODO

-   [ ] networkmanager
-   [ ] packagekit
-   [ ] udisks2
-   [ ] selinux
-   [ ] don't run as root?
