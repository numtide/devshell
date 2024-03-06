{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkOption types;
in
{
  options = {
    perSystem = mkPerSystemOption (
      { config, pkgs, ... }:
      {
        options.devshells = mkOption {
          description = ''
            Configure devshells with flake-parts.

            Not to be confused with `devShells`, with a capital S. Yes, this
            is unfortunate.

            Each devshell will also configure an equivalent `devShells`.

            Used to define devshells. not to be confused with `devShells`
          '';

          type = types.lazyAttrsOf (
            types.submoduleWith (import ./modules/eval-args.nix { inherit pkgs lib; })
          );
          default = { };
        };
        config.devShells = lib.mapAttrs (_name: devshell: devshell.devshell.shell) config.devshells;
      }
    );
  };
}
