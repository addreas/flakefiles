{
  description = "Just a bunch of stuff";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nixos-wsl, nixos-hardware, home-manager, ... }:
    let
      system = "x86_64-linux";

      home-manager-addem = home-conf: [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.addem = import home-conf;
          }
      ];

      home-config = home-conf: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        modules = [home-conf];
      };

      addem-basic = home-manager-addem ./users/addem/home.nix;

      machine = name: modules: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = nixpkgs.lib.lists.flatten [ "${self}/machines/${name}" modules ] ;
      };

      trivial-machine = name: machine name [];

    in
    with import nixpkgs { inherit system; }; rec {
      packages.${system} = rec {
        cockpit-machines = callPackage ./packages/cockpit-machines { };
        cockpit-podman = callPackage ./packages/cockpit-podman { };
      };

      homeConfigurations.addem = home-config ./users/addem/home.desktop.nix;
      homeConfigurations.addem-dev = home-config ./users/addem/home.dev.nix;

      nixosConfigurations.sergio = machine "sergio" [
        addem-basic

        "${self}/packages/pixie-api/module.nix"
        {
          services.pixiecore-host-configs.enable = true;
          services.pixiecore-host-configs.hosts = let
            nucle-installer = name: {
              nixosSystem = nixosConfigurations.nucle-installer;
              kernelParams = [ "hostname=${name}" ];
            };
          in {
            # "1c:69:7a:a0:af:3e" = nucle-installer "nucle1";
            # "1c:69:7a:6f:c2:b8" = nucle-installer "nucle2";
            # "1c:69:7a:01:84:76" = nucle-installer "nucle3";
            # "84:a9:3e:10:c4:66" = nucle-installer "nucle4";
          };
        }
      ];

      # nixosConfigurations.nucle1 = machine "nucles/nucle1" [addem-basic];
      # nixosConfigurations.nucle2 = machine "nucles/nucle2" [addem-basic];
      nixosConfigurations.nucle3 = machine "nucles/nucle3" [addem-basic];
      nixosConfigurations.nucle4 = machine "nucles/nucle4" [addem-basic];

      nixosConfigurations.expessy = machine "expessy" [
        (home-manager-addem ./users/addem/home.desktop.nix)
      ];

      nixosConfigurations."LAPTOP-EK7DRJB8" = machine "lenny" [
        nixos-wsl.nixosModules.wsl
        (home-manager-addem ./users/addem/home.dev.nix)
      ];

      nixosConfigurations.pixie-installer = trivial-machine "pixie-installer";
      nixosConfigurations.pixie-trixie = trivial-machine "pixie-trixie";
      nixosConfigurations.nucle-installer = trivial-machine "nucle-installer";
    };
}
