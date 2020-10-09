{ nixpkgs ? import ./nix/nixpkgs.nix
, system ? builtins.currentSystem
, overlays ? [ ]
}:
import nixpkgs {
  inherit system;
  overlays = [ (import ./overlay.nix) ] ++ overlays;
}
