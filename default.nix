{ nixpkgs ? import ./nix/nixpkgs.nix
, system ? builtins.currentSystem
}:
import nixpkgs {
  inherit system;
  overlays = [ (import ./overlay.nix) ];
}
