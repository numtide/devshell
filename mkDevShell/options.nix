{ lib, pkgs, config, ... }:
with lib;
let
  instrumentedCommands = (import ./instrumentation.nix) {lib, pkgs, config};

  resolveKey = key:
    let
      attrs = builtins.filter builtins.isString (builtins.split "\\." key);
    in
    builtins.foldl' (sum: attr: sum.${attr}) pkgs attrs
  ;

  pad = str: num:
    if num > 0 then
      pad "${str} " (num - 1)
    else
      str
  ;

  ansiBoldOrange = "$(tput setaf 202)";
  ansiReset = "$(tput sgr0)";

  commandsToMenu = commands:
    let
      commandsSorted = builtins.sort (a: b: a.name < b.name) commands;

      commandLengths =
        map ({ name, ... }: builtins.stringLength name) commandsSorted;

      maxCommandLength =
        builtins.foldl'
          (max: v: if v > max then v else max)
          0
          commandLengths
      ;

      op = { name, help, ... }:
        let
          len = maxCommandLength - (builtins.stringLength name);
        in
        if help == null || help == "" then
          name
        else
          "${pad name len} - ${help}"
      ;

    in
    builtins.concatStringsSep "\n" (map op commandsSorted)
  ;

  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage =
    types.coercedTo types.str resolveKey types.package;

  # These are all the options available for the commands.
  commandOptions = {
    name = mkOption {
      type = types.str;
      # default = null;
      description = ''
        Name of this command. Defaults to attribute name in commands.
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
        If defined, it will define a script for the command.
      '';
    };

    package = mkOption {
      type = types.nullOr strOrPackage;
      default = null;
      description = ''
        Used to bring in a specific package. This package will be added to the
        environment.
      '';
    };
  };
in
{
  options = {
    name = mkOption {
      type = types.str;
      default = "devshell";
      description = ''
        Name of the shell environment. It usually maps to the project name.
      '';
    };

    # TODO: rename motd to something better.
    motd = mkOption {
      type = types.str;
      default = ''
        ${ansiBoldOrange}🔨 Welcome to ${config.name}${ansiReset}
        $(devshell-menu)
      '';
      description = ''
        Message Of The Day.

        This is the welcome message that is being printed when the user opens
        the shell.
      '';
    };

    # exclusively consumed by command instrumentation
    dev-ca-path = mkOption {
      type = types.str;
      default = "";
      description = ''
        Path to a development CA.

        Users can load/unload this dev CA easily and cleanly into their local
        trust stores via a wrapper around mkcert third party tool so that browsers
        and other tools would accept issued certificates under this CA as valid.

        Use cases:
         - Ship static dev certificates under version control and make them trusted
           on user machines: add the rootCA under version control alongside the
           your dev certificates.
         - Provide users with easy and reliable CA bootstrapping through the mkcert
           command: exempt this path from version control via .gitignore and have
           users  easily and reliably bootstrap a dev CA infrastructure on first use.
      '';
    };

    commands = mkOption {
      type = types.listOf (types.submodule { options = commandOptions; });
      default = [ ];
      description = ''
        Add commands to the environment.
      '';
      example = literalExample ''
        [
          {
            help = "print hello";
            name = "hello";
            alias = "echo hello";
          }

          {
            help = "used to format nix code";
            package = pkgs.nixpkgs-fmt;
          }
        ]
      '';
    };

    bash = mkOption {
      type = types.submodule {
        options = {
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
      };
      default = { };
    };

    env = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Environment variables to add to the environment.
      '';
      example = {
        GO111MODULE = "on";
        HTTP_PORT = 8080;
      };
    };

    packages = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = ''
        A list of packages to add to the environment.

        If the packages are passed as string, they will be retried from
        nixpkgs with the same attribute name.
      '';
    };

    # exclusively consumed by command instrumentation
    static-dns = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        A list of static DNS entries, for which to enable instrumentation.

        Users can enable/disable listed static DNS easily and cleanly
        via a wrapper around the hostctl third party tool.
      '';
      example = {
        "test.domain.local" = "172.0.0.1";
        "shared.domain.link-local" = "169.254.0.5";
      };
    };


  };

  config = {
    commands = [
      {
        help = "prints this menu";
        name = "devshell-menu";
        command = ''
          echo "[commands]"
          cat <<'DEVSHELL_MENU'
          ${commandsToMenu (config.commands ++ instrumentedCommands)}
          DEVSHELL_MENU
        '';
      }
    ] ++ instrumentedCommands;

    packages =
      lib.unique (
        builtins.filter (x: x != null)
          (map (x: x.package)
            (config.commands ++ instrumentedCommands)
          )
        );
  };
}
