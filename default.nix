{
  system ? builtins.currentSystem,
  inputs ? import ./flake.lock.nix { },
  nixpkgs ? import inputs.nixpkgs {
    inherit system;
    # Makes the config pure as well. See <nixpkgs>/top-level/impure.nix:
    config = { };
    overlays = [ ];
  },
}:
let
  # Build a list of all the files, imported as Nix code, from a directory.
  importTree =
    dir:
    let
      data = builtins.readDir dir;
      op =
        sum: name:
        let
          path = "${dir}/${name}";
          type = data.${name};
        in
        sum
        ++ (
          if type == "regular" then
            [ path ]
          # assume it's a directory
          else
            importTree path
        );
    in
    builtins.foldl' op [ ] (builtins.attrNames data);
in
rec {
  # Folder that contains all the extra modules
  extraModulesPath = toString ./extra;

  # Alias for backward compatibility.
  extraModulesDir = extraModulesPath;

  # Get the modules documentation from an empty evaluation
  modules-docs =
    (eval {
      configuration = {
        # Load all of the extra modules so they appear in the docs
        imports = importTree extraModulesPath;
      };
    }).config.modules-docs;

  # Docs
  docs = nixpkgs.callPackage ./docs { inherit modules-docs; };

  # Tests
  tests = import ./tests {
    inherit system;
    inputs = null;
    pkgs = nixpkgs;
  };

  # Evaluate the devshell module
  eval = import ./modules nixpkgs;

  importTOML = import ./nix/importTOML.nix;

  # Build the devshell from a TOML declaration.
  fromTOML = path: mkShell (importTOML path);

  # A utility to build a "naked" nix-shell environment that doesn't contain
  # all of the default environment variables. This is mostly for internal use.
  mkNakedShell = nixpkgs.callPackage ./nix/mkNakedShell.nix { };

  # A developer shell that works in all scenarios
  #
  # * nix-build
  # * nix-shell
  # * flake app
  # * direnv integration
  # * setup hook for derivation or hercules ci effect
  mkShell = configuration: (eval { inherit configuration; }).shell;
}
