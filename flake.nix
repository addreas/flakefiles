{
  description = "Just a bunch of stuff";

  inputs.nixpkgs.url = "nixpkgs";

  inputs.pcp.url = "./packages/pcp";
  inputs.cockpit.url = "./packages/cockpit";

  # inputs.grcov = {
  #   type = "github";
  #   owner = "mozilla";
  #   repo = "grcov";
  #   flake = false;
  # };

  outputs = all@{ self, nixpkgs, wsl, pcp, cockpit, ... }: {
    packages.x86_64-linux = {
      pcp = pcp.package.x86_64-linux;
      cockpit = cockpit.package.x86_64-linux;
    };

    nixosModules = {
      pcp = pcp.module;
      cockpit = cockpit.module;
    };

    devShells.x86_64-linux = {
      pcp = pcp.shell.x86_64-linux;
      cockpit = cockpit.shell.x86_64-linux;
    };

    nixosConfigurations.sergio = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # sergioFilesystems
        # sergioServices
        # kubeNode
      ];
    };

    nixosConfigurations.lenny = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # wsl
        # devBox
      ];
    };
  };
}
