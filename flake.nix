{
  description = "Just a bunch of stuff";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";

  outputs = { self, nixpkgs, nixos-wsl, nixos-hardware, ... }:
    let system = "x86_64-linux";
    in
    with import nixpkgs { inherit system; }; rec {
      packages.${system} = rec {
        pcp = callPackage ./packages/pcp { }; # just run container instead? https://quay.io/repository/performancecopilot/pcp?tab=tags
        cockpit = callPackage ./packages/cockpit { extraPackages = [ pcp ]; };
        cockpit-machines = callPackage ./packages/cockpit-machines { };
        cockpit-podman = callPackage ./packages/cockpit-podman { };
      };

      nixosModules = {
        pcp = import ./packages/pcp/module.nix;
        cockpit = import ./packages/cockpit/module.nix;
      };

      nixosConfigurations.sergio = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ "${self}/machines/sergio" ];
      };

      nixosConfigurations.expessy = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ "${self}/machines/expessy" ];
      };

      nixosConfigurations."LAPTOP-EK7DRJB8" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-wsl.nixosModules.wsl
          "${self}/machines/lenny"
        ];
      };

      nixosConfigurations.pixie-pie-host = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${self}/machines/pixie-pie-host"
          "${self}/packages/pixie-api/module.nix"
          nixos-hardware.nixosModules.raspberry-pi-4
          {
            #https://github.com/NixOS/nixpkgs/issues/154163
            #https://github.com/NixOS/nixpkgs/issues/109280
            #https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
            nixpkgs.overlays = [
              (final: super: {
                makeModulesClosure = x:
                  super.makeModulesClosure (x // { allowMissing = true; });
              })
            ];

            services.pixiecore-host-configs.enable = true;
            services.pixiecore-host-configs.hosts = {
              "84:a9:3e:10:c4:66" = {
                nixosSystem = nixosConfigurations.pixie-installer;
              };
              "00:00:00:00:00:00" = {
                nixosSystem = nixosConfigurations.pixie-trixie;
                kernelParams = [ "hostname=pixie-trixie-testhost" ];
              };
            };
          }
        ];
      };
      images.pixie-pie-host = nixosConfigurations.pixie-pie-host.config.system.build.sdImage;

      nixosConfigurations.pixie-installer = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ "${self}/machines/pixie-installer" ];
      };

      nixosConfigurations.pixie-trixie = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ "${self}/machines/pixie-trixie" ];
      };
    };
}
