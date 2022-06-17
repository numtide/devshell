{ pkgsets
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
        branch = "master";
      }];
    }
  ];

  pkgsModule = { config, ... }: {
    config = {
      _module.args.baseModules = modules;
      _module.args.pkgs = lib.mkDefault pkgsets.nixpkgs;
      _module.args.pkgsPath = lib.mkDefault pkgsets.nixpkgs.path;
      _module.args.pkgsets = lib.mkDefault pkgsets;
    };
  };
in
[ pkgsModule ] ++ modules
