#!/usr/bin/env nix-build
# Used to test the shell
{ pkgs ? import ./. { } }:
pkgs.mkDevShell {
  imports = [
    (pkgs.mkDevShell.importTOML ./devshell.toml)
    ./extensions/options.nix
  ];
}
