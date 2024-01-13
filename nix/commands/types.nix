{ system ? builtins.currentSystem
, pkgs ? import ../nixpkgs.nix { inherit system; }
}:
let lib = builtins // pkgs.lib; in
rec {
  # find a package corresponding to the string
  resolveKey = arg:
    if lib.isString arg && lib.strings.sanitizeDerivationName arg == arg then
      lib.attrByPath (lib.splitString "\." arg) null pkgs
    else if lib.isDerivation arg then
      arg
    else null;

  strOrPackage = lib.types.coercedTo lib.types.str resolveKey lib.types.package;

  maxDepth = 100;

  attrsNestedOf = elemType:
    let elems = lib.genList (x: null) maxDepth; in
    lib.foldl
      (t: _: lib.types.attrsOf (lib.types.either elemType t) // {
        description = "(nested (max depth is ${toString maxDepth}) attribute set of ${
          lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
        })";
      })
      elemType
      elems;

  list2Of = t1: t2: lib.mkOptionType {
    name = "list2Of";
    description = "list with two elements of types: [ ${
      lib.concatMapStringsSep " " (lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite")) [ t1 t2 ]
    } ]";
    check = x: lib.isList x && lib.length x == 2 && t1.check (lib.head x) && t2.check (lib.last x);
    merge = lib.mergeOneOption;
  };

  flatOptions = import ./flatOptions.nix { inherit lib strOrPackage flatOptionsType; };

  mkAttrsToString = str: { __toString = _: str; };

  mkLocSuffix = name: mkAttrsToString " (${name})";

  flatOptionsType =
    let submodule = lib.types.submodule { options = flatOptions; }; in
    submodule // rec {
      name = "flatOptions";
      description = name;
      getSubOptions = prefix: (
        lib.mapAttrs
          (name_: value: value // {
            loc = prefix ++ [
              name_
              (mkLocSuffix name)
            ];
            declarations = [ "${toString ../..}/nix/commands/flatOptions.nix" ];
          })
          (submodule.getSubOptions prefix));
    };

  pairHelpPackageType = list2Of lib.types.str strOrPackage;

  pairHelpCommandType = list2Of lib.types.str lib.types.str;

  nestedOptions = import ./nestedOptions.nix {
    inherit
      pkgs strOrPackage attrsNestedOf pairHelpPackageType
      pairHelpCommandType flatOptionsType maxDepth
      nestedOptionsType;
  };

  nestedOptionsType =
    let submodule = lib.types.submodule { options = nestedOptions; }; in
    submodule // rec {
      name = "nestedOptions";
      description = name;
      check = x: (x?prefixes || x?packages || x?commands || x?helps || x?exposes) && submodule.check x;
      getSubOptions = prefix: (
        lib.mapAttrs
          (name_: value: value // {
            loc = prefix ++ [
              name_
              (mkAttrsToString " (${name})")
            ];
            declarations = [ "${toString ../..}/nix/commands/nestedOptions.nix" ];
          })
          (submodule.getSubOptions prefix));
    };

  nestedConfigType =
    (
      lib.types.oneOf [
        strOrPackage
        pairHelpPackageType
        nestedOptionsType
        flatOptionsType
      ]
    )
    // {
      getSubOptions = prefix: {
        "${flatOptionsType.name}" = flatOptionsType.getSubOptions prefix;
        "${nestedOptionsType.name}" = nestedOptionsType.getSubOptions prefix;
      };
    }
  ;

  flatConfigType =
    (
      lib.types.oneOf [
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

  commandsFlatType = lib.types.listOf flatConfigType // {
    name = "commandsFlat";
    getSubOptions = prefix: {
      fakeOption = (
        lib.mkOption
          {
            type = flatConfigType;
            description = ''
              A config for a command when the `commands` option is a list.
            '';
            example = lib.literalExpression ''
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

  commandsNestedType = lib.types.attrsOf (lib.types.listOf nestedConfigType) // {
    name = "commandsNested";
    getSubOptions = prefix: {
      fakeOption = (
        lib.mkOption {
          type = nestedConfigType;
          description = ''
            A config for command(s) when the `commands` option is an attrset.
          '';
          example = lib.literalExpression ''
            {
              category = [
                {
                  packages.grep = pkgs.gnugrep;
                }
                pkgs.python3
                [ "[package] vercel description" "nodePackages.vercel" ]
                "nodePackages.yarn"
              ];
            }
          '';
        }
      ) // {
        loc = prefix ++ [ "<name>" "*" ];
        declarations = [ "${toString ../..}/nix/commands/types.nix" ];
      };
    };
  };
}
