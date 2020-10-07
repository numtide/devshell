{ nixpkgs ? <nixpkgs>
, system ? builtins.currentSystem
}:
import nixpkgs {
  inherit system;
  overlays = [ (import ./overlay.nix) ];
}
