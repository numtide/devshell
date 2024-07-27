{
  system ? builtins.currentSystem,
  inputs ? import ../flake.lock.nix { },
  pkgs ? import inputs.nixpkgs {
    inherit system;
    # Makes the config pure as well. See <nixpkgs>/top-level/impure.nix:
    config = { };
    overlays = [ ];
  },
}:
let
  devshell = import ../. {
    inputs = null;
    nixpkgs = pkgs;
  };
  runTest =
    name: attrs: script:
    pkgs.runCommand name attrs ''
      source ${./assert.sh}

      # Needed by devshell
      export PRJ_ROOT=$PWD

      ${script}

      touch $out
    '';

  # Arguments to pass to each test file
  attrs = {
    inherit pkgs devshell runTest;
  };

  # Attrs marked with this attribute are recursed into by nix-build
  recursive = {
    recurseForDerivations = true;
  };

  loadDir =
    testPrefix: dir:
    let
      data = builtins.readDir dir;
      op =
        sum: name:
        let
          path = "${dir}/${name}";
          type = data.${name};
          # Nix doesn't recurse into attrs that have dots in them...
          attr = builtins.replaceStrings [ "." ] [ "-" ] (pkgs.lib.removeSuffix ".nix" name);

          args = attrs // {
            # Customize runTest
            runTest = name: runTest "${testPrefix}.${attr}.${name}";
          };
        in
        assert type == "regular";
        sum // { "${attr}" = recursive // (import path args); };
    in
    builtins.foldl' op recursive (builtins.attrNames data);
in
{
  recurseForDerivations = true;
  core = loadDir "tests.core" (toString ./core);
  extra = loadDir "tests.extra" (toString ./extra);
}
