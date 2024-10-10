# This module automatically configures postgres when the user enters the
# devshell.
#
# To start the server, invoke `postgres` in one devshell. Then start a second
# devshell to run the clients.
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };

  cfg = config.services.postgres;
  createDB = optionalString cfg.createUserDB ''
    echo "CREATE DATABASE ''${USER:-$(id -nu)};" | postgres --single -E postgres
  '';

  setup-postgres = pkgs.writeShellScriptBin "setup-postgres" ''
    set -euo pipefail
    export PATH=${cfg.package}/bin:${pkgs.coreutils}/bin

    # Abort if the data dir already exists
    [[ ! -d "$PGDATA" ]] || exit 0

    initdb ${concatStringsSep " " cfg.initdbArgs}

    cat >> "$PGDATA/postgresql.conf" <<EOF
      listen_addresses = '''
      unix_socket_directories = '$PGHOST'
    EOF

    ${createDB}
  '';

  start-postgres = pkgs.writeShellScriptBin "start-postgres" ''
    set -euo pipefail
    ${setup-postgres}/bin/setup-postgres
    exec ${cfg.package}/bin/postgres
  '';
in
{
  options.services.postgres = {
    package = mkOption {
      type = strOrPackage;
      description = "Which version of postgres to use";
      default = pkgs.postgresql;
      defaultText = "pkgs.postgresql";
    };

    setupPostgresOnStartup = mkEnableOption "call setup-postgres on startup";

    createUserDB = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Create a database named like current user on startup.
        This option only makes sense when `setupPostgresOnStartup` is true.
      '';
    };

    initdbArgs = mkOption {
      type = with types; listOf str;
      default = [ "--no-locale" ];
      example = [
        "--data-checksums"
        "--allow-group-access"
      ];
      description = ''
        Additional arguments passed to `initdb` during data dir
        initialisation.
      '';
    };

  };
  config = {
    packages = [
      cfg.package
    ];

    env = [
      {
        name = "PGDATA";
        eval = "$PRJ_DATA_DIR/postgres";
      }
      {
        name = "PGHOST";
        eval = "$PGDATA";
      }
    ];

    devshell.startup.setup-postgres.text = lib.optionalString cfg.setupPostgresOnStartup ''
      ${setup-postgres}/bin/setup-postgres
    '';

    commands = [
      {
        name = "setup-postgres";
        package = setup-postgres;
        help = "Setup the postgres data directory";
      }
      {
        name = "start-postgres";
        package = start-postgres;
        help = "Start the postgres server";
        category = "databases";
      }
    ];
  };
}
