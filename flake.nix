{
  description = "Just a bunch of stuff";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nixos-wsl, nixos-hardware, home-manager, ... }:
    let system = "x86_64-linux";
    in
    with import nixpkgs { inherit system; }; rec {
      packages.${system} = rec {
        pcp = callPackage ./packages/pcp { }; # just run container instead? https://quay.io/repository/performancecopilot/pcp?tab=tags
        cockpit = callPackage ./packages/cockpit { extraPackages = [ pcp ]; };
        cockpit-machines = callPackage ./packages/cockpit-machines { };
        cockpit-podman = callPackage ./packages/cockpit-podman { };
      };

      homeConfigurations.addem = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        modules = [
          ./users/addem/home.desktop.nix
          {
            home = {
              username = "addem";
              homeDirectory = "/home/addem";
              stateVersion = "22.11";
            };
          }
        ];
      };

      nixosModules = {
        pcp = import ./packages/pcp/module.nix;
        cockpit = import ./packages/cockpit/module.nix;

        home-manager-addem = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.addem = import ./users/addem/home.nix;
        };
        home-manager-addem-desktop = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.addem = import ./users/addem/home.desktop.nix;
        };
      };

      nixosConfigurations.sergio = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${self}/machines/sergio"
          home-manager.nixosModules.home-manager
          nixosModules.home-manager-addem
        ];
      };


      nixosConfigurations.nucle-installer = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ "${self}/machines/nucle-installer" ];
      };

      nixosConfigurations.nucle4 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = ["${self}/machines/nucles/nucle4"];
      };

      nixosConfigurations.expessy = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${self}/machines/expessy"
          home-manager.nixosModules.home-manager
          nixosModules.home-manager-addem-desktop

          "${self}/packages/pixie-api/module.nix"
          {
            services.pixiecore-host-configs.enable = true;
            services.pixiecore-host-configs.hosts = {
              "84:a9:3e:10:c4:66" = {
                nixosSystem = nixosConfigurations.nucle-installer;
                kernelParams = [ "hostname=nucle4" ];
              };
            };
          }
        ];
      };

      nixosConfigurations."LAPTOP-EK7DRJB8" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-wsl.nixosModules.wsl
          "${self}/machines/lenny"
          home-manager.nixosModules.home-manager
          nixosModules.home-manager-addem
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
