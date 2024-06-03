{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.language.hare;
  strOrPackage = import ../../nix/strOrPackage.nix {inherit lib pkgs;};
  makeHareFullPath = thirdParty: let
    allHareThirdPartyPkgs = builtins.attrValues (pkgs.hareThirdParty.packages pkgs);
    isPropagatedLib = drv: builtins.any (x: drv == x) allHareThirdPartyPkgs;
    pkgsPropagatedBuildInputs = builtins.foldl' (acc: e: acc ++ e.propagatedBuildInputs) [] thirdParty;
    propagatedLibs = builtins.filter isPropagatedLib pkgsPropagatedBuildInputs;
  in
    lib.makeSearchPath
    "src/hare/third-party"
    (thirdParty ++ propagatedLibs);
in
  with lib; {
    options.language.hare = {
      thirdPartyLibs = mkOption {
        type = types.listOf strOrPackage;
        default = [];
        example = literalExpression "[ hareThirdParty.hare-compress ]";
        description = "List of extra packages (coming from hareThirdParty) to add";
      };
      vendoredLibs = mkOption {
        type = types.listOf types.str;
        default = [];
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
        (mkIf (cfg.thirdPartyLibs != [] || cfg.vendoredLibs != []) {
          name = "HAREPATH";
          value = lib.makeSearchPath "src/hare/stdlib" [cfg.package];
        })
        (mkIf (cfg.thirdPartyLibs != []) {
          name = "HAREPATH";
          prefix = makeHareFullPath cfg.thirdPartyLibs;
        })
        (mkIf (cfg.vendoredLibs != []) {
          name = "HAREPATH";
          prefix = concatStringsSep ":" cfg.vendoredLibs;
        })
      ];
      devshell.packages = [cfg.package];
    };
  }
