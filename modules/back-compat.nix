{ lib, pkgs, config, ... }:
# Avoid breaking back-compat for now.
let
  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage = import ../nix/strOrPackage.nix { inherit lib pkgs; };
in
with lib;
{
  options = {
    bash.extra = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra commands to run in bash on environment startup.
      '';
    };

    bash.interactive = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Same as shellHook, but is only executed on interactive shells.

        This is useful to setup things such as custom prompt commands.
      '';
    };

    env = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Environment variables to add to the environment.

        If the value is null, it will unset the environment variable.
        Otherwise, the value will be converted to string before being set.
      '';
      example = {
        GO111MODULE = "on";
        HTTP_PORT = 8080;
      };
    };

    motd = mkOption {
      type = types.nullOr types.str;
      default = null;
      internal = true;
    };

    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      internal = true;
    };

    packages = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      internal = true;
    };
  };

  config = {
    # Expose the path to nixpkgs
    env.NIXPKGS_PATH = toString pkgs.path;

    devshell =
      {
        packages = config.packages;
        startup.bash_extra = noDepEntry config.bash.extra;
        interactive.bash_interactive = noDepEntry config.bash.interactive;
      }
      // (lib.optionalAttrs (config.motd != null) { motd = config.motd; })
      // (lib.optionalAttrs (config.name != null) { name = config.name; })
      # TODO: move bash.extra into the activation script
      # TODO: move bash.interactive into the activation script
      # TODO: move env to its own module
    ;
  };
}
