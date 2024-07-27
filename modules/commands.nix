{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  ansi = import ../nix/ansi.nix;

  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage = import ../nix/strOrPackage.nix { inherit lib pkgs; };

  writeDefaultShellScript = import ../nix/writeDefaultShellScript.nix {
    inherit (pkgs) lib writeTextFile bash;
  };

  pad = str: num: if num > 0 then pad "${str} " (num - 1) else str;

  # Fallback to the package pname if the name is unset
  resolveName =
    cmd:
    if cmd.name == null then
      cmd.package.pname or (builtins.parseDrvName cmd.package.name).name
    else
      cmd.name;

  # Fill in default options for a command.
  commandToPackage =
    cmd:
    assert lib.assertMsg (cmd.command == null || cmd.name != cmd.command)
      "[[commands]]: ${toString cmd.name} cannot be set to both the `name` and the `command` attributes. Did you mean to use the `package` attribute?";
    assert lib.assertMsg (
      cmd.package != null || (cmd.command != null && cmd.command != "")
    ) "[[commands]]: ${resolveName cmd} expected either a command or package attribute.";
    if cmd.package == null then
      writeDefaultShellScript {
        name = cmd.name;
        text = cmd.command;
        binPrefix = true;
      }
    else
      cmd.package;

  commandsToMenu =
    cmds:
    let
      cleanName =
        { name, package, ... }@cmd:
        assert lib.assertMsg (
          cmd.name != null || cmd.package != null
        ) "[[commands]]: some command is missing both a `name` or `package` attribute.";
        let
          name = resolveName cmd;

          help = if cmd.help == null then cmd.package.meta.description or "" else cmd.help;
        in
        cmd // { inherit name help; };

      commands = map cleanName cmds;

      commandLengths = map ({ name, ... }: builtins.stringLength name) commands;

      maxCommandLength = builtins.foldl' (max: v: if v > max then v else max) 0 commandLengths;

      commandCategories = lib.unique (
        (zipAttrsWithNames [ "category" ] (name: vs: vs) commands).category
      );

      commandByCategoriesSorted = builtins.attrValues (
        lib.genAttrs commandCategories (
          category:
          lib.nameValuePair category (
            builtins.sort (a: b: a.name < b.name) (builtins.filter (x: x.category == category) commands)
          )
        )
      );

      opCat =
        kv:
        let
          category = kv.name;
          cmd = kv.value;
          opCmd =
            { name, help, ... }:
            let
              len = maxCommandLength - (builtins.stringLength name);
            in
            if help == null || help == "" then "  ${name}" else "  ${pad name len} - ${help}";
        in
        "\n${ansi.bold}[${category}]${ansi.reset}\n\n" + builtins.concatStringsSep "\n" (map opCmd cmd);
    in
    builtins.concatStringsSep "\n" (map opCat commandByCategoriesSorted) + "\n";

  # These are all the options available for the commands.
  commandOptions = {
    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Name of this command. Defaults to attribute name in commands.
      '';
    };

    category = mkOption {
      type = types.str;
      default = "[general commands]";
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
  };
in
{
  options.commands = mkOption {
    type = types.listOf (types.submodule { options = commandOptions; });
    default = [ ];
    description = ''
      Add commands to the environment.
    '';
    example = literalExpression ''
      [
        {
          help = "print hello";
          name = "hello";
          command = "echo hello";
        }

        {
          package = "nixpkgs-fmt";
          category = "formatter";
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
