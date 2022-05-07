{
  description = "my other project description";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: { };
}
