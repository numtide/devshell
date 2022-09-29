{ pkgs, devshell, runTest }:
{
  # Basic test
  simple =
    let
      shell = devshell.mkShell {
        imports = [ ../../extra/services/userhosts.nix ];
        packages = [
          pkgs.netcat
        ];
        services.userhosts.hosts = {
          "127.0.0.1" = [ "example.org" ];
        };
        devshell.name = "services-userhosts-simple";
      };
    in
    runTest "simple" { } ''
      # Load the devshell
      source ${shell}/env.bash

      nc -l 127.0.0.1 8080 &
      LISTENER_PID=$!
      trap "kill $LISTENER_PID 2>/dev/null || true" EXIT
      sleep 0.1
      nc -zv example.org 8080
    '';
}
