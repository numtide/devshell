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

  cfg = config.service.postgres;
in
{
  options.service.postgres = {
    package = mkOption {
      type = strOrPackage;
      description = "Which version of postgres to use";
      default = pkgs.postgresql;
      defaultText = "pkgs.postgresl";
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
      initdb
      cat >> "$PGDATA/postgresql.conf" <<EOF
        listen_addresses = '''
        unix_socket_directories = '$PGHOST'
      EOF
      echo "CREATE DATABASE ''${USER:-$(id -nu)};" | postgres --single -E postgres
      fi
    '';
  };
}
