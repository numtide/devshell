{ pkgs
, strOrPackage
, attrsNestedOf
, pairHelpPackageType
, pairHelpCommandType
, flatOptionsType
, nestedOptionsType
, maxDepth
}:
with pkgs.lib;
let
  flat = name: "`${name} (${flatOptionsType.name})`";
  nested = name: "`${name} (${nestedOptionsType.name})`";
in
{
  prefix = mkOption {
    type = types.str;
    default = "";
    description = ''
      Can be used as ${flat "prefix"} for all
      ${nested "packages"} and ${nested "commands"}.
      
      Priority of this option when selecting a ${flat "prefix"}: `1`.
      
      Lowest priority: `1`.
    '';
    example = literalExpression ''
      {
        prefix = "nix run .#";
      }
    '';
  };

  prefixes = mkOption {
    type = attrsNestedOf types.str;
    default = { };
    description = ''
      A leaf value becomes ${flat "prefix"}
      of ${flat "package"} or ${flat "command"}
      with a matching path in ${nested "packages"} or ${nested "commands"}.

      Priority of this option when selecting a ${flat "prefix"}: `2`.
      
      Lowest priority: `1`.
    '';
    example = literalExpression ''
      {
        packages.a.b = pkgs.jq;
        prefixes.a.b = "nix run ../#";
      }
    '';
  };

  packages = mkOption {
    type =
      attrsNestedOf (
        types.oneOf [
          strOrPackage
          pairHelpPackageType
        ]
      );
    default = { };
    description = ''
      A leaf value:

      1. When a `string` with a value `<string>`,
         devshell tries to resolve a derivation
         `pkgs.<string>` and use it as ${flat "package"}.

      2. When a `derivation`, it's used as ${flat "package"}.

      3. When a list with two elements:
         1. The first element is a `string`
            that is used to select ${flat "help"}.
            
            Priority of this `string` (if present) when selecting ${flat "help"}: `4`.

            Lowest priority: `1`.
         2. The second element is interpreted as if
            the leaf value were initially a `string` or a `derivation`.
      
      A path to a leaf value is concatenated via `.`
      and used as ${flat "name"}.

      Priority of `package.meta.description` (if present in the resolved ${flat "package"}) 
      when selecting ${flat "help"}: `2`
      
      Lowest priority: `1`.

      A user may prefer to not bring to the environment some of the packages.
      
      Priority of `expose = false` when selecting ${flat "expose"}: `1`.
      
      Lowest priority: `1`.
    '';
    example = literalExpression ''
      {
        packages.a.b = pkgs.jq;
      }
    '';
  };

  commands = mkOption {
    type =
      attrsNestedOf (
        types.oneOf [
          types.str
          pairHelpCommandType
        ]
      );
    default = { };
    description = ''        
      A leaf value:

      1. When a `string`, it's used as ${flat "command"}.

      2. When a list with two elements:
         1. The first element of type `string` with a value `<string>`
            is used to select ${flat "help"}.

            Priority of the `<string>` (if present) when selecting ${flat "help"}: `4`

            Lowest priority: `1`.
         1. The second element of type `string` is used as ${flat "command"}.

      A path to the leaf value is concatenated via `.`
      and used as ${flat "name"}.
    '';
  };

  help = mkOption {
    type = types.str;
    default = "";
    description = ''
      Can be used as ${flat "hel"} for all
      ${nested "packages"} and ${nested "commands"}.

      Priority of this option when selecting a ${flat "help"}: `1`.
      
      Lowest priority: `1`.
    '';
    example = literalExpression ''
      {
        help = "default help";
      }
    '';
  };

  helps = mkOption {
    type = attrsNestedOf types.str;
    default = { };
    description = ''
      A leaf value can be used as ${flat "help"}
      for ${flat "package"} or ${flat "command"}
      with a matching path in ${nested "packages"} or ${nested "commands"}.

      Priority of this option when selecting ${flat "help"}: `3`.
      
      Lowest priority: `1`.
    '';
    example = literalExpression ''
      {
        packages.a.b = pkgs.jq;
        helps.a.b = "run jq";
      }
    '';
  };

  expose = mkOption {
    type = types.nullOr types.bool;
    default = null;
    description = ''
      Can be used as ${flat "expose"} for all
      ${nested "packages"} and ${nested "commands"}.
      
      Priority of this option when selecting ${flat "expose"}: `2`.
      
      When selecting ${flat "expose"} for
      - ${flat "package"}, priority of `false`: `1`.
      - ${flat "command"}, priority of `true`: `1`.
      
      Lowest priority: `1`.
    '';
    example = literalExpression ''
      {
        expose = true;
      }
    '';
  };

  exposes = mkOption {
    type = attrsNestedOf types.bool;
    default = { };
    description = ''
      A leaf value can be used as ${flat "expose"}
      for ${flat "package"} or ${flat "command"}
      with a matching path in ${nested "packages"} or ${nested "commands"}.

      Priority of this option when selecting ${flat "expose"}: `3`.
      
      When selecting ${flat "expose"} for
      - ${flat "package"}, priority of `false`: `1`.
      - ${flat "command"}, priority of `true`: `1`.

      Lowest priority: `1`.
    '';
    example = literalExpression ''
      {
        packages.a.b = pkgs.jq;
        exposes.a.b = true;
      }
    '';
  };
}
