{ pkgs, devshell, runTest }:
{
  # Basic devshell package usage
  devshell-packages-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "devshell-1";
        devshell.packages = [ pkgs.git ];
      };
    in
    runTest "devshell-1" { } ''
      # Load the devshell
      source ${shell}

      # Sets an environment variable that points to the buildEnv
      assert -n "$DEVSHELL_DIR"

      # Points DEVSHELL_ROOT to the project root
      assert "$PWD" == "$DEVSHELL_ROOT"

      # Adds packages to the PATH
      type -p git
    '';

  # Test the environment variables
  devshell-env-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "devshell-env-1";
        devshell.env = [
          {
            name = "HTTP_PORT";
            value = 8080;
          }
          {
            name = "PATH";
            prefix = "bin";
          }
          {
            name = "XDG_CACHE_DIR";
            eval = "$DEVSHELL_ROOT/$(echo .cache)";
          }
        ];
      };
    in
    runTest "devshell-env-1" { } ''
      unset XDG_DATA_DIRS

      # Load the devshell
      source ${shell}

      # NIXPKGS_PATH is being set
      assert "$NIXPKGS_PATH" == "${toString pkgs.path}"

      assert "$XDG_DATA_DIRS" == "$DEVSHELL_DIR/share:/usr/local/share:/usr/share"

      assert "$HTTP_PORT" == 8080

      # PATH is prefixed with an expanded bin folder
      [[ $PATH == $PWD/bin:* ]]

      # Eval
      assert "$XDG_CACHE_DIR" == "$PWD/.cache"
    '';
}
