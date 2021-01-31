{ system ? builtins.currentSystem
, pkgs ? import (import ../nix/nixpkgs.nix) { inherit system; }
}:
let
  devshell = import ../. { inherit pkgs; };
  attrs = { inherit pkgs devshell; };
in
{ recurseForDerivations = true; }
// (import ./commands.nix attrs)
// (import ./devshell.nix attrs)
// (import ./git-hooks.nix attrs)
// (import ./modules-docs.nix attrs)
// (import ./nix-shell.nix attrs)
  // { }
