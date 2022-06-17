{ lib, pkgsets }:
with lib;
let
  resolveKey = key:
    let
      attrs = builtins.filter builtins.isString (builtins.split "\\." key);
      op = sum: attr: sum.${attr} or sum.nixpkgs.${attr} or (throw "package \"${key}\" not found");
    in
    builtins.foldl' op pkgsets attrs;
in
# Because we want to be able to push pure JSON-like data into the environment.
types.coercedTo types.str resolveKey types.package
