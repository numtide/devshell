{ pkgs
, lib
}:
let
  modules = [
    ./back-compat.nix
    ./commands.nix
    ./devshell.nix
    ./env.nix
    ./modules-docs.nix
    {
      # Configure modules-docs
      config.modules-docs.roots = [{
        url = "https://github.com/numtide/devshell";
        path = toString ../.;
        branch = "main";
      }];
    }
  ];

  pkgsModule = { config, ... }: {
    config = {
      _module.args.baseModules = modules;
      _module.args.pkgsPath = lib.mkDefault pkgs.path;
      _module.args.pkgs = lib.mkDefault pkgs;
      _module.args._devshelltoml = config.lib._tomlfile or null; # set by importTOML
    };
  };
in
[ pkgsModule ] ++ modules
