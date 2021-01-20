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
    } // extraSpecialArgs;
  };
in
{
  inherit (module) config options;

  activationPackage = module.config.devshell.activationPackage;

  docs = module.config.devshell.docs;

  shell = module.config.devshell.shell;
}
