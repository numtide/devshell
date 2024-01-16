{ system ? builtins.currentSystem
, pkgs ? import ../nixpkgs.nix { inherit system; }
}:
(import ./types.nix { inherit pkgs; }) //
(import ./devshell.nix { inherit pkgs; }) //
(import ./commandsType.nix { inherit pkgs; })
