{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.environment;

  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage = import ../nix/strOrPackage.nix { inherit lib pkgs; };
in
{
  options.environment = {
    packages = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = ''
        A list of packages to add to the environment.

        If the packages are passed as string, they will be retried from
        nixpkgs with the same attribute name.
      '';
    };

    variables = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Environment variables to add to the environment.

        If the value is null, it will unset the environment variable.
        Otherwise, the value will be converted to string before being set.
      '';
      example = {
        GO111MODULE = "on";
        HTTP_PORT = 8080;
      };
    };
  };

  config.environment = {
    packages =
      builtins.filter
        (x: x != null)
        (map (x: x.package) config.commands);

    # Expose the path to nixpkgs
    variables.NIXPKGS_PATH = toString pkgs.path;
  };

  config.devshell.paths =
    let
      op = { name, command, ... }:
        assert lib.assertMsg (name != command) "[[commands]]: ${name} cannot be set to both the `name` and the `command` attributes. Did you mean to use the `package` attribute?";
        if command == null || command == "" then [ ]
        else [
          (pkgs.writeShellScriptBin name (toString command))
        ];
    in
    (lib.concatMap op config.commands) ++ cfg.packages;
}
