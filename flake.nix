{
  description = "Just a bunch of stuff";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

  inputs.vscode-server.url = "github:msteen/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";


  outputs = { self, nixpkgs, nixos-wsl, vscode-server, nixos-hardware, home-manager, ... }:
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
        modules = nixpkgs.lib.lists.flatten [
          {
            environment.etc."nixos-source".source = self;
          }
          {
            nixpkgs.config.allowUnfree = true;
          }
          "${self}/machines/${name}"
          modules
        ] ;
      };

      trivial-machine = name: machine name [];

    in
    with import nixpkgs { inherit system; }; rec {
      packages.${system} = rec {
        cockpit-machines = callPackage ./packages/cockpit-machines { };
        cockpit-podman = callPackage ./packages/cockpit-podman { };
      };

      apps.${system}.diff-current-system = let
        diff-closures = pkgs.writeScript "diff-current-system" ''
          nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel
          nix store diff-closures /nix/var/nix/profiles/system ./result
          # nix-diff --character-oriented --environment  /run/current-system ./result
        '';
      in {
        type = "app";
        program = "${diff-closures}";
      };

      homeConfigurations.addem = home-config ./users/addem/home.desktop.nix;
      homeConfigurations.addem-dev = home-config ./users/addem/home.dev.nix;

      nixosConfigurations.sergio = machine "sergio" [
        addem-basic

        # "${self}/packages/pixie-api/module.nix"
        # {
        #   services.pixiecore-host-configs.enable = true;
        #   services.pixiecore-host-configs.hosts = let
        #     nucle-installer = name: {
        #       nixosSystem = nixosConfigurations.nucle-installer;
        #       kernelParams = [ "hostname=${name}" ];
        #     };
        #   in {
        #     # "1c:69:7a:a0:af:3e" = nucle-installer "nucle1";
        #     # "1c:69:7a:6f:c2:b8" = nucle-installer "nucle2";
        #     # "1c:69:7a:01:84:76" = nucle-installer "nucle3";
        #     # "84:a9:3e:10:c4:66" = nucle-installer "nucle4";
        #   };
        # }
      ];

      # nixosConfigurations.nucle1 = machine "nucles/nucle1" [addem-basic];
      # nixosConfigurations.nucle2 = machine "nucles/nucle2" [addem-basic];
      nixosConfigurations.nucle3 = machine "nucles/nucle3" [addem-basic];
      nixosConfigurations.nucle4 = machine "nucles/nucle4" [addem-basic];

      nixosConfigurations.expessy = machine "expessy" [
        (home-manager-addem ./users/addem/home.desktop.nix)
      ];

      nixosConfigurations.lenny = machine "lenny" [
        (home-manager-addem ./users/addem/home.desktop.nix)
      ];

      nixosConfigurations."LAPTOP-EK7DRJB8" = machine "lenny-wsl" [
        nixos-wsl.nixosModules.wsl
        vscode-server.nixosModule
        (home-manager-addem ./users/addem/home.dev.nix)
      ];

      nixosConfigurations.pixie-installer = trivial-machine "pixie-installer";
      nixosConfigurations.pixie-trixie = trivial-machine "pixie-trixie";
      nixosConfigurations.nucle-installer = trivial-machine "nucle-installer";
    };
}
