{ system ? builtins.currentSystem
, pkgs ? import ./nixpkgs.nix { inherit system; }
, lib ? pkgs.lib
}: (import ./commands/lib.nix { inherit pkgs; }).strOrPackage
