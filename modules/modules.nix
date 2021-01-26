{ pkgs
, lib
}:
let
  modules = [
    ./back-compat.nix
    ./commands.nix
    ./devshell.nix
    ./modules-docs.nix
    {
      # Configure modules-docs
      config.modules-docs.roots = [{
        url = "https://github.com/numtide/devshell";
        path = ../.;
        branch = "master";
      }];
    }
    ./git-hooks.nix
  ];

  pkgsModule = { config, ... }: {
    config = {
      _module.args.baseModules = modules;
      _module.args.pkgsPath = lib.mkDefault pkgs.path;
      _module.args.pkgs = lib.mkDefault pkgs;
    };
  };
in
[ pkgsModule ] ++ modules
