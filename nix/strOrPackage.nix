{ lib, pkgs }:
with lib;
let
  pkgOpt = {
    pkg = mkOption {
      type = types.package;
      description = ''
        The derivation of this package.
      '';
      exampleText = "pkgs.hello";
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

  # Because we want to be able to push pure JSON-like data into the environment.
  coerceStr = str:
    let
      attrs = builtins.filter builtins.isString (builtins.split "\\." key);
      op = sum: attr: sum.${attr} or (throw "package \"${key}\" not found");
    in
    {
      pkg = builtins.foldl' op pkgs attrs;
    };

  strOrAttrs =
    types.coercedTo
      types.str
      coerceStr
      (types.submodule { options = pkgOpt; });

  coercePkgOpt = opt:
    if isNull opt.prio then opt.pkg
    else if opt.prio == "low" then lowPrio opt.pkg
    else if opt.prio == "high" then hiPrio opt.pkg
    else setPrio opt.prio opt.pkg;
in
types.coercedTo strOrAttrs coercePkgOpt types.package
