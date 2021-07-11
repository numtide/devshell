{ lib, pkgs }:
with lib;
let

  pkgOpt = {
    pkg = mkOption {
      type = types.either types.str types.package;
      description = ''
        The derivation of this package.
      '';
      example = "hello";
    };
    prio = mkOption = {
      type = types.nullOr (types.either (types.enum [ "low" "high" ]) types.int);
      description = ''
        The priority of this package in the shell environment.

        Left to default if null.
      '';
      default = null;
      example = "high";
    };
  };

  strOrAttrs =
    types.coercedTo
      types.str
      (pkg: { inherit pkg; })
      (types.submodule { options = pkgOpt; });

  # Because we want to be able to push pure JSON-like data into the environment.
  resolveKey = key:
    let
      attrs = builtins.filter builtins.isString (builtins.split "\\." key);
      op = sum: attr: sum.${attr} or (throw "package \"${key}\" not found");
    in
    builtins.foldl' op pkgs attrs;

  coercePkgOpt = opt:
    let
      pkg = if isString opt.pkg then resolveKey opt.pkg else opt.pkg;
    in
      if isNull opt.prio then pkg
      else if opt.prio == "low" then lowPrio pkg
      else if opt.prio == "high" then hiPrio pkg
      else setPrio opt.prio pkg;
in
types.coercedTo strOrAttrs coercePkgOpt types.package
