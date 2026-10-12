{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    ;

  serviceOptions = {
    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Name of this service. Defaults to attribute name in group services.
      '';
    };
    command = mkOption {
      type = types.str;
      description = ''
        Command to execute.
      '';
    };
  };
  groupOptions = {
    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Name of the service group. Defaults to attribute name in groups.
      '';
    };
    description = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Short description of the service group, shown in generated commands
      '';
    };
    services = mkOption {
      type = types.attrsOf (types.submodule {options = serviceOptions;});
      default = {};
      description = ''
        Attrset of services that should be run in this group.
      '';
    };
    beforeStart = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Shell command to run before starting the service group.
      '';
    };
    afterStart = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Shell command to run after starting the service group.
      '';
    };
    beforeStop = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Shell command to run before stopping the service group.
      '';
    };
    afterStop = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Shell command to run after stopping the service group.
      '';
    };
  };
  groupToProcfile = name: g:
    pkgs.writeText "Procfile.${name}" (
      lib.concatLines (
        lib.mapAttrsToList (
          sName: s: "${
            if s.name == null
            then sName
            else s.name
          }: ${s.command}"
        )
        g.services
      )
    );
  groupToCommands = gName: g: let
    procfile = groupToProcfile gName g;
    description =
      if g.description == null
      then gName
      else g.description;
  in [
    {
      name = "${gName}:start";
      category = "service groups";
      help = "Start ${description} services";
      command =
        (pkgs.writeShellScript "${gName}-services-start" ''
          if [ -e "$PRJ_DATA_DIR/pids/${gName}.pid" ]; then
            echo "Already running, refusing to start"
            exit 1
          fi
          mkdir -p "$PRJ_DATA_DIR/pids/"
          ${g.beforeStart}
          ${pkgs.honcho}/bin/honcho start -f ${procfile} -d "$PRJ_ROOT" &
          pid=$!
          echo $pid > "$PRJ_DATA_DIR/pids/${gName}.pid"
          ${g.afterStart}
          on_stop() {
              ${g.beforeStop}
              if ps -p $pid > /dev/null; then
                kill -TERM $pid
              fi
              ${g.afterStop}
              rm "$PRJ_DATA_DIR/pids/${gName}.pid"
              wait $pid
          }
          trap "on_stop" SIGINT SIGTERM SIGHUP EXIT
          wait $pid
        '').outPath;
    }
    {
      name = "${gName}:stop";
      category = "service groups";
      help = "Stop ${description} services";
      command =
        (pkgs.writeShellScript "${gName}-services-stop" ''
          if [ -e "$PRJ_DATA_DIR/pids/${gName}.pid" ]; then
            pid=$(${pkgs.coreutils}/bin/cat "$PRJ_DATA_DIR/pids/${gName}.pid")
            ${g.beforeStop}
            kill -TERM $pid
            rm "$PRJ_DATA_DIR/pids/${gName}.pid"
            ${g.afterStop}
          fi
        '').outPath;
    }
  ];
in {
  options.serviceGroups = mkOption {
    type = types.attrsOf (types.submodule {options = groupOptions;});
    default = {};
    description = ''
      Add services to the environment. Services can be used to group long-running processes.
    '';
  };

  config.commands = lib.foldl (l: r: l ++ r) [] (
    lib.mapAttrsToList (
      gName: g:
        groupToCommands (
          if g.name == null
          then gName
          else g.name
        )
        g
    )
    config.serviceGroups
  );
}
