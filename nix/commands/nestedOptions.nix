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
{
  prefix = mkOption {
    type = types.nullOr types.str;
    default = "";
    description = ''
      Possible `(${flatOptionsType.name}) prefix`.
      
      Priority of this option when selecting a prefix: `1`.
      
      Lowest priority: `1`.
    '';
    example = literalExpression ''
      {
        prefix = "nix run .#";
      }
    '';
  };

  prefixes = mkOption {
    type = types.nullOr (attrsNestedOf types.str);
    default = { };
    description = ''
      A leaf value becomes a `(${flatOptionsType.name}) prefix`
      of a `package` (`command`) with a matching path in `packages` (`commands`).

      Priority of this option when selecting a prefix: `2`.
      
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
      types.nullOr (
        attrsNestedOf (types.oneOf [
          strOrPackage
          pairHelpPackageType
        ]));
    default = { };
    description = ''
      A nested (max depth is ${toString maxDepth}) attrset of `(${flatOptionsType.name}) package`-s
      to describe in the devshell menu
      and optionally bring to the environment.

      A path to a leaf value is concatenated via `.`
      and used as a `(${flatOptionsType.name}) name`.

      A leaf value can be of three types.
        
      1. When a `string` with a value `<string>`,
         devshell tries to resolve a derivation
         `pkgs.<string>` and use it as a `(${flatOptionsType.name}) package`.

      2. When a `derivation`, it's used as a `(${flatOptionsType.name}) package`.

      3. When a list with two elements:
         1. The first element is a `string`
            that is used to select a `(${flatOptionsType.name}) help`.
            - Priority of this `string` (if present) when selecting a `(${flatOptionsType.name}) help`: `4`.

              Lowest priority: `1`.
         2. The second element is interpreted as if
            the leaf value were initially a `string` or a `derivation`.
        
      Priority of `package.meta.description` (if present in the resolved `(${flatOptionsType.name}) package`) 
      when selecting a `(${flatOptionsType.name}) help`: 2
      
      Lowest priority: `1`.

      A user may prefer not to bring the environment some of the packages.
      
      Priority of `expose = false` when selecting a `(${flatOptionsType.name}) expose`: `1`.
      
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
      types.nullOr (
        attrsNestedOf (types.oneOf [
          types.str
          pairHelpCommandType
        ]));
    default = { };
    description = ''
      A nested (max depth is ${toString maxDepth}) attrset of `(${flatOptionsType.name}) command`-s
      to describe in the devshell menu
      and bring to the environment.

      A path to a leaf value is concatenated via `.`
      and used in the `(${flatOptionsType.name}) name`.

      A leaf value can be of two types.
        
      1. When a `string`, it's used as a `(${flatOptionsType.name}) command`.

      2. When a list with two elements:
         1. the first element of type `string` with a value `<string>`
            that is used to select a `help`;

            Priority of the `<string>` (if present) when selecting a `(${flatOptionsType.name}) help`: `4`

            Lowest priority: `1`.
         1. the second element of type `string` is used as a `(${flatOptionsType.name}) command`.
    '';
  };

  help = mkOption {
    type = types.nullOr types.str;
    default = "";
    description = ''
      Priority of this option when selecting a `(${flatOptionsType.name}) help`: `1`.
      
      Lowest priority: `1`.
    '';
    example = literalExpression ''
      {
        help = "default help";
      }
    '';
  };

  helps = mkOption {
    type = types.nullOr (attrsNestedOf types.str);
    default = { };
    description = ''
      A leaf value can be used as `(${flatOptionsType.name}) help`
      for a `(${flatOptionsType.name}) package` (`(${flatOptionsType.name}) command`) 
      with a matching path in `(${nestedOptionsType.name}) packages` (`(${nestedOptionsType.name}) commands`).

      Priority of this option when selecting a `(${flatOptionsType.name}) help`: `3`.
      
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
    default = false;
    description = ''
      When `true`, all `packages` can be added to the environment.
      
      Otherwise, they can not be added to the environment,
      but will be printed in the devshell description.
      
      Priority of this option when selecting a `(${flatOptionsType.name}) expose`: `2`.
      
      Lowest priority: `1`.
    '';
    example = literalExpression ''
      {
        expose = true;
      }
    '';
  };

  exposes = mkOption {
    type = types.nullOr (attrsNestedOf types.bool);
    default = { };
    description = ''
      A nested (max depth is ${toString maxDepth}) attrset of `(${flatOptionsType.name}) expose`-s.
      
      A leaf value can be used as `(${flatOptionsType.name}) expose` 
      for a `(${flatOptionsType.name}) package` (`(${flatOptionsType.name}) command`)
      with a matching path in `(${nestedOptionsType.name}) packages` (`(${nestedOptionsType.name}) commands`).

      Priority of this option when selecting a `(${flatOptionsType.name}) expose`: `3`.
      
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
