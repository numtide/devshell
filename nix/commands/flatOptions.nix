{ lib, strOrPackage, flatOptionsType }:
with lib;
# These are all the options available for the commands.
{
  prefix = mkOption {
    type = types.str;
    default = "";
    description = ''
      Prefix of the command name in the devshell menu.
    '';
  };

  name = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      Name of this command. 
      
      Defaults to a `package (${flatOptionsType.name})` name or pname if present.

      The value of this option is required for a `command (${flatOptionsType.name})`.
    '';
  };

  category = mkOption {
    type = types.str;
    default = "[general commands]";
    description = ''
      Sets a free text category under which this command is grouped
      and shown in the devshell menu.
    '';
  };

  help = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      Describes what the command does in one line of text.
    '';
  };

  command = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      If defined, it will add a script with the name of the command, and the
      content of this value.

      By default it generates a bash script, unless a different shebang is
      provided.
    '';
    example = ''
      #!/usr/bin/env python
      print("Hello")
    '';
  };

  package = mkOption {
    type = types.nullOr (types.oneOf [ strOrPackage types.package ]);
    default = null;
    description = ''
      Used to bring in a specific package. This package will be added to the
      environment.
    '';
  };

  expose = mkOption {
    type = types.bool;
    default = true;
    description = ''
      When `true`, the `command (${flatOptionsType.name})`
      or the `package (${flatOptionsType.name})` will be added to the environment.
        
      Otherwise, they will not be added to the environment, but will be printed
      in the devshell menu.
    '';
  };
}
