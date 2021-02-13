{ system ? builtins.currentSystem
, pkgs ? import (import ../nix/nixpkgs.nix) { inherit system; }
}:
let
  devshell = import ../. { inherit pkgs; };
  runTest = name: attrs: script:
    pkgs.runCommand name attrs ''
      source ${./assert.sh}

      ${script}

      touch $out
    '';

  # Arguments to pass to each test file
  attrs = { inherit pkgs devshell runTest; };

  # Attrs marked with this attribute are recursed into by nix-build
  recursive = { recurseForDerivations = true; };

  loadDir = testPrefix: dir:
    let
      data = builtins.readDir dir;
      op = sum: name:
        let
          path = "${dir}/${name}";
          type = data.${name};
          # Nix doesn't recurse into attrs that have dots in them...
          attr = builtins.replaceStrings [ "." ] [ "-" ]
            (pkgs.lib.removeSuffix ".nix" name);

          args = attrs // {
            # Customize runTest
            runTest = name: runTest "${testPrefix}.${attr}.${name}";
          };
        in
        assert type == "regular";
        sum //
        {
          "${attr}" = recursive // (import path args);
        }
      ;
    in
    builtins.foldl' op recursive (builtins.attrNames data);
in
{
  recurseForDerivations = true;
  core = loadDir "tests.core" (toString ./core);
}
