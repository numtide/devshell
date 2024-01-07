{
  description = "devshell";
  # To update all inputs:
  # nix flake update
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem
    (system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        devshell = import ./. { nixpkgs = pkgs; };
      in
      rec {
        packages = {
          docs = pkgs.writeShellApplication {
            name = "docs";
            meta.description = ''Run mdBook server at http://localhost:3000'';
            runtimeInputs = [ pkgs.mdbook ];
            text = ''
              cd docs
              cp ${devshell.modules-docs.markdown} src/modules_schema.md
              mdbook serve
            '';
          };
          bench = pkgs.writeShellApplication {
            name = "benchmark";
            meta.description = ''Run benchmark'';
            runtimeInputs = [ pkgs.hyperfine ];
            text = ''
              cd benchmark
              hyperfine -w 3 \
                'nix-instantiate ../shell.nix' \
                'nix-instantiate ./devshell-nix.nix' \
                'nix-instantiate ./devshell-toml.nix' \
                'nix-instantiate ./nixpkgs-mkshell.nix'
            '';
          };
        };

        devShells.default = devshell.fromTOML ./devshell.toml;

        apps.default = devShells.default.flakeApp;

        checks =
          with pkgs.lib;
          pipe (import ./tests { inherit pkgs; }) [
            (collect isDerivation)
            (map (x: { name = x.name or x.pname; value = x; }))
            listToAttrs
          ];

        formatter = pkgs.nixpkgs-fmt;
      }
    ) // {
    # Import this overlay into your instance of nixpkgs
    overlays.default = import ./overlay.nix;

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

    lib.importTOML = import ./nix/importTOML.nix;

    flakeModule = ./flake-module.nix;
  }
  ;
}
