{ system ? builtins.currentSystem
, pkgs ? import (import ./nix/nixpkgs.nix) { inherit system; }
}:
let
  # Small src cleaner.
  source = import ./nix/source.nix;
in
rec {
  devshell = pkgs.callPackage ./nix/devshell.nix { inherit source; };
  devshell-docs = pkgs.callPackage ./nix/mdbook.nix { inherit source; };
  mkDevShell = pkgs.callPackage ./nix/mkDevShell.nix { };

  # This project's shell
  devshell-shell = mkDevShell.fromTOML ./devshell.toml;
}
