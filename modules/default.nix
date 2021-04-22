# Evaluate the devshell environment
{ pkgs, sources }:
{ configuration
, lib ? pkgs.lib
, extraSpecialArgs ? { }
}:
let
  devenvModules = import ./modules.nix {
    inherit pkgs lib sources;
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

  shell = module.config.devshell.shell;
}
