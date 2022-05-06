{
  description = "my project description";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        {
          defaultPackage = nixpkgs.callPackaget ./default.nix
            {
              inherit system};
              devShell = defaultPackage;
            }
            );
        }
