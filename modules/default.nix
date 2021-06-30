# Evaluate the devshell environment
pkgs:
{ configuration
, lib ? pkgs.lib
, extraSpecialArgs ? { }
}:
let
  devenvModules = import ./modules.nix {
    inherit pkgs lib;
  };

  module = lib.evalModules {
    modules = [ configuration ] ++ devenvModules;
    specialArgs = {
      modulesPath = builtins.toString ./.;
      extraModulesPath = builtins.toString ../extra;
    } // extraSpecialArgs;
  };
in
{
  inherit (module) config options;

  shell = module.config.devshell.shell;
}
