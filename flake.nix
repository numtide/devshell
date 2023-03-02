{
  description = "devshell";
  # To update all inputs:
  # $ nix flake update --recreate-lock-file
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = inputs:
    inputs.flake-utils.lib.eachSystem [
      "aarch64-darwin"
      "aarch64-linux"
      "i686-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ]
      (system:
        let
          pkgs = import inputs.self {
            inherit system;
            inputs = null;
            nixpkgs = inputs.nixpkgs.legacyPackages.${system};
          };
        in
        {
          legacyPackages = pkgs;
          devShells.default = pkgs.fromTOML ./devshell.toml;
        }
      ) // {

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
