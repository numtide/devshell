{ lib, config, pkgs, ... }:
let
  cfg = config.language.go;
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };
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
      default = pkgs.go;
      example = literalExpression "pkgs.go";
      description = "Which go package to use";
    };

    GOPATH = mkOption {
      type = types.either types.path types.str;
      default = "$HOME/go";
      example = literalExpression "/home/user/go";
      description = "Path to your go directory";
    };
  };

  config = {
    env = [
      {
        name = "GO111MODULE";
        value = cfg.GO111MODULE;
      }
      {
        name = "GOPATH";
        eval = cfg.GOPATH;
      }
    ];

    devshell.packages = [ cfg.package ];
  };
}
