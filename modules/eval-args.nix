# Arguments for `lib.evalModules` or `types.submoduleWith`.
{
  pkgs,
  lib,
  modules ? [ ],
  extraSpecialArgs ? { },
}:
let
  devenvModules = import ./modules.nix { inherit lib pkgs; };
in
{
  modules = (lib.toList modules) ++ devenvModules;
  specialArgs = {
    modulesPath = builtins.toString ./.;
    extraModulesPath = builtins.toString ../extra;
  } // extraSpecialArgs;
}
