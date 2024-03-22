{ system ? builtins.currentSystem
, pkgs ? import ../nixpkgs.nix { inherit system; }
, lib ? pkgs.lib
}:
with lib;
with builtins;
rec {
  # find a package corresponding to the string
  resolveKey = arg:
    if isString arg && lib.strings.sanitizeDerivationName arg == arg then
      attrByPath (splitString "\." arg) null pkgs
    else if isDerivation arg then
      arg
    else null;

  strOrPackage = types.coercedTo types.str resolveKey types.package;

  list2Of = t1: t2: mkOptionType {
    name = "list2Of";
    description = "list with two elements of types: [ ${
      concatMapStringsSep " " (types.optionDescriptionPhrase (class: class == "noun" || class == "composite")) [ t1 t2 ]
    } ]";
    check = x: isList x && length x == 2 && t1.check (head x) && t2.check (last x);
    merge = mergeOneOption;
  };

  flatOptions = import ./flatOptions.nix { inherit lib strOrPackage flatOptionsType; };

  mkAttrsToString = str: { __toString = _: str; };

  mkLocLast = name: mkAttrsToString " (${name})";

  flatOptionsType =
    let submodule = types.submodule { options = flatOptions; }; in
    submodule // rec {
      name = "flatOptions";
      description = name;
      getSubOptions = prefix: (mapAttrs
        (name_: value: value // {
          loc = prefix ++ [
            name_
            (mkLocLast name)
          ];
          declarations = [ "${toString ../..}/nix/commands/flatOptions.nix" ];
        })
        (submodule.getSubOptions prefix));
    };

  pairHelpPackageType = list2Of types.str strOrPackage;

  flatConfigType =
    (
      types.oneOf [
        strOrPackage
        pairHelpPackageType
        flatOptionsType
      ]
    ) // {
      getSubOptions = prefix: {
        flat = flatOptionsType.getSubOptions prefix;
      };
    }
  ;

  commandsFlatType = types.listOf flatConfigType // {
    name = "commandsFlat";
    getSubOptions = prefix: {
      fakeOption = (
        mkOption
          {
            type = flatConfigType;
            description = ''
              A config for a command when the `commands` option is a list.
            '';
            example = literalExpression ''
              [
                {
                  category = "scripts";
                  package = "black";
                }
                [ "[package] print hello" "hello" ]
                "nodePackages.yarn"
              ]
            '';
          }
      ) // {
        loc = prefix ++ [ "*" ];
        declarations = [ "${toString ../..}/nix/commands/types.nix" ];
      };
    };
  };
}
