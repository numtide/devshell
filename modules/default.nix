# Evaluate the devshell environment
nixpkgs:
{ configuration
, lib ? nixpkgs.lib
, extraSpecialArgs ? { }
}:
let
  devenvModules = import ./modules.nix {
    pkgs = nixpkgs;
    inherit lib;
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
