#!/usr/bin/env nix-build
# Used to test the shell
{
  system ? builtins.currentSystem,
}:
let
  devshell = import ./. { inherit system; };
in
devshell.fromTOML ./devshell.toml
