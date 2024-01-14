{ lib, config, pkgs, ... }:
let
  inherit (import ../nix/commands/devshell.nix { inherit pkgs; }) commandsToMenu commandToPackage devshellMenuCommandName;
  inherit (import ../nix/commands/types.nix { inherit pkgs; }) commandsFlatType;
in
{
  options.commands = lib.mkOption {
    type = commandsFlatType;
    default = [ ];
    description = ''
      Add commands to the environment.
    '';
    example = lib.literalExpression ''
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
      name = devshellMenuCommandName;
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
