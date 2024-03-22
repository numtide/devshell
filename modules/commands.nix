{ lib, config, pkgs, options, ... }:
let
  inherit (import ../nix/commands/lib.nix { inherit pkgs options config; })
    commandsType
    commandToPackage
    devshellMenuCommandName
    commandsToMenu
    ;
in
{
  options.commands = lib.mkOption {
    type = commandsType;
    default = [ ];
    description = ''
      Add commands to the environment.
    '';
    example = lib.literalExpression ''
      {
        packages = [
          "diffutils"
          "goreleaser"
        ];
        scripts = [
          {
            prefix = "nix run .#";
            inherit packages;
          }
          {
            name = "nix fmt";
            help = "format Nix files";
          }
        ];
        utilites = [
          [ "GitHub utility" "gitAndTools.hub" ]
          [ "golang linter" "golangci-lint" ]
        ];
      }
    '';
  };

  config.commands = [
    {
      help = "prints this menu";
      name = devshellMenuCommandName;
      command = commandsToMenu config.devshell.menu config.commands;
    }
  ];

  # Add the commands to the devshell packages. Either as wrapper scripts, or
  # the whole package.
  config.devshell.packages =
    lib.filter
      (x: x != null)
      (map commandToPackage config.commands);

  # config.devshell.motd = "$(motd)";
}
