{ system ? builtins.currentSystem
, pkgs ? import ../nixpkgs.nix { inherit system; }
}:
let
  lib = builtins // pkgs.lib;
  inherit (import ./types.nix { inherit pkgs; }) flatOptionsType;
  inherit (import ./convert.nix { inherit pkgs; }) commandsToMenu;
in
rec {
  devshellMenuCommandName = "menu";

  mkDevshellMenuCommand = commands: flatOptionsType.merge [ ] [
    {
      file = lib.unknownModule;
      value = {
        help = "prints this menu";
        name = devshellMenuCommandName;
        command = ''
          cat <<'DEVSHELL_MENU'
          ${commandsToMenu
            (
              let
                commands_ = [ commandMenu ] ++ commands;
                commandMenu = mkDevshellMenuCommand commands_;
              in
              commands_
            )
          }
          DEVSHELL_MENU
        '';
      };
    }
  ];
}
