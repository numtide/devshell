{ pkgs, devshell, runTest }:
{
  # Test the environment variables
  env-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "devshell-env-1";
        env = [
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
      source ${shell}/env.bash

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
