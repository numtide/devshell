{
  pkgs,
  devshell,
  runTest,
}:
{
  # Basic devshell usage
  commands-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "commands-1";
        commands = [
          {
            name = "bash-script";
            category = "hello";
            help = "Prints hello-bash";
            command = ''
              echo "hello-bash"
            '';
          }
          {
            name = "python-script";
            category = "hello";
            help = "Prints hello-python";
            command = ''
              #!/usr/bin/env python3
              print("hello-python")
            '';
          }
          { package = "git"; }
        ];
      };
    in
    runTest "devshell-1" { } ''
      # Load the devshell
      source ${shell}/env.bash

      menu

      # Checks that all the commands are available
      type -p bash-script
      type -p python-script
      type -p git

      assert "$(bash-script)" == hello-bash

      # Check that the shebang is correct. We can't execute it inside of the
      # sandbox because /usr/bin/env doesn't exist.
      #
      # Ideally it would be rewritten with patchShebang.
      assert "$(head -n1 "$(type -p python-script)")" == "#!/usr/bin/env python3"
    '';

  # Documentation-only commands
  commands-2 =
    let
      shell = devshell.mkShell {
        devshell.name = "commands-2";
        devshell.packages = [ pkgs.coreutils ];
        commands = [
          {
            name = "awol";
            category = "ambient";
            help = "Not present in the devshell :(";
            doc_only = true;
          }
          {
            name = "truant";
            category = "ambient";
            help = "Not present in the devshell, but no biggie :|";
            doc_only = true;
            warn_if_missing = false;
          }
          {
            name = "ok";
            category = "ambient";
            help = "Present in the devshell :)";
            doc_only = true;
          }
        ];
      };
    in
    runTest "devshell-2" { } ''
      ok() {
        : # NOP
      }

      # Capture output from loading devshell
      diag="$({ source ${shell}/env.bash || : ; } |& tee /dev/stderr)"

      # Actually load the devshell
      source ${shell}/env.bash

      [[ "$diag" == *warning:*"expected 'awol' to be available in"*'but it is missing'* ]] || assert "did not get expected message"
      [[ "$diag" != *warning:*"expected 'truant' to be available in"*'but it is missing'* ]] || assert "did not get expected message"
      [[ "$diag" != *warning:*"expected 'ok' to be available in"*'but it is missing'* ]] || assert "did not get expected message"

      menu

      # Checks that commands expected to be absent are indeed absent.
      ! type -p awol
      ! type -p truant
    '';
}
