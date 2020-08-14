# Used to test the shell
{ pkgs ? import <nixpkgs> { } }:
let
  mkDevShell = pkgs.callPackage ./. { };
in
mkDevShell.fromTOML ./devshell.toml
