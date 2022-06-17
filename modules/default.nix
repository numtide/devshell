# Evaluate the devshell environment
pkgsets:
{ configuration
, lib ? pkgsets.nixpkgs.lib
, extraSpecialArgs ? { }
}:
let
  devenvModules = import ./modules.nix {
    inherit lib pkgsets;
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
