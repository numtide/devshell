{
  lib,
  pkgs,
  config,
  ...
}:
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
      internal = true;
      type = types.lines;
      default = "";
    };

    bash.interactive = mkOption {
      internal = true;
      type = types.lines;
      default = "";
    };

    motd = mkOption {
      internal = true;
      type = types.nullOr types.str;
      default = null;
    };

    name = mkOption {
      internal = true;
      type = types.nullOr types.str;
      default = null;
    };

    packages = mkOption {
      internal = true;
      type = types.listOf strOrPackage;
      default = [ ];
    };

    packagesFrom = mkOption {
      internal = true;
      type = types.listOf strOrPackage;
      default = [ ];
    };
  };

  # Copy the values over to the devshell module
  config.devshell =
    {
      packages = config.packages;
      packagesFrom = config.packagesFrom;
      startup.bash_extra = noDepEntry config.bash.extra;
      interactive.bash_interactive = noDepEntry config.bash.interactive;
    }
    // (lib.optionalAttrs (config.motd != null) { motd = config.motd; })
    // (lib.optionalAttrs (config.name != null) { name = config.name; });
}
