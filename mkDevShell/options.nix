{ lib, pkgs, config, ... }:
with lib;
let
  resolveKey = key:
    let
      attrs = builtins.filter builtins.isString (builtins.split "\\." key);
      op = sum: attr: sum.${attr} or (throw "package \"${key}\" not found");
    in
    builtins.foldl' op pkgs attrs
  ;

  pad = str: num:
    if num > 0 then
      pad "${str} " (num - 1)
    else
      str
  ;

  ansiBoldOrange = "$(tput setaf 202)";
  ansiReset = "$(tput sgr0)";

  commandsToMenu = commands:
    let
      commandLengths =
        map ({ name, ... }: builtins.stringLength name) commands;

      maxCommandLength =
        builtins.foldl'
          (max: v: if v > max then v else max)
          0
          commandLengths
      ;

      commandCategories = lib.unique (
        (zipAttrsWithNames [ "category" ] (name: vs: vs) commands).category
      );

      commandByCategoriesSorted =
        builtins.attrValues (lib.genAttrs
          commandCategories
          (category: lib.nameValuePair category (builtins.sort
            (a: b: a.name < b.name)
            (builtins.filter
              (x: x.category == category)
              commands
            )
          ))
        );

      opCat = { name, value }:
        let
          opCmd = { name, help, ... }:
            let
              len = maxCommandLength - (builtins.stringLength name);
            in
            if help == null || help == "" then
              name
            else
              "${pad name len} - ${help}";
        in
        "\n[${name}]\n" + builtins.concatStringsSep "\n" (map opCmd value);
    in
    builtins.concatStringsSep "\n" (map opCat commandByCategoriesSorted)
  ;

  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage =
    types.coercedTo types.str resolveKey types.package;

  # These are all the options available for the commands.
  commandOptions = {
    name = mkOption {
      type = types.str;
      # default = null;
      description = ''
        Name of this command. Defaults to attribute name in commands.
      '';
    };

    category = mkOption {
      type = types.str;
      default = "general commands";
      description = ''
        Set a free text category under which this command is grouped
        and shown in the help menu.
      '';
    };

    help = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Describes what the command does in one line of text.
      '';
    };

    command = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        If defined, it will define a script for the command.
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
  serviceOptions = {
    name = mkOption {
      type = types.str;
    };
    command = mkOption {
      type = types.nullOr types.str;
      default = null;
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
      default = ''
        ${ansiBoldOrange}🔨 Welcome to ${config.name}${ansiReset}
        $(menu)
      '';
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

    services = mkOption {
      type = types.listOf (types.submodule { options = serviceOptions; });
      default = [ ];
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
      default = { };
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
        help = "prints this menu";
        name = "menu";
        command = ''
          cat <<'DEVSHELL_MENU'
          ${commandsToMenu config.commands}
          DEVSHELL_MENU
        '';
      }
    ];

    packages =
      builtins.filter
        (x: x != null)
        (map (x: x.package) config.commands);
  };
}
