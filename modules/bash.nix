{ lib, ... }:
with lib;
{
  options.bash = {
    extra = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra commands to run in bash on environment startup.
      '';
    };

    interactive = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Same as shellHook, but is only executed on interactive shells.

        This is useful to setup things such as custom prompt commands.
      '';
    };
  };
}
