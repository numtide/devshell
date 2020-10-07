#!/usr/bin/env nix-build
# Used to test the shell
{ pkgs ? import ./. { } }:
pkgs.mkDevShell.fromTOML ./devshell.toml
