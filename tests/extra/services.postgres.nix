{
  pkgs,
  devshell,
  runTest,
}:
{
  # Basic test
  simple =
    let
      shell = devshell.mkShell {
        imports = [ ../../extra/services/postgres.nix ];
        devshell.name = "services-postgres-example";
      };
    in
    runTest "simple" { } ''
      # Load the devshell
      source ${shell}/env.bash

      # Has postgres
      type -p postgres

      # Has a setup script
      setup-postgres

      # Second call is idempotent and should succeed as well
      setup-postgres

      # Start postgres in the background
      pg_ctl start
      trap "pg_ctl stop" EXIT

      # Test that the DB is up and running
      i=0
      while ! pg_isready; do
        if [[ $i -gt 10 ]]; then
          echo "could not connect to postgres"
          exit 1
        fi
        ((i++))
        sleep 0.2
        echo "x"
      done
      echo OK
    '';
}
