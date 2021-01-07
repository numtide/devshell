#!/usr/bin/env nix-build
# Used to test the shell
{ system ? builtins.currentSystem }:
(import ./. { inherit system; }).devshell-shell
