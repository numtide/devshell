{ lib, config, pkgsets, ... }:
let
  cfg = config.language.go;
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgsets; };
in
with lib;
{
  options.language.go = {
    GO111MODULE = mkOption {
      type = types.enum [ "on" "off" "auto" ];
      default = "on";
      description = "Enable Go modules";
    };

    package = mkOption {
      type = strOrPackage;
      default = pkgsets.nixpkgs.go;
      example = literalExpression "nixpkgs.go";
      description = "Which go package to use";
    };
  };

  config = {
    env = [{
      name = "GO111MODULE";
      value = cfg.GO111MODULE;
    }];

    devshell.packages = [ cfg.package ];
  };
}
