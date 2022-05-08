{
  description = "Just a bunch of stuff";

  inputs.nixpkgs.url = "nixpkgs";

  # inputs.grcov = {
  #   type = "github";
  #   owner = "mozilla";
  #   repo = "grcov";
  #   flake = false;
  # };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    with import nixpkgs { inherit system; };
    rec {
      packages.${system} = rec {
        pcp = callPackage ./packages/pcp { };
        cockpit = callPackage ./packages/cockpit { inherit pcp; };
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

      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${self}/machines/lenny-wsl"
          "${self}/machines/wsl"
          "${self}/packages/cockpit/module.nix"
          "${self}/packages/pcp/module.nix"
        ];
      };
    };
}
