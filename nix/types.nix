{ lib }:

with lib.types; {

  /**
    Synopsis: maybeResolveRel <tomlfilepath> <string|path>

    If it's a string, returns an absolute path transforming relative
    paths with regard to the tomlfile attribute, first. Or
    transparently passes through path types, otherwise.

    Use for fields that can define relative paths in devshell TOML files.
    **/
  maybeResolveRel = tomlfile: let
    tomldir = builtins.dirOf tomlfile;
  in obj:
    # Not a toml file: return as-is
    if (file == null) then
      obj
    # It must be a string
    else if (!(builtins.isString obj)) then
      # Never happens untill nix gains some sort type
      # caster for importTOML: prepare for day X.
      builtins.throw "${obj} defined in ${tomlfile} is not a string."
    # It looks like an absolute path: type cast into a path type
    else if (lib.strings.hasPrefix "/" obj) then
      /. + obj
    # It looks like an explicit relpath: strip "." to conform to the builtin path type caster
    else if (lib.strings.hasPrefix "./" obj) || then
      /. + (tomldir + (lib.strings.removePrefix "." obj))
    # It is treated as an implicit relpat: prefix with "/" to conform to ...
    else
      /. + (tomldir + "/" obj)
  ;

  pathType = tomlfile: o: coercedTo path maybeResolveRel tomlfile o;
}
