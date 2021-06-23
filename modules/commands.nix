{ lib, config, pkgs, ... }:
with lib;
let
  ansi = import ../nix/ansi.nix;

  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage = import ../nix/strOrPackage.nix { inherit lib pkgs; };

  writeDefaultShellScript = import ../nix/writeDefaultShellScript.nix {
    inherit (pkgs) lib writeTextFile bash;
  };

  pad = str: num:
    if num > 0 then
      pad "${str} " (num - 1)
    else
      str;

  # Fill in default options for a command.
  commandToPackage = cmd:
    assert lib.assertMsg (cmd.command == null || cmd.name != cmd.command) "[[commands]]: ${toString cmd.name} cannot be set to both the `name` and the `command` attributes. Did you mean to use the `package` attribute?";
    assert lib.assertMsg (cmd.package != null || (cmd.command != null && cmd.command != "")) "[[commands]]: ${name} expected either a command or package attribute.";
    if cmd.package == null then
      writeDefaultShellScript
        {
          name = cmd.name;
          text = cmd.command;
          binPrefix = true;
        }
    else
      cmd.package;

  commandsToMenu = cmds:
    let
      cleanName = { name, package, ... }@cmd:
        assert lib.assertMsg (cmd.name != null || cmd.package != null) "[[commands]]: some command is missing both a `name` or `package` attribute.";
        # Fallback to the package pname if the name is unset
        let
          name =
            if cmd.name == null then
              cmd.package.pname or (builtins.parseDrvName cmd.package.name).name
            else
              cmd.name;

          help =
            if cmd.help == null then
              cmd.package.meta.description or ""
            else
              cmd.help;
        in
        cmd // {
          inherit name help;
        };

      commands = map cleanName cmds;

      pushDownExtras = { package, extra, ... }@cmd:
        assert lib.assertMsg (package != null || extra == [ ]) "[[commands]]: ${cmd.name} cannot specify `extra` commands without a `package` attribute.";
        [ cmd ] ++ cmd.extra;

      allCommands = concatMap pushDownExtras commands;

      commandLengths =
        map ({ name, ... }: builtins.stringLength name) allCommands;

      maxCommandLength =
        builtins.foldl'
          (max: v: if v > max then v else max)
          0
          commandLengths
      ;

      commandCategories = lib.unique (
        (zipAttrsWithNames [ "category" ] (name: vs: vs) allCommands).category
      );

      commandByCategoriesSorted =
        builtins.attrValues (lib.genAttrs
          commandCategories
          (category: lib.nameValuePair category (builtins.sort
            (a: b: a.name < b.name)
            (builtins.filter (x: x.category == category) allCommands)
          ))
        );

      opCat = kv:
        let
          category = kv.name;
          cmd = kv.value;
          opCmd = { name, help, ... }:
            let
              len = maxCommandLength - (builtins.stringLength name);
            in
            if help == null || help == "" then
              "  ${name}"
            else
              "  ${pad name len} - ${help}";
        in
        "\n${ansi.bold}[${category}]${ansi.reset}\n\n" + builtins.concatStringsSep "\n" (map opCmd cmd);
    in
    builtins.concatStringsSep "\n" (map opCat commandByCategoriesSorted) + "\n";

  # Options available to all commands
  commonCommandOptions = {
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
  };

  # Options only available to extra commands
  extraCommandOptions = commonCommandOptions // {
    name = mkOption {
      type = types.str;
      description = ''
        Name of this command.
      '';
    };
  };

  # Options only available to basic commands
  commandOptions = commonCommandOptions // {
    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Name of this command. Defaults to attribute name in commands.
      '';
    };

    command = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        If defined, it will add a script with the name of the command, and the
        content of this value.

        By default it generates a bash script, unless a different shebang is
        provided.
      '';
      example = ''
        #!/usr/bin/env python
        print("Hello")
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

    extra = mkOption {
      type = types.listOf (types.submodule { options = extraCommandOptions; });
      default = [ ];
      description = ''
        Extra commands for extra programs brought in by the command's package.
        Note this only allows to add a menu entry, it won't bring a specific
        package or command in the environment.
        It can't be used if the base command doesn't specify a package.
      '';
    };
  };
in
{
  options.commands = mkOption {
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

  config.commands = [
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

  # Add the commands to the devshell packages. Either as wrapper scripts, or
  # the whole package.
  config.devshell.packages = map commandToPackage config.commands;
  # config.devshell.motd = "$(motd)";
}
