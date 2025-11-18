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

  commandsToMenu =
    cmds:
    let
      inherit (config) commands;

      commandLengths =
        map ({ entry, ... }: builtins.stringLength entry) commands;

      maxCommandLength = builtins.foldl' (max: v: if v > max then v else max) 0 commandLengths;

      commandCategories = lib.unique (
        (zipAttrsWithNames [ "category" ] (name: vs: vs) commands).category
      );

      commandByCategoriesSorted =
        builtins.attrValues (lib.genAttrs
          commandCategories
          (category: lib.nameValuePair category (builtins.sort
            (a: b: a.entry < b.entry)
            (builtins.filter (x: x.category == category) commands)
          ))
        );

      opCat =
        kv:
        let
          category = kv.name;
          cmd = kv.value;
          opCmd = { entry, help, ... }:
            let
              len = maxCommandLength - (builtins.stringLength entry);
            in
            if help == "" then "  ${entry}" else "  ${pad entry len} - ${help}";
        in
        "\n${ansi.bold}[${category}]${ansi.reset}\n\n" + builtins.concatStringsSep "\n" (map opCmd cmd);
    in
    builtins.concatStringsSep "\n" (map opCat commandByCategoriesSorted) + "\n";

  # This is the submodule defining all the options available for the commands.
  commandModule = { name, config, options, ... }: {
    options = {
      name = mkOption {
        type = types.str;
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
        default = if config.doc_only then "" else config.package.meta.description or "";
        description = ''
          Describes what the command does in one line of text.
        '';
      };

      command = mkOption {
        type = types.str;
        description = ''
          If defined, it will add a script with the name of the command, and
          the content of this value.

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
        default =
          if config.doc_only
          then null
          else
          (assert lib.assertMsg ((!config.doc_only) -> (options.name.isDefined && options.command.isDefined)) "[[commands]]: ${name}: expected either (1) a `name` and `command` attribute or (b) a `package` attribute (${if config.doc_only then "true" else "false"}).";
          assert lib.assertMsg (config.name != config.command) "[[commands]]: ${name}: cannot set both the `name` and the `command` attributes to the same value '${config.name}'. Did you mean to use the `package` attribute?";
          writeDefaultShellScript
            {
              name = config.name;
              text = config.command;
              binPrefix = true;
            });
        description = ''
          Used to bring in a specific package. This package will be added to
          the environment.
        '';
      };

      doc_only = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Indicate that this command is for documentation only.  Its name and
          help text will appear in the devshell menu, but no corresponding
          script will be added to the devshell environment.
        '';
      };

      warn_if_missing = mkOption {
        type = types.bool;
        default = config.doc_only;
        defaultText = "<command>.doc_only";
        description = ''
          When enabled, the devshell startup process will issue a warning if
          this command cannot be found (as determined by `command -v
          <command>`).

          Potentially useful for documentation-only commands
          (`<command>.doc_only`) that are expected to be available within the
          devshell environment but that are not explicitly installed by the
          devshell configuration.
        '';
      };

      program = mkOption {
        type = types.str;
        internal = true;
        readOnly = true;
        default =
          if options.name.isDefined
          then config.name
          else if config.package ? meta.mainProgram
          then config.package.meta.mainProgram
          else config.entry;
      };

      check = mkOption {
        type = types.functionTo types.nonEmptyStr;
        default = cmd: "command -v ${lib.escapeShellArg cmd.program}";
        description = '''';
      };

      entry = mkOption {
        type = types.str;
        internal = true;
        readOnly = true;
        default =
          if options.name.isDefined
          then config.name
          else config.package.pname or (builtins.parseDrvName config.package.name).name;
      };


      __toString = mkOption {
        type = types.functionTo types.str;
        internal = true;
        readOnly = true;
        default = self: self.entry;
      };
    };
  };
in
{
  options.commands = mkOption {
    type = types.listOf (types.submodule commandModule);
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
  config.devshell.packages = map (cmd: cmd.package) (lib.filter (cmd: !cmd.doc_only) config.commands);
  # config.devshell.motd = "$(motd)";

  config.devshell.startup.warn_if_missing_commands.text  = lib.pipe config.commands [
    (lib.filter (cmd: cmd.warn_if_missing))
    (map (cmd: ''
      ${cmd.check cmd} 1>/dev/null 2>&1 \
        || echo "${ansi.bold}${ansi."11"}warning:${ansi.reset} expected '${cmd.program}' to be available in ${config.devshell.name} but it is missing" 1>&2
    ''))
    (lib.concatStringsSep "\n")
  ];
}
