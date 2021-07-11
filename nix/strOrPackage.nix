{ lib, pkgs }:
with lib;
let

  resolveKey = key:
    let
      attrs = builtins.filter builtins.isString (builtins.split "\\." key);
      op = sum: attr: sum.${attr} or (throw "package \"${key}\" not found");
    in
    builtins.foldl' op pkgs attrs;

  pkgOpt = {
    package = mkOption {
      type = types.coercedTo types.str resolveKey types.package;
      description = ''
        The derivation of this package.
      '';
      example = "hello";
    };
    priority = mkOption {
      type = types.nullOr (types.either (types.enum [ "low" "high" ]) types.int);
      description = ''
        The priority of this package in the shell environment.

        Left to default if null.
      '';
      default = null;
      example = "high";
    };
  };

# Because we want to be able to push pure JSON-like data into the environment.
in
types.coercedTo
  types.str
  (package: { inherit package; })
  (types.submodule { options = pkgOpt; })
