# Used to test the shell
{ inNixShell ? false
, pkgs ? import <nixpkgs> { }
}:
let
  mkDevShell = pkgs.callPackage ./. { inherit inNixShell; };
in
mkDevShell.fromTOML ./devshell.toml
