{ pkgs, config, lib, ... }:
let
  inherit (lib) hasPrefix literalExpression mkDefault mkIf mkOption removePrefix types;
in
{
  # all rights reserved to nix-community
  # copy of https://github.com/nix-community/home-manager/blob/master/modules/lib/file-type.nix
  # Constructs a type suitable for a `devshell.file` like option. The
  # target path may be absolute, in which case it
  # is relative to project root
  # Arguments:
  #   - basePathDesc   docbook compatible description of the base path
  #   - basePath       the file base path
  fileType = basePathDesc: types.attrsOf (types.submodule (
    { name, config, ... }: {
      options = {
        target = mkOption {
          type = types.str;
          defaultText = literalExpression "<name>";
          description = ''
            Path to target file relative to ${basePathDesc}.
          '';
        };

        text = mkOption {
          default = null;
          type = types.nullOr types.lines;
          description = ''
            Text of the file. If this option is null then
            <link linkend="devshell.file._name_.source">devshel.file.&lt;name?&gt;.source</link>
            must be set.
          '';
        };

        source = mkOption {
          type = types.path;
          description = ''
            Path of the source file or directory. If
            <link linkend="devshell.file._name_.text">devshell.file.&lt;name?&gt;.text</link>
            is non-null then this option will automatically point to a file
            containing that text.
          '';
        };

        executable = mkOption {
          type = types.nullOr types.bool;
          default = null;
          description = ''
            Set the execute bit. If <literal>null</literal>, defaults to the mode
            of the <varname>source</varname> file or to <literal>false</literal>
            for files created through the <varname>text</varname> option.
          '';
        };
      };

      config = {
        target = mkDefault name;
        source = mkIf (config.text != null) (
          mkDefault (pkgs.writeTextFile {
            inherit (config) executable text;
            name = name;
          })
        );
      };
    }
  ));
}
