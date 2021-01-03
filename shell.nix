#!/usr/bin/env nix-build
# Used to test the shell
{ system ? builtins.currentSystem
, pkgs ? import ./nix { inherit system; }
}:
pkgs.mkDevShell.fromTOML ./devshell.toml
