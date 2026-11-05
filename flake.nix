{
  description = "Just a bunch of stuff";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  # inputs.nixpkgs.url = "nixpkgs/nixos-23.11";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  # inputs.nixpkgs.url = "nixpkgs/nixos-25.05";

  inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";
  inputs.nix-alien.url = "github:thiagokokada/nix-alien";

  inputs.dms = {
    url = "github:duxlabs-dev/dux-shell/stable";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.niri = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.dank-greeter = {
    url = "github:duxlabs-dev/dux-greeter/v2.0.0";
    inputs.nixpkgs.follows = "nixpkgs";
    # same DCommon revision as dux-shell 2.0.0 (pinned by both)
    inputs.dank-qml-common.follows = "dms/dank-qml-common";
  };

  inputs.home-manager.url = "github:nix-community/home-manager";
  # inputs.home-manager.url = "github:nix-community/home-manager/release-25.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    { self
    , nixpkgs
    , ...
    }@inputs:
    let
      system = "x86_64-linux";

      nixpkgs-config = {
        allowUnfree = true;
        segger-jlink.acceptLicense = true;
        permittedInsecurePackages = [ "segger-jlink-qt4-970" ];
      };

      pkgs = import nixpkgs {
        inherit system;
        config = nixpkgs-config;
      };

      lib = nixpkgs.lib;

      home-module = host: {
        imports = [ "${self}/users/addem/home.${host}.nix" ];
      };

      home-config = host: inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs.inputs = inputs;
        modules = [
          (home-module host)
          { nixpkgs.config = nixpkgs-config; }
        ];
      };

      nixos-module = host: {
        imports = [
          inputs.home-manager.nixosModules.home-manager
          ./users/addem.nix
        ];
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs.inputs = inputs;
        home-manager.users.addem = home-module host;
      };

      machine = host: extraModules: lib.nixosSystem {
        inherit system;
        inherit pkgs;
        specialArgs.nixpkgs = nixpkgs;
        specialArgs.flakepkgs = self.packages.${system};
        specialArgs.inputs = inputs;
        modules = [
          { environment.etc."nixos-source".source = self; }
          {
            environment.systemPackages = [ inputs.nix-alien.packages.${system}.default ];
            programs.nix-ld.enable = true;
          }
          "${self}/machines/${host}"
          (nixos-module host)
        ] ++ extraModules;
      };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      nixosConfigurations = {
        expessy = machine "expessy" [ ];
        lenny = machine "lenny" [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
      };

      homeConfigurations = {
        expessy = home-config "expessy";
        lenny = home-config "lenny";
      };

      nixosModules = {
        base = import ./machines/common/base.nix;
        nix-builder = import ./machines/common/nix-builder.nix;
        services = import ./machines/common/services.nix;
      };

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
