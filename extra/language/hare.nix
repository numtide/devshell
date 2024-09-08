{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.language.hare;
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };
  makeHareFullPath =
    userHareLibs:
    let
      allHareThirdPartyLibs = builtins.attrValues (pkgs.hareThirdParty.packages pkgs);
      propagatedLibs = lib.unique (
        builtins.foldl' (
          acc: userLib: acc ++ (lib.intersectLists userLib.propagatedBuildInputs allHareThirdPartyLibs)
        ) [ ] userHareLibs
      );
    in
    lib.makeSearchPath "src/hare/third-party" (userHareLibs ++ propagatedLibs);
in
with lib;
{
  options.language.hare = {
    thirdPartyLibs = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      example = literalExpression "[ hareThirdParty.hare-compress ]";
      description = "List of extra packages (coming from hareThirdParty) to add";
    };
    vendoredLibs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = literalExpression "[ ./vendor/lib ]";
      description = "List of paths to add to HAREPATH";
    };
    package = mkOption {
      type = strOrPackage;
      default = pkgs.hare;
      example = literalExpression "pkgs.hare";
      description = "Which Hare package to use";
    };
  };

  config = {
    env = [
      {
        name = "HAREPATH";
        value = lib.makeSearchPath "src/hare/stdlib" [ cfg.package ];
      }
      (mkIf (cfg.thirdPartyLibs != [ ]) {
        name = "HAREPATH";
        prefix = makeHareFullPath cfg.thirdPartyLibs;
      })
      (mkIf (cfg.vendoredLibs != [ ]) {
        name = "HAREPATH";
        prefix = concatStringsSep ":" cfg.vendoredLibs;
      })
    ];
    devshell.packages = [ cfg.package ];
  };
}
