{ lib, pkgs }:
with lib;
let

  pkgOpt = {
    package = mkOption {
      type = types.either types.str types.package;
      description = ''
        The derivation of this package.
      '';
      example = "hello";
    };
    priority = mkOption = {
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
      (package: { inherit package; })
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
      pkg =
        if isString opt.package then resolveKey opt.package
        else opt.package;
    in
      if isNull opt.priority then pkg
      else if opt.priority == "low" then lowPrio pkg
      else if opt.priority == "high" then hiPrio pkg
      else setPrio opt.priority pkg;
in
types.coercedTo strOrAttrs coercePkgOpt types.package
