{
  system ? builtins.currentSystem,
}:
let
  pkgs = import (import ../nix/nixpkgs.nix) { inherit system; };
in
pkgs.mkShell { }
