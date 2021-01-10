{ lib, config, pkgs, ... }:
with lib;
let
  ansi = import ../nix/ansi.nix;

  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage = import ../nix/strOrPackage.nix { inherit lib pkgs; };

  pad = str: num:
    if num > 0 then
      pad "${str} " (num - 1)
    else
      str;

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
              "  ${name}"
            else
              "  ${pad name len} - ${help}";
        in
        "\n${ansi.bold}[${name}]${ansi.reset}\n\n" + builtins.concatStringsSep "\n" (map opCmd value);
    in
    builtins.concatStringsSep "\n" (map opCat commandByCategoriesSorted) + "\n";

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
        menu="${commandsToMenu config.commands}"
        echo -e "$menu"
      '';
    }
  ];
}
