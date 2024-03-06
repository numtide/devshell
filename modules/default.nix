# Evaluate the devshell environment
nixpkgs:
{
  configuration,
  lib ? nixpkgs.lib,
  extraSpecialArgs ? { },
}:
let
  module = lib.evalModules (
    import ./eval-args.nix {
      inherit lib extraSpecialArgs;
      pkgs = nixpkgs;
      modules = [ configuration ];
    }
  );
in
{
  inherit (module) config options;

  shell = module.config.devshell.shell;
}
