{ lib, pkgs, config, ... }:
with lib;
let
  resolveKey = key:
    let
      attrs = builtins.filter builtins.isString (builtins.split "\\." key);
    in
    builtins.foldl' (sum: attr: sum.${attr}) pkgs attrs
  ;

  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage =
    types.coercedTo types.str resolveKey types.package;

  # These are all the options available for the commands.
  commandOptions = {
    name = mkOption {
      type = types.nullOr types.str;
      # default = null;
      description = ''
        Name of this command. Defaults to attribute name in commands.
      '';
    };

    help = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Describes what the command does in one line of text.
      '';
    };

    alias = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        If defined, will define an alias for the command.

        Aliases are only usable in Bash, in interactive mode.
      '';
    };

    package = mkOption {
      type = types.nullOr strOrPackage;
      default = null;
      description = ''
        Used to bring in a specific package. This package will be added to the
        environment.
      '';
    };
  };
in
{
  options = {
    name = mkOption {
      type = types.str;
      default = "devshell";
      description = ''
        Name of the shell environment. It usually maps to the project name.
      '';
    };

    # TODO: rename motd to something better.
    motd = mkOption {
      type = types.str;
      default = "$(devshell-menu)";
      description = ''
        Message Of The Day.

        This is the welcome message that is being printed when the user opens
        the shell.
      '';
    };

    commands = mkOption {
      type = types.listOf (types.submodule { options = commandOptions; });
      default = [ ];
      description = ''
        Add commands to the environment.
      '';
      example = literalExample ''
        [
          {
            help = "print hello";
            name = "hello";
            alias = "echo hello";
          }

          {
            help = "used to format nix code";
            package = pkgs.nixpkgs-fmt;
          }
        ]
      '';
    };

    bash = mkOption {
      type = types.submodule {
        options = {
          extra = mkOption {
            type = types.lines;
            default = "";
            description = ''
              Extra commands to run in bash on environment startup.
            '';
          };

          interactive = mkOption {
            type = types.lines;
            default = "";
            description = ''
              Same as shellHook, but is only executed on interactive shells.

              This is useful to setup things such as custom prompt commands.
            '';
          };
        };
      };
    };

    env = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Environment variables to add to the environment.
      '';
      example = {
        GO111MODULE = "on";
        HTTP_PORT = 8080;
      };
    };

    packages = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = ''
        A list of packages to add to the environment.

        If the packages are passed as string, they will be retried from
        nixpkgs with the same attribute name.
      '';
    };

  };

  config = {
    commands = [
      {
        help = "print this menu";
        name = "devshell-menu";
      }
      {
        help = "change directory to root";
        name = "devshell-root";
        alias = ''cd "$DEVSHELL_ROOT"'';
      }
    ];

    packages =
      builtins.filter (x: x != null)
        (map (x: x.package) config.commands);
  };
}
