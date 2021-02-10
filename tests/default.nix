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
  attrs = { inherit pkgs devshell runTest; };
in
{ recurseForDerivations = true; }
// (import ./commands.nix attrs)
// (import ./devshell.nix attrs)
// (import ./git-hooks.nix attrs)
// (import ./modules-docs.nix attrs)
  // { }
