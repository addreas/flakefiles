{
  description = "Just a bunch of stuff";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  # inputs.nixpkgs.url = "nixpkgs/nixos-23.11";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  # inputs.nixpkgs.url = "nixpkgs/nixos-24.11";

  inputs.vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  inputs.vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  # inputs.home-manager.url = "github:nix-community/home-manager/release-24.11";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, vscode-extensions, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          vscode-extensions.overlays.default
        ];
        config.allowUnfree = true;
        # config.segger-jlink.acceptLicense = true;
        # config.permittedInsecurePackages = [ "segger-jlink-qt4-794l" ];
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

    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      packages.${system} = rec {
        cockpit-machines = pkgs.callPackage ./packages/cockpit-machines { };
        cockpit-podman = pkgs.callPackage ./packages/cockpit-podman { };

        nrf-udev = pkgs.callPackage ./packages/nrf-udev { };

        simplicity-commander = pkgs.callPackage ./packages/simplicity-commander { };
        simplicity-commander-cli = pkgs.callPackage ./packages/simplicity-commander-cli { };

        freecad = pkgs.callPackage ./packages/freecad { inherit freecad-git; };
        # freecad-custom = (pkgs.freecad.override {
        #   withWayland = true;
        #   # ifcSupport = true;
        # }).customize {
        #   pythons = [(ps: with ps; [ ifcopenshell ])];
        #   makeWrapperArgs = []
        # };
        # freecad-git-ifc = freecad-git.customize {
        #   pythons = [(ps: with ps; [ ifcopenshell ])];
        # };
        freecad-git = pkgs.freecad-wayland.overrideAttrs {
          version = "1.1.0-dev";
          patches = let patch = index: builtins.elemAt pkgs.freecad-wayland.patches index; in [
            (patch 0)
            (patch 1)
          ];
          nativeBuildInputs = pkgs.freecad-wayland.nativeBuildInputs ++ [ pkgs.fontconfig pkgs.freetype ];

          # nativeBuildInputs = pkgs.freecad-wayland.nativeBuildInputs ++ [ pkgs.autoPatchelfHook ];
          # appendRunpaths = [
          #   (pkgs.lib.makeLibraryPath [
          #     pkgs.fontconfig
          #     pkgs.freetype
          #   ])
          # ];
          src = pkgs.fetchFromGitHub {
            owner = "FreeCAD";
            repo = "FreeCAD";
            rev = "6c20224379d6f52dfbc768ebab4942f90bcb3ea4";
            hash = "sha256-XuySqC529mVns/M3yItUdIqz3+/g0UxyKUsJmAd9ZK8=";
            fetchSubmodules = true;
          };
        };
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
            #!/bin/sh
            nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel \
            && nix store diff-closures /nix/var/nix/profiles/system ./result
          '';
          diff-current-system-drv = script "diff-current-system-drv" ''
            #!/bin/sh
            nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel \
            && ${pkgs.nix-diff}/bin/nix-diff --character-oriented --environment  /run/current-system ./result
          '';
          tree-current-system-drv = script "tree-current-system-drv" ''
            #!/bin/sh
            nix eval --raw .#nixosConfigurations.$(hostname).config.system.build.toplevel | xargs -o ${pkgs.nix-tree}/bin/nix-tree --derivation
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
            home-manager.extraSpecialArgs.flakepkgs = self.packages.${system};
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
            extraSpecialArgs.flakepkgs = self.packages.${system};
          };
        in
        {
          addem = addem-home-config "home.desktop.nix";
          addem-basic = addem-home-config "home.nix";
          addem-desktop = addem-home-config "home.desktop.nix";
          addem-dev = addem-home-config "home.dev.nix";
        };

      nixosConfigurations.expessy = machine "expessy" [ self.nixosModules.addem-desktop ];

      nixosConfigurations.lenny = machine "lenny" [ self.nixosModules.addem-desktop ];
    };
}
