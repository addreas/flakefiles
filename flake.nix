{
  description = "Just a bunch of stuff";

  inputs.nixpkgs.url = "nixpkgs";

  # inputs.grcov = {
  #   type = "github";
  #   owner = "mozilla";
  #   repo = "grcov";
  #   flake = false;
  # };

  outputs = all@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    with import nixpkgs { inherit system; };
    rec {
      packages.${system} = rec {
        pcp = callPackage ./packages/pcp { };
        cockpit = callPackage ./packages/cockpit { inherit pcp; };
        cockpit-machines = callPackage ./packages/cockpit-machines { };
      };

      nixosModules = {
        pcp = import ./packages/pcp/module.nix;
        cockpit = import ./packages/cockpit/module.nix;
      };

      nixosConfigurations.sergio = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # sergioFilesystems
          # sergioServices
          # kubeNode
        ];
      };

      nixosConfigurations.lenny = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # wsl
          # devBox
        ];
      };
    };
}
