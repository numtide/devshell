{ lib, pkgs }:
let
  resolveKey =
    key:
    let
      attrs = builtins.filter builtins.isString (builtins.split "\\." key);
      op = sum: attr: sum.${attr} or (throw "package \"${key}\" not found");
    in
    builtins.foldl' op pkgs attrs;
in
# Because we want to be able to push pure JSON-like data into the environment.
lib.types.coercedTo lib.types.str resolveKey lib.types.package
