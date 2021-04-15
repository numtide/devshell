{ config, lib, pkgs, ... }:
with lib;
let
  envOptions = {
    name = mkOption {
      type = types.str;
      description = "Name of the environment variable";
    };

    value = mkOption {
      type = with types; nullOr (oneOf [ str int bool ]);
      default = null;
      description = "Shell-escaped value to set";
    };

    eval = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Like value but not evaluated by Bash. This allows to inject other
        variable names or even commands using the `$()` notation.
      '';
      example = "$OTHER_VAR";
    };

    prefix = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Prepend to PATH-like environment variables.

        For example name = "PATH"; prefix = "bin"; will expand the path of
        ./bin and prepend it to the PATH, separated by ':'.
      '';
      example = "bin";
    };
  };

  envToBash = { name, value, eval, prefix }@args:
    let
      vals = filter (key: args.${key} != null) [ "value" "eval" "prefix" ];
      valType = head vals;
    in
    assert assertMsg ((length vals) > 0) "[[environ]]: ${name} expected one of value, eval or prefix to be set.";
    assert assertMsg ((length vals) < 2) "[[environ]]: ${name} expected only one of value, eval or prefix to be set. Not ${toString vals}";
    assert assertMsg (!(name == "PATH" && valType == "value")) "[[environ]]: ${name} should not override the value. Use 'prefix' instead.";
    if valType == "value" then
      "export ${name}=${escapeShellArg (toString value)}"
    else if valType == "eval" then
      "export ${name}=${eval}"
    else if valType == "prefix" then
      ''export ${name}=$(${pkgs.coreutils}/bin/realpath "${prefix}")''${${name}+:''${${name}}}''
    else
      throw "BUG in the env.nix module. This should never be reached.";
in
{
  options.env = mkOption {
    type = types.listOf (types.submodule { options = envOptions; });
    default = [ ];
    description = ''
      Add environment variables to the shell.
    '';
    example = literalExample ''
      [
        {
          name = "HTTP_PORT";
          value = 8080;
        }
        {
          name = "PATH";
          prefix = "bin";
        }
        {
          name = "XDG_CACHE_DIR";
          eval = "$DEVSHELL_ROOT/.cache";
        }
      ]
    '';
  };

  config = {
    # Default env
    env = lib.mkBefore [
      # Expose the path to nixpkgs
      {
        name = "NIXPKGS_PATH";
        value = toString pkgs.path;
      }

      # This is used by bash-completions to find new completions on demand
      {
        name = "XDG_DATA_DIRS";
        eval = ''$DEVSHELL_DIR/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}'';
      }
    ];

    devshell.startup_env = concatStringsSep "\n" (map envToBash config.env);
  };
}
