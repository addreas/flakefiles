{
  description = "Just a bunch of stuff";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  # inputs.nixpkgs.url = "nixpkgs/nixos-23.11";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  # inputs.nixpkgs.url = "nixpkgs/nixos-25.05";

  inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";

  inputs.home-manager.url = "github:nix-community/home-manager";
  # inputs.home-manager.url = "github:nix-community/home-manager/release-25.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.elephant.url = "github:abenz1267/elephant";
  inputs.walker = {
    url = "github:abenz1267/walker";
    inputs.elephant.follows = "elephant";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nix-flatpak
    , ...
    }@inputs:
    let
      system = "x86_64-linux";

      nixpkgs-config = {
        allowUnfree = true;
        segger-jlink.acceptLicense = true;
        permittedInsecurePackages = [ "segger-jlink-qt4-874" ];
      };

      pkgs = import nixpkgs {
        inherit system;
        config = nixpkgs-config;
      };

      machine = name: extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        inherit pkgs;
        specialArgs.nixpkgs = nixpkgs;
        specialArgs.flakepkgs = self.packages.${system};
        modules = [
          { environment.etc."nixos-source".source = self; }
          "${self}/machines/${name}"
        ] ++ extraModules;
      };

      home-files = {
        addem-basic = "addem/home.nix";
        addem-dev = "addem/home.dev.nix";
        addem-desktop = "addem/home.desktop.nix";
      };

      addem-home-config = name: extraModules: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs.inputs = inputs;
        modules = [
          "${self}/users/${home-files.${name}}"
          { nixpkgs.config = nixpkgs-config; }
        ] ++ extraModules;
      };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      homeConfigurations = {
        addem = self.homeConfigurations.addem-desktop;

        addem-basic = addem-home-config "addem-basic" [ ];
        addem-dev = addem-home-config "addem-dev" [ ];
        addem-desktop = addem-home-config "addem-desktop" [ ];
      };

      nixosModules =
        let
          addem-module = name: {
            imports = [
              home-manager.nixosModules.home-manager
              ./users/addem.nix
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs.inputs = inputs;
            home-manager.users.addem = import "${self}/users/${home-files.${name}}";
          };
        in
        {
          base = import ./machines/common/base.nix;
          nix-builder = import ./machines/common/nix-builder.nix;
          services = import ./machines/common/services.nix;

          addem-basic = addem-module "addem-basic";
          addem-dev = addem-module "addem-dev";
          addem-desktop = addem-module "addem-desktop";
        };

      nixosConfigurations.expessy = machine "expessy" [ self.nixosModules.addem-desktop ];
      nixosConfigurations.lenny = machine "lenny" [ self.nixosModules.addem-desktop ];

      packages.${system} = rec {
        nrf-udev = pkgs.callPackage ./packages/nrf-udev { };
      };

      apps.${system} =
        let appScript = name: src: { type = "app"; program = "${pkgs.writeScript name src}"; }; in
        {
          diff-current-system-store = appScript "diff-current-system-store" ''
            #!/bin/sh
            nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel \
            && nix store diff-closures /nix/var/nix/profiles/system ./result
          '';
          diff-current-system-drv = appScript "diff-current-system-drv" ''
            #!/bin/sh
            nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel \
            && ${pkgs.nix-diff}/bin/nix-diff --character-oriented --environment  /run/current-system ./result
          '';
          tree-current-system-drv = appScript "tree-current-system-drv" ''
            #!/bin/sh
            nix eval --raw .#nixosConfigurations.$(hostname).config.system.build.toplevel | xargs -o ${pkgs.nix-tree}/bin/nix-tree --derivation
          '';
        };
    };
}
