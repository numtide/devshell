{
  description = "devshell";
  # To update all inputs:
  # $ nix flake update --recreate-lock-file
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";

  outputs = { self, nixpkgs, systems }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      legacyPackages = eachSystem (system:
          import self {
            inherit system;
            inputs = null;
            nixpkgs = nixpkgs.legacyPackages.${system};
          }
      );

      devShells = eachSystem (system: {
        default = self.legacyPackages.${system}.fromTOML ./devshell.toml;
      });

      templates = rec {
        toml = {
          path = ./templates/toml;
          description = "nix flake new my-project -t github:numtide/devshell";
        };
        flake-parts = {
          path = ./templates/flake-parts;
          description = "nix flake new my-project -t github:numtide/devshell#flake-parts";
        };
        default = toml;
      };
      # Import this overlay into your instance of nixpkgs
      overlays.default = import ./overlay.nix;
      lib = {
        importTOML = import ./nix/importTOML.nix;
      };
      flakeModule = ./flake-module.nix;
    };
}
