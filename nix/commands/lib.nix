{ system ? builtins.currentSystem
, pkgs ? import ../nixpkgs.nix { inherit system; }
, options ? { }
, config ? { }
}:
(import ./types.nix { inherit pkgs options; }) //
(import ./devshell.nix { inherit pkgs config; }) //
(import ./commandsType.nix { inherit pkgs options; })
