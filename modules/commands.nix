{ lib, config, pkgs, ... }:
let
  inherit (import ../nix/commands/convert.nix { inherit pkgs; }) commandsToMenu commandToPackage;
  inherit (import ../nix/commands/devshellMenu.nix { inherit pkgs; }) mkDevshellMenuCommand;
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

  # Add the commands to the devshell packages. Either as wrapper scripts, or
  # the whole package.
  config.devshell.packages = map commandToPackage ([ (mkDevshellMenuCommand config.commands) ] ++ config.commands);
  # config.devshell.motd = "$(motd)";
}
