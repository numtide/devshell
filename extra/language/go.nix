{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.language.go;
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };
in
with lib;
{
  options.language.go = {
    GO111MODULE = mkOption {
      type = types.enum [
        "on"
        "off"
        "auto"
      ];
      default = "on";
      description = "Enable Go modules";
    };

    package = mkOption {
      type = strOrPackage;
      default = pkgs.go;
      example = literalExpression "pkgs.go";
      description = "Which go package to use";
    };
  };

  config = {
    env = [
      {
        name = "GO111MODULE";
        value = cfg.GO111MODULE;
      }
    ];

    devshell.packages = [ cfg.package ];
  };
}
