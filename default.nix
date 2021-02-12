{ system ? builtins.currentSystem
, pkgs ? import (import ./nix/nixpkgs.nix) { inherit system; }
}:
rec {
  # CLI
  cli = pkgs.callPackage ./devshell { };

  # Get the modules documentation from an empty evaluation
  modules-docs = (eval
    {
      configuration = {
        # Load all of the extra modules so they appear in the docs
        imports =
          let dir = builtins.readDir extraModulesDir; in
          map
            (str: import "${extraModulesDir}/${str}")
            (builtins.attrNames dir);
      };
    }
  ).config.modules-docs;

  # Docs
  docs = pkgs.callPackage ./docs { inherit modules-docs; };

  # Tests
  tests = import ./tests { inherit pkgs system; };

  # Evaluate the devshell module
  eval = import ./modules pkgs;

  # Folder that contains all the extra modules
  extraModulesDir = toString ./modules_extra;

  # Loads a Nix module from TOML.
  importTOML =
    let
      extraModules = builtins.readDir extraModulesDir;
    in
    file:
    let
      dir = toString (builtins.dirOf file);
      data = builtins.fromTOML (builtins.readFile file);

      importModule = str:
        let
          repoFile = "${dir}/${str}";
          extraFile =
            "${extraModulesDir}/${pkgs.lib.removePrefix "extra." str}.nix";
        in
        # Load from the extra modules if it starts with extra.
        if pkgs.lib.hasPrefix "extra." str then import extraFile
        # Otherwise look in the repo
        else import repoFile;
    in
    {
      _file = file;
      imports = map importModule (data.imports or [ ]);
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
