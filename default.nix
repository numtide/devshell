{ system ? builtins.currentSystem
, pkgs ? import (import ./nix/nixpkgs.nix) { inherit system; }
}:
let
  # Build a list of all the files, imported as Nix code, from a directory.
  importTree = dir:
    let
      data = builtins.readDir dir;
      op = sum: name:
        let
          path = "${dir}/${name}";
          type = data.${name};
        in
        sum ++
        (if type == "regular" then [ path ]
        # assume it's a directory
        else importTree path);
    in
    builtins.foldl' op [ ] (builtins.attrNames data);
in
rec {
  # CLI
  cli = pkgs.callPackage ./devshell { };

  # Folder that contains all the extra modules
  extraModulesDir = toString ./extra;

  # Get the modules documentation from an empty evaluation
  modules-docs = (eval {
    configuration = {
      # Load all of the extra modules so they appear in the docs
      imports = importTree extraModulesDir;
    };
  }).config.modules-docs;

  # Docs
  docs = pkgs.callPackage ./docs { inherit modules-docs; };

  # Tests
  tests = import ./tests { inherit pkgs system; };

  # Evaluate the devshell module
  eval = import ./modules pkgs;

  importTOML = import ./nix/importTOML.nix;

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
