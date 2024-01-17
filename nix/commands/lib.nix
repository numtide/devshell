{ system ? builtins.currentSystem
, pkgs ? import ../nixpkgs.nix { inherit system; }
, options ? { }
}:
(import ./types.nix { inherit pkgs options; }) //
(import ./devshell.nix { inherit pkgs; }) //
(import ./commandsType.nix { inherit pkgs options; })
