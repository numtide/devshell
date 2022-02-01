# This module automatically configures postgres when the user enters the
# devshell.
#
# To start the server, invoke `postgres` in one devshell. Then start a second
# devshell to run the clients.
{ lib, pkgs, config, ... }:
with lib;
let
  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };

  cfg = config.services.postgres;
in
{
  options.services.postgres = {
    package = mkOption {
      type = strOrPackage;
      description = "Which version of postgres to use";
      default = pkgs.postgresql;
      defaultText = "pkgs.postgresl";
    };

    initdbArgs = mkOption {
      type = with types; listOf str;
      default = [ "--no-locale" ];
      example = [ "--data-checksums" "--allow-group-access" ];
      description = ''
        Additional arguments passed to <literal>initdb</literal> during data dir
        initialisation.
      '';
    };

  };
  config = {
    packages = [ cfg.package ];

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

    devshell.startup.setup-postgres.text = ''
      if [[ ! -d "$PGDATA" ]]; then
      initdb ${concatStringsSep " " cfg.initdbArgs}
      cat >> "$PGDATA/postgresql.conf" <<EOF
        listen_addresses = '''
        unix_socket_directories = '$PGHOST'
      EOF
      echo "CREATE DATABASE ''${USER:-$(id -nu)};" | postgres --single -E postgres
      fi
    '';
  };
}
