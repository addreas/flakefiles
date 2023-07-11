{
  description = "Just a bunch of stuff";

  # inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.nixpkgs.url = "nixpkgs/nixos-23.05";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

  inputs.vscode-server.url = "github:msteen/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  inputs.vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  inputs.vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager/release-23.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nixos-wsl, vscode-server, vscode-extensions, nixos-hardware, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          vscode-extensions.overlays.default
        ];
        config.allowUnfree = true;
      };

      machine = name: extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        inherit pkgs;
        modules = [
          { environment.etc."nixos-source".source = self; }
          "${self}/machines/${name}"
        ] ++ extraModules;
      };

    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      packages.${system} = {
        cockpit-machines = pkgs.callPackage ./packages/cockpit-machines { };
        cockpit-podman = pkgs.callPackage ./packages/cockpit-podman { };
      };

      apps.${system} =
        let
          script = name: src: {
            type = "app";
            program = "${pkgs.writeScript name src}";
          };
        in
        {
          diff-current-system-store = script "diff-current-system-store" ''
            nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel \
            && nix store diff-closures /nix/var/nix/profiles/system ./result
          '';
          diff-current-system-drv = script "diff-current-system-drv" ''
            nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel \
            && ${pkgs.nix-diff}/bin/nix-diff --character-oriented --environment  /run/current-system ./result
          '';
        };

      nixosModules =
        let
          addem-module = path: {
            imports = [
              home-manager.nixosModules.home-manager
              ./users/addem.nix
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.addem = import "${self}/users/addem/${path}";
          };
        in
        {
          addem-basic = addem-module "home.nix";
          addem-desktop = addem-module "home.desktop.nix";
          addem-dev = addem-module "home.dev.nix";

          base = import ./machines/common/base.nix;
          nix-builder = import ./machines/common/nix-builder.nix;
          services = import ./machines/common/services.nix;
        };

      homeConfigurations =
        let
          addem-home-config = path: home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ "${self}/users/addem/${path}" ];
          };
        in
        {
          addem-basic = addem-home-config "home.nix";
          addem-desktop = addem-home-config "home.desktop.nix";
          addem-dev = addem-home-config "home.dev.nix";
        };

      nixosConfigurations.expessy = machine "expessy" [ self.nixosModules.addem-desktop ];

      nixosConfigurations.lenny = machine "lenny" [ self.nixosModules.addem-desktop ];

      nixosConfigurations."LAPTOP-EK7DRJB8" = machine "lenny-wsl" [
        nixos-wsl.nixosModules.wsl
        vscode-server.nixosModule
        self.nixosModules.addem-dev
      ];
    };
}
