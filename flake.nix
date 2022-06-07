{
  description = "Just a bunch of stuff";

  inputs.nixpkgs.url = "nixpkgs";

  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";

  outputs = { self, nixpkgs, nixos-wsl, ... }:
    let
      system = "x86_64-linux";
    in
    with import nixpkgs { inherit system; };
    rec {
      packages.${system} = rec {
        pcp = callPackage ./packages/pcp { };
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

      nixosConfigurations."LAPTOP-EK7DRJB8" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-wsl.nixosModules.wsl
          "${self}/machines/lenny"
          "${self}/packages/cockpit/module.nix"
          "${self}/packages/pcp/module.nix"
        ];

      };
    };
}
