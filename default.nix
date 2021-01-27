{ system ? builtins.currentSystem
, pkgs ? import (import ./nix/nixpkgs.nix) { inherit system; }
}:
rec {
  # CLI
  cli = pkgs.callPackage ./devshell { };

  # Get the modules documentation from an empty evaluation
  modules-docs = (eval { configuration = { }; }).config.modules-docs;

  # Docs
  docs = pkgs.callPackage ./docs { inherit modules-docs; };

  # Tests
  tests = import ./tests { inherit pkgs system; };

  # Evaluate the devshell module
  eval = import ./modules pkgs;

  # Loads a Nix module from TOML.
  importTOML = file:
    let
      dir = builtins.dirOf file;
      data = builtins.fromTOML (builtins.readFile file);
    in
    {
      _file = file;
      imports = map (str: "${toString dir}/${str}") (data.imports or [ ]);
      config = builtins.removeAttrs data [ "imports" ];
    };

  # Build the devshell from a TOML declaration.
  fromTOML = path: mkShell (importTOML path);

  # A utility to build a "naked" nix-shell environment that doesn't contain
  # all of the default environment variables. This is mostly for internal use.
  mkNakedShell = pkgs.callPackage ./nix/mkNakedShell.nix { };

  # A developer shell that works in all scenarios
  #
  # * nix-build
  # * nix-shell
  # * flake app
  # * direnv integration
  mkShell = configuration:
    (eval { inherit configuration; }).shell;
}
